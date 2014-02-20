//
//  HistoryViewController.m
//  flickr_places
//
//  Created by Scott Kensell on 1/29/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "HistoryCDTVC.h"
#import "DatabaseAvailabilityNotification.h"

@interface HistoryCDTVC ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation HistoryCDTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"History";
    [self setupFetchedResultsController];
}

// Because this is not being segued to we subscribe to the Database being available.

- (void)awakeFromNib {
    // add self as observer for the DatabaseAvailabilityNotification
    [[NSNotificationCenter defaultCenter] addObserverForName:DatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[DatabaseAvailabilityContext];
                                                  }];
}


- (void)setupFetchedResultsController {
    if (self.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        NSDate *referenceDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
        request.predicate = [NSPredicate predicateWithFormat:@"lastViewed > %@", referenceDate];
        request.fetchLimit = 50;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastViewed"
                                                                  ascending:NO
                                                                   selector:@selector(compare:)]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

@end
