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

- (void)prepareNextViewController:(UIViewController *)vc afterSelectingIndexPath:(NSIndexPath *)indexPath segueIdentifier:(NSString *)segueIdentifier {
    // abstract method
}

#pragma mark - Navigation

// in splitViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailvc = [self.splitViewController.viewControllers lastObject];
    if ([detailvc isKindOfClass:[UINavigationController class]]) {
        detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
        [self prepareNextViewController:detailvc
                afterSelectingIndexPath:indexPath
                        segueIdentifier:nil];
    }
}

// normal segue in navigationController
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath && [segue.identifier isEqualToString:[self segueIdentifierToNextViewController]] &&
            [segue.destinationViewController isKindOfClass:[self classOfViewControllerAfterSegue]]) {
            
            [self prepareNextViewController:segue.destinationViewController
                    afterSelectingIndexPath:indexPath
                            segueIdentifier:segue.identifier];
            
        }
    }
    
}
@end
