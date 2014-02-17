//
//  AppDelegate+Database.h
//  TopRegions
//
//  Created by Scott Kensell on 2/14/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "AppDelegate.h"

// To use this category, the AppDelegate must implement the DatabaseDelegate protocol declared in Database.h.
// In particular, the database is available when self.databaseContext is set.

@interface AppDelegate (Database)

// call immediately after app launch
- (void)openManagedDocument;

@end
