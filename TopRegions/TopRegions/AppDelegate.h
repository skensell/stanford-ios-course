//
//  AppDelegate.h
//  TopRegions
//
//  Created by Scott Kensell on 2/14/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Database.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, DatabaseDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
