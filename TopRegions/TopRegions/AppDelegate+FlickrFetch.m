//
//  AppDelegate+FlickrFetch.m
//  TopRegions
//
//  Created by Scott Kensell on 2/20/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "AppDelegatePrivate.h"

#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "Place+Flickr.h"
#import "FlickrManager.h"
#import "PlaceInfoDownloadsFinishedNotification.h"


@implementation AppDelegate (FlickrFetch)

#pragma mark - Background fetching
// When our app is in the background

- (void)startFlickrFetchWhenAppIsInBackground {
    NSURLSession *session = [self sessionWhenAppInBackground];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                    completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                        if (error) {
                                                            ERROR(@"Flickr background fetch failed: %@", error.localizedDescription);
                                                            [self callEphemeralCompletionHandlerHasNewData:NO];
                                                        } else {
                                                            DEBUG(@"Flickr background fetch succeeded for RecentGeoreferencedPhotos finished");
                                                            NSArray *photos = [FlickrManager flickrPhotosAtURL:localFile];
                                                            [FlickrManager loadFlickrPhotos:photos
                                                                                intoContext:self.databaseContext
                                                                        andThenExecuteBlock:^{
                                                                            [self startFlickrPlaceInfoFetchGivenPhotos:photos
                                                                                                     appIsInBackground:YES];
                                                                        }];
                                                        }
                                                    }];
    [task resume];
}

- (void)callEphemeralCompletionHandlerHasNewData:(BOOL)hasNewData {
    DEBUG(@"Calling EphemeralURLSessionCompletionHandler. HasNewData: %d", hasNewData);
    void (^ephemeralSessionCompletion)(UIBackgroundFetchResult) = self.flickrDownloadEphemeralURLSessionCompletionHandler;
    self.flickrDownloadEphemeralURLSessionCompletionHandler = nil;
    if (ephemeralSessionCompletion) {
        if (hasNewData) {
            ephemeralSessionCompletion(UIBackgroundFetchResultNewData);
        } else {
            ephemeralSessionCompletion(UIBackgroundFetchResultNoData);
        }
    }
}

- (NSURLSession *)sessionWhenAppInBackground {
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfig.allowsCellularAccess = NO;
    sessionConfig.timeoutIntervalForRequest = BACKGROUND_FLICKR_FETCH_TIMEOUT; // want to be a good background citizen!
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    return session;
}

#pragma mark - Foreground fetching

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
    [self startFlickrPlaceInfoFetchGivenPhotos:photos appIsInBackground:NO];
}

- (void)startFlickrPlaceInfoFetchGivenPhotos:(NSArray *)photos
                           appIsInBackground:(BOOL)appIsInBackground {
    // we need to use different session configs depending on whether the app is in the background or not.
    // also we can use a block completion handler when in the background, but just delegate for foreground
    
    NSMutableSet *placeIDs = [[NSMutableSet alloc] initWithArray:[photos valueForKey:FLICKR_PHOTO_PLACE_ID]]; // this uniquefies it
    [placeIDs removeObject:[NSNull null]];
    DEBUG(@"%d fetched PlaceIDs, %d unique PlaceIDs.", photos.count, placeIDs.count);
    
    NSURLSession *session = (appIsInBackground) ? [self sessionWhenAppInBackground] : self.flickrDownloadSession;
    
    // I prob don't need to call getTasksWith... because this should only be fired once.
    BOOL theAppIsInBackground = appIsInBackground;
    [session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (([downloadTasks count] == 0) && (self.numberOfPlaceInfoDownloads == 0)) {
            self.numberOfPlaceInfoDownloads = 0;
            for (NSString *placeID in placeIDs) {
                Place *place = [Place placeFromPlaceID:placeID managedObjectContext:self.databaseContext];
                if (place.region == nil) {
                    // only fetch information about a place if it's not in the db
                    self.numberOfPlaceInfoDownloads++;
                    NSURLSessionDownloadTask *task;
                    if (theAppIsInBackground) {
                        task = [session downloadTaskWithURL:[FlickrFetcher URLforInformationAboutPlace:placeID]
                                          completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                              if (error) {
                                                  ERROR(@"PlaceInfo download failed when appInBackground. %@", error.localizedDescription);
                                              } else {
                                                  [self placeInfoDownloadFinishedToLocalFile:location];
                                              }
                                          }];
                    } else {
                        task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforInformationAboutPlace:placeID]];
                    }
                    task.taskDescription = FLICKR_PLACE_FETCH;
                    [task resume];
                }
            }
            DEBUG(@"%d downloadTasks for placeInfo.", self.numberOfPlaceInfoDownloads);
        } else {
            // ... we are working on a fetch (let's make sure they are running while we're here)
            WARNING(@"We have %d download tasks when attempting to start placeInfoFetch.", [downloadTasks count]);
            for (NSURLSessionDownloadTask *task in downloadTasks) [task resume];
        }
    }];
    
}

- (void)placeInfoDownloadFinishedToLocalFile:(NSURL *)localFile {
    DEBUG(@"Download for PlaceInfo finished. %d left.", --self.numberOfPlaceInfoDownloads);
    NSDictionary *placeInfo = [FlickrManager placeInfoFromURL:localFile];
    
    NSInteger numberOfPlaceInfoDownloads = self.numberOfPlaceInfoDownloads;
    [FlickrManager loadFlickrPlaces:@[placeInfo]
                        intoContext:self.databaseContext
                andThenExecuteBlock:^{
                    if (numberOfPlaceInfoDownloads == 0) {
                        [self flickrDownloadTasksMightBeComplete];
                        DEBUG(@"All PlaceInfo downloads finished.");
                        [[NSNotificationCenter defaultCenter] postNotificationName:PlaceInfoDownloadsFinishedNotification
                                                                            object:self];
                    }
                }];
}

- (void)flickrFetchDownloadFinishedToLocalFile:(NSURL *)localFile {
    DEBUG(@"Download for RecentGeoreferencedPhotos finished");
    NSArray *photos = [FlickrManager flickrPhotosAtURL:localFile];
    [FlickrManager loadFlickrPhotos:photos
                        intoContext:self.databaseContext
                andThenExecuteBlock:^{
                    [self startFlickrPlaceInfoFetchGivenPhotos:photos];
                }];
}

#pragma mark - NSURLSessionDownloadDelegate

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile {
    // first comes the fetch for top photos, then many requests for place information.
    
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {

        [self flickrFetchDownloadFinishedToLocalFile:localFile];
        
    } else if ([downloadTask.taskDescription isEqualToString:FLICKR_PLACE_FETCH]) {
        
        [self placeInfoDownloadFinishedToLocalFile:localFile];
        
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
    
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        //  note that getTasksWithCompletionHandler: is ASYNCHRONOUS
        //  so we must check again when the block executes if the handler is still not nil
        //  (another thread might have sent it already in a multiple-tasks-at-once implementation)
        if (![downloadTasks count]) {  // any more Flickr downloads left?
            // nope, then invoke flickrDownloadBackgroundURLSessionCompletionHandler (if it's still not nil)
            DEBUG(@"No more flickr downloads.");
            if (self.flickrDownloadBackgroundURLSessionCompletionHandler) {
                DEBUG(@"Updating UI in app-switcher.");
                void (^completionHandler)() = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                self.flickrDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            }
            if (self.flickrDownloadEphemeralURLSessionCompletionHandler) {
                [self callEphemeralCompletionHandlerHasNewData:YES];
            }
        } // else other downloads going, so let them call this method when they finish
    }];
}


@end
