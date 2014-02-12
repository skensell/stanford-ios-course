//
//  CommonTableViewController.h
//  flickr_places
//
//  Created by Scott Kensell on 2/3/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//
//  This is an abstract class providing simpler way of creating the TableViewControllers.

#import <UIKit/UIKit.h>
#import "FlickrFetcher.h"
#import "Common.h"

@protocol CommonTableViewControllerProtocol <NSObject>
// methods to be implemented by subclasses
@required
- (IBAction)fetchFlickrData;
// you only need to override these methods instead of TableViewDataSource cellAtIndexPath
- (NSString *)titleForCellAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)subtitleForCellAtIndexPath:(NSIndexPath *)indexPath;
// explain what needs to be done when seguing
- (void)prepareNextViewController:(UIViewController *)vc afterSelectingIndexPath:(NSIndexPath *)indexPath;
@optional
// the property list data from flickr is stored here
// you may want to modify it a little before table reload
@property (nonatomic, strong, readonly) NSArray *fetchedDataFromFlickr;
- (void)prepareFetchedDataForTableReload;
@end


@interface CommonTableViewController : UITableViewController <CommonTableViewControllerProtocol>
// methods to be called by subclasses
- (IBAction)fetchFlickrData;

// subclasses must call once in ViewDidLoad
- (void)setupWithTitle:(NSString *)title
tableViewCellIdentifier:(NSString *)tableViewCellIdentifier
segueIdentifierToNextViewController:(NSString *)segueIdentifierToNextViewController
classOfViewControllerAfterSegue:(Class)classOfViewControllerAfterSegue;

// asynchronously fetches flickr data, call when seguing
- (IBAction)fetchFlickrDataAtURL:(NSURL *)url keyPath:(NSString *)keyPath;

@end
