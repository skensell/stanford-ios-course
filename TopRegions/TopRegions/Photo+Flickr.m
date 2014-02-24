//
//  Photo+Flickr.m
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"
#import "Place+Flickr.h"
#import "Common.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context {
    Photo *photo = nil;
    
    NSString *unique = photoDictionary[FLICKR_PHOTO_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        ERROR(@"query error : %@", [error localizedDescription]);
    } else if ([matches count]) {
        photo = [matches firstObject];
    } else {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];
        photo.unique = unique;
        NSString *title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.title = title.length ? title : @"Unknown";
        photo.created = [NSDate date];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.thumbURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        
        NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        photo.whoTook = [Photographer photographerWithName:photographerName
                                    inManagedObjectContext:context];
        
        NSString *placeID = [photoDictionary valueForKeyPath:FLICKR_PHOTO_PLACE_ID];
        photo.place = [Place placeFromPlaceID:placeID managedObjectContext:context];

    }

    return photo;
}

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos // of Flickr NSDictionary
         intoManagedObjectContext:(NSManagedObjectContext *)context {
    for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
    }
}

+ (void)deletePhotos:(NSArray *)thePhotos {
    if (![thePhotos count]) {
        return;
    }
    NSMutableArray *photos = [NSMutableArray arrayWithArray:thePhotos];
    while (photos.count) {
        Photo *photo = [photos lastObject];
        [photos removeLastObject];
        NSManagedObjectContext *context = photo.managedObjectContext;
        [context deleteObject:photo];
    }
}

@end
