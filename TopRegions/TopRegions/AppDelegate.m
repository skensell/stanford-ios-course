//
//  AppDelegate.m
//  TopRegions
//
//  Created by Scott Kensell on 2/14/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+Database.h"
#import "DatabaseAvailabilityNotification.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "Place+Flickr.h"
#import "FlickrManager.h"
#import "Common.h"

@interface AppDelegate() <NSURLSessionDownloadDelegate>
@property (copy, nonatomic) void (^flickrDownloadBackgroundURLSessionCompletionHandler)();
@property (strong, nonatomic) NSURLSession *flickrDownloadSession;
@property (strong, nonatomic) NSTimer *flickrForegroundFetchTimer;
@property (nonatomic) NSUInteger numberOfPlaceInfoDownloads;
@end

// name of the Flickr fetching background download session
#define FLICKR_FETCH @"Flickr Just Uploaded Fetch"
#define FLICKR_PLACE_FETCH @"Flickr Place Info Fetch"

// how often (in seconds) we fetch new photos if we are in the foreground
#define FOREGROUND_FLICKR_FETCH_INTERVAL (20*60)

// how long we'll wait for a Flickr fetch to return when we're in the background
#define BACKGROUND_FLICKR_FETCH_TIMEOUT (10)


@implementation AppDelegate

@synthesize databaseContext = _databaseContext;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [self openManagedDocument];
    return YES;
}

// this is called whenever a URL we have requested with a background session returns and we are in the background
// it is essentially waking us up to handle it
// if we were in the foreground iOS would just call our delegate method and not bother with this

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    // this completionHandler, when called, will cause our UI to be re-cached in the app switcher
    // but we should not call this handler until we're done handling the URL whose results are now available
    // so we'll stash the completionHandler away in a property until we're ready to call it
    // (see flickrDownloadTasksMightBeComplete for when we actually call it)
    self.flickrDownloadBackgroundURLSessionCompletionHandler = completionHandler;
}

#pragma mark - DatabaseDelegate

- (void)setDatabaseContext:(NSManagedObjectContext *)databaseContext {
    _databaseContext = databaseContext;

    [self.flickrForegroundFetchTimer invalidate];
    self.flickrForegroundFetchTimer = nil;
    
    if (self.databaseContext) {
        // this timer will fire only when we are in the foreground
        self.flickrForegroundFetchTimer = [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_FLICKR_FETCH_INTERVAL
                                                                           target:self
                                                                         selector:@selector(startFlickrFetch:)
                                                                         userInfo:nil
                                                                          repeats:YES];
        
        NSDictionary *userInfo = @{ DatabaseAvailabilityContext : self.databaseContext };
        [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseAvailabilityNotification
                                                            object:self
                                                          userInfo:userInfo];
        
        [self startFlickrFetch];
    } else {
        DEBUG(@"No databaseContext set.");
    }
}

#pragma mark - Flickr Fetching

// this will probably not work (task = nil) if we're in the background, but that's okay
// (we do our background fetching in performFetchWithCompletionHandler:)
// it will always work when we are the foreground (active) application

- (void)startFlickrFetch {
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        // let's see if we're already working on a fetch ...
        if (![downloadTasks count]) {
            // ... not working on a fetch, let's start one up
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH;
            [task resume];
            DEBUG(@"Download for RecentGeoreferencedPhotos started");
        } else {
            // ... we are working on a fetch (let's make sure they are running while we're here)
            for (NSURLSessionDownloadTask *task in downloadTasks) [task resume];
        }
    }];
}

- (void)startFlickrFetch:(NSTimer *)timer {
    [self startFlickrFetch];
}

