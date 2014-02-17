//
//  FlickrFetcher.h
//
//  Created for Stanford CS193p Fall 2013.
//  Copyright 2013 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

// key paths to photos or places at top-level of Flickr results
#define FLICKR_RESULTS_PHOTOS @"photos.photo"
#define FLICKR_RESULTS_PLACES @"places.place"

// keys (paths) to values in a photo dictionary
#define FLICKR_PHOTO_TITLE @"title"
#define FLICKR_PHOTO_DESCRIPTION @"description._content"
#define FLICKR_PHOTO_ID @"id"
#define FLICKR_PHOTO_OWNER @"ownername"
#define FLICKR_PHOTO_UPLOAD_DATE @"dateupload" // in seconds since 1970
#define FLICKR_PHOTO_PLACE_ID @"place_id"

// keys (paths) to values in a places dictionary (from TopPlaces)
#define FLICKR_PLACE_NAME @"_content"
#define FLICKR_PLACE_ID @"place_id"

// keys applicable to all types of Flickr dictionaries
#define FLICKR_LATITUDE @"latitude"
#define FLICKR_LONGITUDE @"longitude"
#define FLICKR_TAGS @"tags"

// keys (paths) to values in a placeInfo dictionary
#define FLICKR_PLACE_NEIGHBORHOOD_NAME @"place.neighbourhood._content"
#define FLICKR_PLACE_NEIGHBORHOOD_PLACE_ID @"place.neighbourhood.place_id"
#define FLICKR_PLACE_LOCALITY_NAME @"place.locality._content"
#define FLICKR_PLACE_LOCALITY_PLACE_ID @"place.locality.place_id"
#define FLICKR_PLACE_REGION_NAME @"place.region._content"
#define FLICKR_PLACE_REGION_PLACE_ID @"place.region.place_id"
#define FLICKR_PLACE_COUNTY_NAME @"place.county._content"
#define FLICKR_PLACE_COUNTY_PLACE_ID @"place.county.place_id"
#define FLICKR_PLACE_COUNTRY_NAME @"place.country._content"
#define FLICKR_PLACE_COUNTRY_PLACE_ID @"place.country.place_id"
#define FLICKR_PLACE_REGION @"place.region"

typedef enum {
	FlickrPhotoFormatSquare = 1,    // thumbnail
	FlickrPhotoFormatLarge = 2,     // normal size
	FlickrPhotoFormatOriginal = 64  // high resolution
} FlickrPhotoFormat;

@interface FlickrFetcher : NSObject

+ (NSURL *)URLforTopPlaces;

+ (NSURL *)URLforPhotosInPlace:(id)flickrPlaceId maxResults:(int)maxResults;

+ (NSURL *)URLforPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat)format;

+ (NSURL *)URLforRecentGeoreferencedPhotos;

+ (NSURL *)URLforInformationAboutPlace:(id)flickrPlaceId;

+ (NSString *)extractNameOfPlace:(id)placeId fromPlaceInformation:(NSDictionary *)place;
+ (NSString *)extractRegionNameFromPlaceInformation:(NSDictionary *)placeInformation;
+ (NSArray *)allPlaceIDsFromPlaceInformation:(NSDictionary *)place;

@end
