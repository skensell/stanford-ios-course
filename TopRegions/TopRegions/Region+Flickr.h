//
//  Region+Flickr.h
//  TopRegions
//
//  Created by Scott Kensell on 2/16/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "Region.h"

@interface Region (Flickr)

+ (Region *)regionWithName:(NSString *)name
      managedObjectContext:(NSManagedObjectContext *)context;

+ (void)updateNumberOfPhotographersInRegion:(Region *)region;

@end
