//
//  CommonTableViewController.m
//  flickr_places
//
//  Created by Scott Kensell on 2/3/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "CommonCDTVC.h"

@interface CommonCDTVC ()
@property (nonatomic, strong) NSString *tableViewCellIdentifier;
@property (nonatomic, strong) NSString *segueIdentifierToNextViewController;
@property (nonatomic, strong) Class classOfViewControllerAfterSegue;
@end

@implementation CommonCDTVC

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

- (void)prepareNextViewController:(UIViewController *)vc afterSelectingIndexPath:(NSIndexPath *)indexPath {
    // abstract method
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