- (void)startFlickrPlaceInfoFetchGivenPhotos:(NSArray *)photos {
    NSMutableSet *placeIDs = [[NSMutableSet alloc] initWithArray:[photos valueForKey:FLICKR_PHOTO_PLACE_ID]]; // this uniquefies it
    [placeIDs removeObject:[NSNull null]];
    
    DEBUG(@"Array had size %d and Set has size %d", photos.count, placeIDs.count);
    
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            self.numberOfPlaceInfoDownloads = 0;
            for (NSString *placeID in placeIDs) {
                Place *place = [Place placeFromPlaceID:placeID managedObjectContext:self.databaseContext];
                if (place.region == nil) {
                    // only fetch information about a place if it's not in the db
                    self.numberOfPlaceInfoDownloads++;
                    NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforInformationAboutPlace:placeID]];
                    task.taskDescription = FLICKR_PLACE_FETCH;
                    [task resume];
                }
            }
            DEBUG(@"%d downloadTasks for placeInfo.", self.numberOfPlaceInfoDownloads);
        } else {
            // ... we are working on a fetch (let's make sure they are running while we're here)
            for (NSURLSessionDownloadTask *task in downloadTasks) [task resume];
        }
    }];
}

- (NSURLSession *)flickrDownloadSession {
    if (!_flickrDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // notice the configuration here is "backgroundSessionConfiguration:"
            // that means that we will (eventually) get the results even if we are not the foreground application
            // even if our application crashed, it would get relaunched (eventually) to handle this URL's results!
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH];
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig
                                                                   delegate:self    // required for backgroundSessions
                                                              delegateQueue:nil];   // nil means "a random, non-main-queue queue"
        });
    }
    return _flickrDownloadSession;
}

#pragma mark - NSURLSessionDownloadDelegate

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile {
    // first comes the fetch for top photos, then many requests for place information.
    
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        DEBUG(@"Download for RecentGeoreferencedPhotos finished");
        NSArray *photos = [FlickrManager flickrPhotosAtURL:localFile];
        [FlickrManager loadFlickrPhotos:photos
                            intoContext:self.databaseContext
                    andThenExecuteBlock:^{
                        [self startFlickrPlaceInfoFetchGivenPhotos:photos];
                    }];

    } else if ([downloadTask.taskDescription isEqualToString:FLICKR_PLACE_FETCH]) {
        DEBUG(@"Download for PlaceInfo finished. %d left.", --self.numberOfPlaceInfoDownloads);
        NSDictionary *placeInfo = [FlickrManager placeInfoFromURL:localFile];
        
        [FlickrManager loadFlickrPlaces:@[placeInfo]
                            intoContext:self.databaseContext
                    andThenExecuteBlock:^{
                        [self flickrDownloadTasksMightBeComplete];
                    }];
        
    } else {
        WARNING(@"Unidentified downloadTask.taskDescription : %@", downloadTask.taskDescription);
    }
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    // we don't support resuming an interrupted download task
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    // we don't report the progress of a download in our UI, but this is a cool method to do that with
}

// not required by the protocol, but we should definitely catch errors here
// so that we can avoid crashes
// and also so that we can detect that download tasks are (might be) complete
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error && (session == self.flickrDownloadSession)) {
        ERROR(@"Flickr background download session failed: %@", error.localizedDescription);
        [self flickrDownloadTasksMightBeComplete];
    }
}

// this is "might" in case some day we have multiple downloads going on at once
- (void)flickrDownloadTasksMightBeComplete {
    if (self.flickrDownloadBackgroundURLSessionCompletionHandler) {
        // our app was in the background when a download finished so we need to update UI in app switcher
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            //  note that getTasksWithCompletionHandler: is ASYNCHRONOUS
            //  so we must check again when the block executes if the handler is still not nil
            //  (another thread might have sent it already in a multiple-tasks-at-once implementation)
            if (![downloadTasks count]) {  // any more Flickr downloads left?
                // nope, then invoke flickrDownloadBackgroundURLSessionCompletionHandler (if it's still not nil)
                void (^completionHandler)() = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                self.flickrDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            } // else other downloads going, so let them call this method when they finish
        }];
    }
}



@end
