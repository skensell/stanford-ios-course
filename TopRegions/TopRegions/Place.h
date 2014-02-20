//
//  Place.h
//  TopRegions
//
//  Created by Scott Kensell on 2/19/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Region;

@interface Place : NSManagedObject

@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) Region *region;
@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
