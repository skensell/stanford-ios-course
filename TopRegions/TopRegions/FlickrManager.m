//
//  FlickrManager.h
//  TopRegions
//
//  Created by Scott Kensell on 2/16/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "FlickrManager.h"

#import "FlickrFetcher.h"
#import "Region+Flickr.h"
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

+ (void)deleteOldPhotos:(NSManagedObjectContext *)context {
    DEBUG(@"Deleting old photos.");
    NSTimeInterval secondsInADay = 60*60*24;
    NSDate *oneDayAgo = [NSDate dateWithTimeIntervalSinceNow:-secondsInADay];
    [self executeFetchRequestWithEntityName:@"Photo"
                              withPredicate:[NSPredicate predicateWithFormat:@"created < %@", oneDayAgo]
                       managedObjectContext:context
                          completionHandler:^(NSArray *matches) {
                              [self deleteObjects:matches
                                        InContext:context];
                              [self deletePlacesWithNoPhotos:context];
                              [self deletePhotographersWithNoPhotos:context];
                              DEBUG(@"Finished cleaning out the old.");
                          }];
}

#pragma mark - Private callbacks

+ (void)deletePlacesWithNoPhotos:(NSManagedObjectContext *)context {
    DEBUG(@"Deleting places with no photos.");
    [self executeFetchRequestWithEntityName:@"Place"
                              withPredicate:[NSPredicate predicateWithFormat:@"photos.@count < 1"]
                       managedObjectContext:context
                          completionHandler:^(NSArray *matches) {
                              [self deleteObjects:matches
                                        InContext:context];
                              [self deleteRegionsWithNoPlaces:context];
                          }];
}

+ (void)deleteRegionsWithNoPlaces:(NSManagedObjectContext *)context {
    DEBUG(@"Deleting Regions with no places.");
    [self executeFetchRequestWithEntityName:@"Region"
                              withPredicate:[NSPredicate predicateWithFormat:@"places.@count < 1"]
                       managedObjectContext:context
                          completionHandler:^(NSArray *matches) {
                              [self deleteObjects:matches
                                        InContext:context];
                          }];
}

+ (void)deletePhotographersWithNoPhotos:(NSManagedObjectContext *)context {
    DEBUG(@"Deleting Photographers with no photos.");
    [self executeFetchRequestWithEntityName:@"Photographer"
                              withPredicate:[NSPredicate predicateWithFormat:@"photos.@count < 1"]
                       managedObjectContext:context
                          completionHandler:^(NSArray *matches) {
                              [self deleteObjects:matches
                                        InContext:context];
                              [self updateNumberOfPhotographers:context];
                          }];
}

+ (void)updateNumberOfPhotographers:(NSManagedObjectContext *)context {
    DEBUG(@"Updating number of photographers for all regions.");
    [self executeFetchRequestWithEntityName:@"Region"
                              withPredicate:nil // fetch all
                       managedObjectContext:context
                          completionHandler:^(NSArray *matches) {
                              for (Region *region in matches) {
                                  [Region updateNumberOfPhotographersInRegion:region];
                              }
                          }];
}


#pragma mark - Private helpers

+ (void)executeFetchRequestWithEntityName:(NSString *)entityName
                            withPredicate:(NSPredicate *)predicate
                     managedObjectContext:(NSManagedObjectContext *)context
                        completionHandler:(void(^)(NSArray *matches))completionHandler {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate = predicate;
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error) {
        ERROR(@"query error : %@", [error localizedDescription]);
    } else if (![matches count]) {
        DEBUG(@"0 matches for %@ query with predicate '%@'", entityName, predicate);
    } else {
        completionHandler(matches);
    }
}


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


+ (void)deleteObjects:(NSArray *)theManagedObjects InContext:(NSManagedObjectContext *)context {
    if (![theManagedObjects count]) {
        return;
    }
    NSMutableArray *managedObjects = [NSMutableArray arrayWithArray:theManagedObjects];
    DEBUG(@"Deleting %d objects", [managedObjects count]);
    while (managedObjects.count) {
        id obj = [managedObjects lastObject];
        if ([obj isKindOfClass:[NSManagedObject class]]) {
            // DEBUG(@"Deleting object of type %@", [obj class]);
            NSManagedObject *managedObject = (NSManagedObject *)obj;
            [managedObjects removeLastObject];
            [context deleteObject:managedObject];
        } else {
            DEBUG(@"Tried to delete object of type %@, expected NSManagedObject", [obj class]);
            break;
        }
    }
}


@end
