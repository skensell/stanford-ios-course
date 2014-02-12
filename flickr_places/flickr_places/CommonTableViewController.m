//
//  CommonTableViewController.m
//  flickr_places
//
//  Created by Scott Kensell on 2/3/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "CommonTableViewController.h"

@interface CommonTableViewController ()
@property (nonatomic, strong, readwrite) NSArray *fetchedDataFromFlickr;
@property (nonatomic, strong) NSString *tableViewCellIdentifier;
@property (nonatomic, strong) NSString *segueIdentifierToNextViewController;
@property (nonatomic, strong) Class classOfViewControllerAfterSegue;
@end

@implementation CommonTableViewController

- (void)setFetchedDataFromFlickr:(NSArray *)fetchedDataFromFlickr {
    _fetchedDataFromFlickr = fetchedDataFromFlickr;
    [self prepareFetchedDataForTableReload];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.fetchedDataFromFlickr && self.refreshControl) {
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:NO];
    }
    [self fetchFlickrData];
}

#pragma mark - Protected

- (void)setupWithTitle:(NSString *)title
tableViewCellIdentifier:(NSString *)tableViewCellIdentifier
segueIdentifierToNextViewController:(NSString *)segueIdentifierToNextViewController
classOfViewControllerAfterSegue:(Class)classOfViewControllerAfterSegue {
    
    self.title = (self.title) ? self.title : title;
    _tableViewCellIdentifier = tableViewCellIdentifier;
    _segueIdentifierToNextViewController = segueIdentifierToNextViewController;
    _classOfViewControllerAfterSegue = classOfViewControllerAfterSegue;
    
}

- (IBAction)fetchFlickrData {
    
}

- (IBAction)fetchFlickrDataAtURL:(NSURL *)url keyPath:(NSString *)keyPath {
    [self.refreshControl beginRefreshing]; // start the spinner

    // create a (non-main) queue to do fetch on
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    // put a block to do the fetch onto that queue
    dispatch_async(fetchQ, ^{
        // fetch the JSON data from Flickr
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        if (!jsonResults) {
            DEBUG(@"No JSON results found at url: %@", url);
        }
        NSError *error;
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                            options:0
                                                                              error:&error];
        if (error) {
            DEBUG(@"Failed to create NSDictionary from JSON: %@", error);
        }
        NSArray *fetched = [propertyListResults valueForKeyPath:keyPath];
        if (!fetched || fetched.count == 0) {
            DEBUG(@"Raw result from query to %@ \n%@", [url description], propertyListResults);
        }
        //DEBUG(@"Result as array:\n%@", fetched);
        
        // update the Model (and thus our UI), but do so back on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing]; // stop the spinner
            self.fetchedDataFromFlickr = fetched;
        });
    });
}

- (void)prepareFetchedDataForTableReload {
    // abstract method
}

- (void)prepareNextViewController:(UIViewController *)vc afterSelectingIndexPath:(NSIndexPath *)indexPath {
    // abstract method
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (NSString *)titleForCellAtIndexPath:(NSIndexPath *)indexPath {
    // abstract
    return nil;
}

- (NSString *)subtitleForCellAtIndexPath:(NSIndexPath *)indexPath {
    // abstract
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [self tableViewCellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self titleForCellAtIndexPath:indexPath];
    cell.detailTextLabel.text = [self subtitleForCellAtIndexPath:indexPath];
    
    return cell;
}




#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath && [segue.identifier isEqualToString:[self segueIdentifierToNextViewController]] &&
            [segue.destinationViewController isKindOfClass:[self classOfViewControllerAfterSegue]]) {
            
            [self prepareNextViewController:segue.destinationViewController
                    afterSelectingIndexPath:indexPath];
            
        }
    }
    
}
@end
