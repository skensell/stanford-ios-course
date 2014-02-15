//
//  FlickrPhotoTableViewController.m
//  flickr_places
//
//  Created by Scott Kensell on 1/30/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "PhotosCDTVC.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"

@interface PhotosCDTVC ()

@end

@implementation PhotosCDTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupWithTitle:self.placeName
 tableViewCellIdentifier:@"Photo Cell"
segueIdentifierToNextViewController:@"Show Photo"
classOfViewControllerAfterSegue:[ImageViewController class]];
}

- (NSString *)placeName {
    if (!_placeName) {
        _placeName = @"Unknown";
    }
    return _placeName;
}

#pragma mark - CommonTVC Required

- (void)prepareNextViewController:(UIViewController *)vc afterSelectingIndexPath:(NSIndexPath *)indexPath {
    if ([vc isKindOfClass:[ImageViewController class]]) {
        ImageViewController *ivc = (ImageViewController *)vc;
        //ivc.imageURL = [FlickrFetcher URLforPhoto:self.fetchedDataFromFlickr[indexPath.row] format:FlickrPhotoFormatLarge];
        ivc.title = [[[self.tableView cellForRowAtIndexPath:indexPath] textLabel] text]; // maybe I SHOULD check if nav controller
        [self addPhotoToHistory:indexPath];
    }
}


#pragma mark - CommonTVC Optional



#pragma mark - Private

// TODO: refactor this out to DefaultsManager
- (void)addPhotoToHistory:(NSIndexPath *)indexPath {

}

#pragma mark - TableView data source


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
