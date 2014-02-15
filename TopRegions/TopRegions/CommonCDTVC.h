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
#import "CoreDataTableViewController.h"

@protocol CommonCDTVC <NSObject>
// methods to be IMPLEMENTED by subclasses
// explain what needs to be done when seguing
- (void)prepareNextViewController:(UIViewController *)vc afterSelectingIndexPath:(NSIndexPath *)indexPath;
@end


@interface CommonCDTVC : CoreDataTableViewController <CommonCDTVC>
// methods to be CALLED by subclasses
- (void)setupWithTitle:(NSString *)title
tableViewCellIdentifier:(NSString *)tableViewCellIdentifier
segueIdentifierToNextViewController:(NSString *)segueIdentifierToNextViewController
classOfViewControllerAfterSegue:(Class)classOfViewControllerAfterSegue;

@end
