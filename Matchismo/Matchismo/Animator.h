//
//  Animator.h
//  Matchismo
//
//  Created by Scott Kensell on 12/28/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayingAreaView.h"

@interface Animator : NSObject

- (instancetype)initWithPlayingArea:(PlayingAreaView *)playingArea;

- (void)animateCardViewsIntoEmptySpaces:(NSArray *)cardViews;
- (void)animateMatchedCardViewsOffScreen:(NSArray *)matchedCardViews;

@end
