//
//  AppDelegatePrivate.h
//  TopRegions
//
//  Created by Scott Kensell on 2/20/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#ifndef TopRegions_AppDelegatePrivate_h
#define TopRegions_AppDelegatePrivate_h

#import "AppDelegate.h"
#import "AppDelegate+Database.h"
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

#endif
