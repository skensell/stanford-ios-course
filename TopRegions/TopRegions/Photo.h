//
//  Photo.h
//  TopRegions
//
//  Created by Scott Kensell on 2/15/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer, Place;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSDate * lastViewed;
@property (nonatomic, retain) Photographer *whoTook;
@property (nonatomic, retain) Place *place;

@end
