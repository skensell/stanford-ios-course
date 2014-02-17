//
//  Place+Flickr.h
//  TopRegions
//
//  Created by Scott Kensell on 2/15/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "Place.h"
#import "Region.h"

@interface Place (Flickr)

+ (Place *)placeFromPlaceID:(NSString *)placeID
       managedObjectContext:(NSManagedObjectContext *)context;

+ (void)loadPlacesFromFlickrArray:(NSArray *)placesOfPhotos
            intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
