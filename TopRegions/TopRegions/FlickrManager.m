//
//  FlickrManager.h
//  TopRegions
//
//  Created by Scott Kensell on 2/16/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "FlickrManager.h"

#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "Place+Flickr.h"
#import "NSURL+JSON.h"
#import "Common.h"

@implementation FlickrManager

#pragma mark - Public

+ (void)loadFlickrPhotos:(NSArray *)photos
             intoContext:(NSManagedObjectContext *)context
     andThenExecuteBlock:(void(^)())whenDone {
    
    [self loadObjects:photos
              ofClass:[Photo class]
          intoContext:context
  andThenExecuteBlock:whenDone];
}

+ (void)loadFlickrPlaces:(NSArray *)placesOfPhotos
             intoContext:(NSManagedObjectContext *)context
     andThenExecuteBlock:(void(^)())whenDone {
    
    [self loadObjects:placesOfPhotos
              ofClass:[Place class]
          intoContext:context
  andThenExecuteBlock:whenDone];
}

+ (NSDictionary *)placeInfoFromURL:(NSURL *)url {
    return [url dictFromJSONData];
}

+ (NSArray *)flickrPhotosAtURL:(NSURL *)url {
    NSDictionary *flickrPropertyList = [url dictFromJSONData];
    return [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
}


#pragma mark - Private

+ (void)loadObjects:(NSArray *)objects
            ofClass:(Class)class
        intoContext:(NSManagedObjectContext *)context
andThenExecuteBlock:(void(^)())whenDone {
    
    if (!context) {
        if (whenDone) whenDone();
        return;
    }
    
    [context performBlock:^{
        if ([class isSubclassOfClass:[Photo class]]) {
            [Photo loadPhotosFromFlickrArray:objects intoManagedObjectContext:context];
        } else if ([class isSubclassOfClass:[Place class]]) {
            [Place loadPlacesFromFlickrArray:objects intoManagedObjectContext:context];
        } else {
            ERROR(@"Unrecognized class : %@", class);
        }
        
        if (whenDone) whenDone();
    }];
}



@end
