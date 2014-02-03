//
//  FlickrPhotoTableViewController.m
//  flickr_places
//
//  Created by Scott Kensell on 1/30/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "FlickrPhotoTableViewController.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"

@interface FlickrPhotoTableViewController ()

@property (nonatomic, strong) NSDictionary *photos; // { photo_id : [ title, description] }

@end

@implementation FlickrPhotoTableViewController

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

- (void)setPlaceID:(NSString *)placeID {
    _placeID = placeID;
    [self fetchPhotos];
}

#pragma mark - Private

- (void)fetchPhotos {
    [self fetchFlickrDataAtURL:[FlickrFetcher URLforPhotosInPlace:self.placeID
                                                       maxResults:50]
                       keyPath:FLICKR_RESULTS_PHOTOS];
}

#pragma mark - Inherited

- (void)prepareFetchedDataForTableReload {
    // self.fetchedDataFromFlickr is available to manipulate
    // take its data, curate, and store in ivar
    //TODO: finish this.
    for (NSDictionary *photoDict in self.fetchedDataFromFlickr) {
        
    }
}

#pragma mark - Private

- (void)prepareImageViewController:(ImageViewController *)fptvc
              toShowPhotoAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.countries[self.sortedCountryNames[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Cell";
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

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([sender isKindOfClass:[UITableViewCell class]]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
//        if (indexPath && [segue.identifier isEqualToString:@"List Photos"] &&
//            [segue.destinationViewController isKindOfClass: [FlickrPhotoTableViewController class]]) {
//            
//            [self preparePhotoTableViewController:segue.destinationViewController
//                        toShowPhotosFromIndexPath:indexPath];
//            
//        }
//    }
//    
//}

@end
