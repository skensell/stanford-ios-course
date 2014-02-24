//
//  FlickrManager.h
//  TopRegions
//
//  Created by Scott Kensell on 2/16/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FlickrManager : NSObject

+ (void)loadFlickrPhotos:(NSArray *)photos
             intoContext:(NSManagedObjectContext *)context
     andThenExecuteBlock:(void(^)())whenDone;

+ (void)loadFlickrPlaces:(NSArray *)placesOfPhotos
             intoContext:(NSManagedObjectContext *)context
     andThenExecuteBlock:(void(^)())whenDone;

+ (NSArray *)flickrPhotosAtURL:(NSURL *)url;
+ (NSDictionary *)placeInfoFromURL:(NSURL *)url;

+ (void)deleteOldPhotos:(NSManagedObjectContext *)context;

@end
