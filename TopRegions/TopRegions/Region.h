//
//  Region.h
//  TopRegions
//
//  Created by Scott Kensell on 2/15/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Region : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfPhotographers;
@property (nonatomic, retain) NSSet *places;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addPlacesObject:(NSManagedObject *)value;
- (void)removePlacesObject:(NSManagedObject *)value;
- (void)addPlaces:(NSSet *)values;
- (void)removePlaces:(NSSet *)values;

@end
