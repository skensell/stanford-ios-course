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

@end

@implementation FlickrPhotoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupWithTitle:self.placeName
 tableViewCellIdentifier:@"Flickr Photo Cell"
segueIdentifierToNextViewController:@"Show Photo"
classOfViewControllerAfterSegue:[ImageViewController class]];
}

- (void)setPlaceID:(NSString *)placeID {
    _placeID = placeID;
    [self fetchPhotos];
}

- (NSString *)placeName {
    if (!_placeName) {
        _placeName = @"Unknown";
    }
    return _placeName;
}

#pragma mark - CommonTVC Required

- (NSString *)titleForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.fetchedDataFromFlickr[indexPath.row][FLICKR_PHOTO_TITLE];
    if (!title) {
        NSString *description = [self subtitleForCellAtIndexPath:indexPath];
        if (description && ![description isEqualToString:@""]) {
            return description;
        } else {
            return @"Unknown";
        }
    }
    return title;
}

- (NSString *)subtitleForCellAtIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedDataFromFlickr valueForKeyPath:FLICKR_PHOTO_DESCRIPTION][indexPath.row];
}

- (void)prepareNextViewController:(UIViewController *)vc afterSelectingIndexPath:(NSIndexPath *)indexPath {
    if ([vc isKindOfClass:[ImageViewController class]]) {
        ImageViewController *ivc = (ImageViewController *)vc;
        ivc.imageURL = [FlickrFetcher URLforPhoto:self.fetchedDataFromFlickr[indexPath.row] format:FlickrPhotoFormatLarge];
        ivc.title = [[[self.tableView cellForRowAtIndexPath:indexPath] textLabel] text]; // maybe I SHOULD check if nav controller
        [self addPhotoToHistory:indexPath];
    }
}

- (IBAction)fetchFlickrData {
    [self fetchPhotos];
}

#pragma mark - CommonTVC Optional



#pragma mark - Private

- (void)fetchPhotos {
    [self fetchFlickrDataAtURL:[FlickrFetcher URLforPhotosInPlace:self.placeID
                                                       maxResults:50]
                       keyPath:FLICKR_RESULTS_PHOTOS];
}

// TODO: refactor this out to DefaultsManager
- (void)addPhotoToHistory:(NSIndexPath *)indexPath {
    NSDictionary *photo = self.fetchedDataFromFlickr[indexPath.row];
    NSMutableArray *history = [[[NSUserDefaults standardUserDefaults] objectForKey:kHistoryKey] mutableCopy];
    history = history ? history : [[NSMutableArray alloc] init];
    for (int i=0; i < history.count; i++) {
        if (history[i][@"id"] == photo[@"id"]) {
            [history removeObjectAtIndex:i];
            break;
        }
    }
    if (history.count == 20) {
        [history removeObjectAtIndex:19];
    }
    [history insertObject:photo atIndex:0];
    
    [[NSUserDefaults standardUserDefaults] setObject:history forKey:kHistoryKey];
}

#pragma mark - TableView data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedDataFromFlickr.count ? self.fetchedDataFromFlickr.count : 0;
}

#pragma mark - UITableViewDelegate

// when a row is selected and we are in a UISplitViewController,
//   this updates the Detail ImageViewController (instead of segueing to it)
// knows how to find an ImageViewController inside a UINavigationController in the Detail too
// otherwise, this does nothing (because detail will be nil and not "isKindOfClass:" anything)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the Detail view controller in our UISplitViewController (nil if not in one)
    id detail = self.splitViewController.viewControllers[1]; // 0 is master, 1 is detail
    // if Detail is a UINavigationController, look at its root view controller to find it
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    // is the Detail is an ImageViewController?
    if ([detail isKindOfClass:[ImageViewController class]]) {
        // yes ... we know how to update that!
        [self prepareNextViewController:detail afterSelectingIndexPath:indexPath];
    }
}

@end
