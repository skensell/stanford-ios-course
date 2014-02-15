//
//  RegionsCDTVC.m
//  TopRegions
//
//  Created by Scott Kensell on 2/14/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "RegionsCDTVC.h"
#import "PhotosCDTVC.h"

@implementation RegionsCDTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupWithTitle:@"Top Regions"
 tableViewCellIdentifier:@"Region Cell"
segueIdentifierToNextViewController:@"List Photos"
classOfViewControllerAfterSegue:[PhotosCDTVC class]];
}

@end
