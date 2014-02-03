//
//  FlickrPlacesTableViewController.m
//  flickr_places
//
//  Created by Scott Kensell on 1/29/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "FlickrPlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "FlickrPhotoTableViewController.h"

@interface FlickrPlacesTableViewController ()
@property (nonatomic, strong) NSDictionary *countries; // each entry is sorted array @[ @[city, region, place_id], ... ]
@property (nonatomic, strong) NSArray *sortedCountryNames; // used to order the keys of countries
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
    // take its data, curate, and store in ivar
    
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
        
        countries[country] = [[countrySoFar arrayByAddingObject:@[city, region, placeId]] sortedArrayUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
            return [obj1[0] localizedCaseInsensitiveCompare:obj2[0]];
        }];
    }
    
    self.countries = countries;
    self.sortedCountryNames = [[countries allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    DEBUG(@"%@", self.sortedCountryNames);
}

#pragma mark - Private

- (void)preparePhotoTableViewController:(FlickrPhotoTableViewController *)fptvc
              toShowPhotosFromIndexPath:(NSIndexPath *)indexPath {
    NSString *country = self.sortedCountryNames[indexPath.section];
    fptvc.placeID = self.countries[country][indexPath.row][2];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sortedCountryNames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.countries[self.sortedCountryNames[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Place Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *country = self.sortedCountryNames[indexPath.section];
    NSArray *placeInfo = self.countries[country][indexPath.row];
    NSString *city = placeInfo[0];
    NSString *region = placeInfo[1];
    
    cell.textLabel.text = city;
    cell.detailTextLabel.text = region;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sortedCountryNames[section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *firstLetters = [NSMutableArray new];
    for (NSString *country in self.sortedCountryNames) {
        [firstLetters addObject:[country substringToIndex:1]];
    }
    return firstLetters;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath && [segue.identifier isEqualToString:@"List Photos"] &&
            [segue.destinationViewController isKindOfClass: [FlickrPhotoTableViewController class]]) {
            
            [self preparePhotoTableViewController:segue.destinationViewController
                        toShowPhotosFromIndexPath:indexPath];
            
        }
    }
    
}



@end
