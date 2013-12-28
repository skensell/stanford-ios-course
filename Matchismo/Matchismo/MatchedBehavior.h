//
//  MatchedBehavior.h
//  Matchismo
//
//  Created by Scott Kensell on 12/27/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchedBehavior : UIDynamicBehavior

- (void)addItem:(id <UIDynamicItem>)item;
- (void)removeItem:(id <UIDynamicItem>)item;

@end
