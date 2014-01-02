//
//  StickToGridBehavior.h
//  Matchismo
//
//  Created by Scott Kensell on 12/30/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StickToGridBehavior : UIDynamicBehavior

- (void)addItem:(id <UIDynamicItem>)item;
- (void)removeItem:(id <UIDynamicItem>)item;

@end
