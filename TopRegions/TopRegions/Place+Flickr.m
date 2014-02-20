//
//  Place+Flickr.m
//  TopRegions
//
//  Created by Scott Kensell on 2/15/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "Place+Flickr.h"
#import "Common.h"
#import "FlickrFetcher.h"
#import "Region+Flickr.h"

@implementation Place (Flickr)

+ (Place *)placeFromPlaceID:(NSString *)placeID
       managedObjectContext:(NSManagedObjectContext *)context  {
    
    Place *place;
    if (placeID && placeID.length) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
        request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", placeID];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || error || ([matches count] > 1)) {
            ERROR(@"query error : %@", [error localizedDescription]);
        } else  if ([matches count] == 1){
            place = [matches firstObject];
        } else {
            place = [NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                                  inManagedObjectContext:context];
            place.unique = placeID;
        }
    }
    return place;
}

+ (void)loadPlacesFromFlickrArray:(NSArray *)placesOfPhotos
         intoManagedObjectContext:(NSManagedObjectContext *)context {
    
    NSMutableSet *regionsAffected = [[NSMutableSet alloc] init];
    for (NSDictionary *placeInfo in placesOfPhotos) {
        for (NSString *placeID in [FlickrFetcher allPlaceIDsFromPlaceInformation:placeInfo]) {
            Place *place = [self placeFromPlaceID:placeID managedObjectContext:context];
            Region *region = [Region regionWithName:[FlickrFetcher extractRegionNameFromPlaceInformation:placeInfo]
                               managedObjectContext:context];
            if (region) {
                place.region = region;
                [regionsAffected addObject:region];
            }
        }
    }
    
    for (Region *region in regionsAffected) {
        [Region updateNumberOfPhotographersInRegion:region];
    }
    
}

@end
