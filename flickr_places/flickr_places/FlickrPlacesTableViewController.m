//
//  FlickrPlacesTableViewController.m
//  flickr_places
//
//  Created by Scott Kensell on 1/29/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "FlickrPlacesTableViewController.h"
#import "FlickrFetcher.h"

@interface FlickrPlacesTableViewController ()
@property (nonatomic, strong) NSDictionary *countries; // each entry is @[city, region, place_id]

@end

@implementation FlickrPlacesTableViewController

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
    
    [self fetchFlickrDataAtURL:[FlickrFetcher URLforTopPlaces]
                       keyPath:FLICKR_RESULTS_PLACES];
    

}

#pragma mark - Inherited

- (void)prepareFetchedDataForTableReload {
    // self.fetchedDataFromFlickr is available to manipulate
    
    NSMutableDictionary *countries = [[NSMutableDictionary alloc] init];
    for (NSDictionary *placeDict in self.fetchedDataFromFlickr) {
        NSArray *content = [placeDict[FLICKR_PLACE_NAME] componentsSeparatedByString:@", "];
        NSString *region;
        if ([content count] < 2) {
            continue;
        } else if ([content count] == 2) {
            region = @"";
        } else {
            region = [[content subarrayWithRange:NSMakeRange(1, [content count] - 2)] componentsJoinedByString:@", "];
        }
        NSString *country = [content lastObject];
        NSString *city = [content firstObject];
        NSString *placeId = [placeDict[FLICKR_PLACE_ID] description];
        
        NSArray *countrySoFar = countries[country];
        if (!countrySoFar) {
            countrySoFar = @[];
        }
        
        countries[country] = [countrySoFar arrayByAddingObject:@[city, region, placeId]];
    }
    
    self.countries = countries;
    DEBUG(@"%@", self.countries);
}

// Next step: Populate the Table View with the countries dict.

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}



/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
