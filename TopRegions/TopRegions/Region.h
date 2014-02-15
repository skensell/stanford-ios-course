//
//  Region.h
//  TopRegions
//
//  Created by Scott Kensell on 2/14/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Photographer;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfPhotographers;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) Photographer *photographers;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
