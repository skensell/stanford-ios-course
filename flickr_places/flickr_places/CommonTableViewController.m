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
@end

@implementation CommonTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)setFetchedDataFromFlickr:(NSArray *)fetchedDataFromFlickr {
    _fetchedDataFromFlickr = fetchedDataFromFlickr;
    [self prepareFetchedDataForTableReload];
    [self.tableView reloadData];
}

#pragma mark - Protected

// TODO: Hook up to pull to refresh
- (IBAction)fetchFlickrDataAtURL:(NSURL *)url keyPath:(NSString *)keyPath {
    [self.refreshControl beginRefreshing]; // start the spinner

    // create a (non-main) queue to do fetch on
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    // put a block to do the fetch onto that queue
    dispatch_async(fetchQ, ^{
        // fetch the JSON data from Flickr
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                            options:0
                                                                              error:NULL];
        //DEBUG(@"Raw result from query to %@:\n%@", [url description], propertyListResults);
        NSArray *fetched = [propertyListResults valueForKeyPath:keyPath];
        DEBUG(@"Result as array:\n%@", fetched);
        
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


#pragma mark - Table view data source
// OVERRIDE THESE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Place Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}




#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        // find out which row in which section we're seguing from
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Display Photo"]) {
//                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
//                    [self prepareImageViewController:segue.destinationViewController
//                                      toDisplayPhoto:self.photos[indexPath.row]];
//                }
            } else if ([segue.identifier isEqualToString:@"List Photos"]) {
                if ([segue.destinationViewController isKindOfClass:[CommonTableViewController class]]) {
                }
            }
        }
    }
}



@end
