//
//  PhotosByRegionCDTVC.m
//  TopRegions
//
//  Created by Scott Kensell on 2/14/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "PhotosByRegionCDTVC.h"

@implementation PhotosByRegionCDTVC

// follow the example below. set the context in the setter.

@end


//#import "PhotosByPhotographerCDTVC.h"
//
//@implementation PhotosByPhotographerCDTVC
//
//- (void)setPhotographer:(Photographer *)photographer
//{
//    _photographer = photographer;
//    self.title = photographer.name;
//    [self setupFetchedResultsController];
//}
//
//- (void)setupFetchedResultsController
//{
//    NSManagedObjectContext *context = self.photographer.managedObjectContext;
//    
//    if (context) {
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
//        request.predicate = [NSPredicate predicateWithFormat:@"whoTook = %@", self.photographer];
//        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
//                                                                  ascending:YES
//                                                                   selector:@selector(localizedStandardCompare:)]];
//        
//        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
//                                                                            managedObjectContext:context
//                                                                              sectionNameKeyPath:nil
//                                                                                       cacheName:nil];
//    } else {
//        self.fetchedResultsController = nil;
//    }
//}
//
//
//@end
