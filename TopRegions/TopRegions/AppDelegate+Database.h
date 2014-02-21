//
//  AppDelegate+Database.h
//  TopRegions
//
//  Created by Scott Kensell on 2/14/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "AppDelegate.h"

// To use this category, call openManagedDocument after app launch.
// It will set the private property databaseContext.
// You will likely want to notify other classes of the availability of the databaseContext, so override the setter.

@interface AppDelegate (Database)
- (void)openManagedDocument; // call immediately after app launch
@end