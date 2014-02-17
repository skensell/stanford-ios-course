//
//  Region+Flickr.m
//  TopRegions
//
//  Created by Scott Kensell on 2/16/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "Region+Flickr.h"
#import "Common.h"

@implementation Region (Flickr)

+ (Region *)regionWithName:(NSString *)name
      managedObjectContext:(NSManagedObjectContext *)context {
    Region *region;
    if (name && name.length) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || error || ([matches count] > 1)) {
            ERROR(@"query error : %@", [error localizedDescription]);
        } else  if ([matches count] == 1){
            region = [matches firstObject];
        } else {
            region = [NSEntityDescription insertNewObjectForEntityForName:@"Region"
                                                   inManagedObjectContext:context];
            region.name = name;
        }
    } else {
        ERROR(@"Nil region name given for region query.");
    }
    return region;
}

@end
