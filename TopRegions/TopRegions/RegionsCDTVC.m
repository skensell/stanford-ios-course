//
//  RegionsCDTVC.m
//  TopRegions
//
//  Created by Scott Kensell on 2/14/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "RegionsCDTVC.h"
#import "DatabaseAvailabilityNotification.h"
#import "PlaceInfoDownloadsFinishedNotification.h"
#import "Region.h"
#import "PhotosByRegionCDTVC.h"
#import "Common.h"

#define MaximumRegionsToShow 10
static NSString *tableViewCellIdentifier = @"Region Cell";

@interface RegionsCDTVC ()
@property (nonatomic) BOOL placeInfoDownloadsFinished;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation RegionsCDTVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setupWithTitle:@"Top Regions"
 tableViewCellIdentifier:tableViewCellIdentifier
segueIdentifierToNextViewController:@"List Photos"
classOfViewControllerAfterSegue:[PhotosByRegionCDTVC class]];
}

#pragma mark - Database Context

// Because this is the first responder it gets its table view from a notification

- (void)awakeFromNib {
    // add self as observer for the DatabaseAvailabilityNotification
    [[NSNotificationCenter defaultCenter] addObserverForName:DatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[DatabaseAvailabilityContext];
                                                      [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                                                      name:DatabaseAvailabilityNotification
                                                                                                    object:nil];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:PlaceInfoDownloadsFinishedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      DEBUG(@"Received notification of PlaceInfoDownloadsFinished.");
                                                      self.placeInfoDownloadsFinished = YES;
                                                  }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = nil;
    request.fetchLimit = MaximumRegionsToShow; // TODO: refetch results later (with performFetch) to cut it down to 50 again.
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"numberOfPhotographers"
                                                              ascending:NO
                                                               selector:nil],
                                [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:tableViewCellIdentifier];
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = region.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photographers", [region.numberOfPhotographers intValue]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSUInteger numberOfRegions = [[self.fetchedResultsController fetchedObjects] count];
    return [NSString stringWithFormat:@"%d regions", numberOfRegions];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [super controllerDidChangeContent:controller];
    if (self.placeInfoDownloadsFinished ||
        [[self.fetchedResultsController fetchedObjects] count] > MaximumRegionsToShow + 5) {
        [self reduceNumberOfRegions];
        self.placeInfoDownloadsFinished = NO;
    }
}

- (void)reduceNumberOfRegions {
    if ([[self.fetchedResultsController fetchedObjects] count] > MaximumRegionsToShow) {
        DEBUG(@"Reducing size to %d.", MaximumRegionsToShow);
        [self performFetch];
    } else {
        DEBUG(@"%d or fewer regions. Not reducing size.", MaximumRegionsToShow);
    }
}

#pragma mark - Navigation

- (void)prepareNextViewController:(UIViewController *)vc
          afterSelectingIndexPath:(NSIndexPath *)indexPath
                  segueIdentifier:(NSString *)segueIdentifier {
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([vc isKindOfClass:[PhotosByRegionCDTVC class]]) {
        PhotosByRegionCDTVC *pbrcdtvc = (PhotosByRegionCDTVC *)vc;
        pbrcdtvc.region = region;
    }
    
    
}



@end
