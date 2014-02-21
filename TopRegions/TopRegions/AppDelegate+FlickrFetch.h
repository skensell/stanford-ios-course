//
//  AppDelegate+FlickrFetch.h
//  TopRegions
//
//  Created by Scott Kensell on 2/20/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "AppDelegate.h"

// To use this category you should create a singleton flickrDownloadSession @property which
// has configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH];

@interface AppDelegate (FlickrFetch) <NSURLSessionDownloadDelegate>
- (void)startFlickrFetchWhenAppIsInBackground;
- (void)startFlickrFetch;
- (void)startFlickrFetch:(NSTimer *)timer;
@end
