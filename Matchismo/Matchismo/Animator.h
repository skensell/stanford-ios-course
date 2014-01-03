//
//  Animator.h
//  Matchismo
//
//  Created by Scott Kensell on 12/28/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayingAreaView.h"

typedef void (^CompletionBlock)(BOOL finished);
typedef void (^AnimationBlock)();

@interface Animator : NSObject

- (instancetype)initWithPlayingArea:(PlayingAreaView *)playingArea allowsFlippingOfCards:(BOOL)allowsFlippingOfCards;

- (void)animateCardViewsIntoEmptySpaces:(NSArray *)cardViews;
- (void)animateMatchedCardViewsOffScreen:(NSArray *)matchedCardViews completion:(CompletionBlock)completion;
- (void)animateChosenCardViews:(NSArray *)chosenCardViews;
- (void)animateRedealGivenCardViews:(NSArray *)cardViews completion:(CompletionBlock)completion;

- (void)realignAndScaleCardViewsToGridCells:(NSArray *)cardViews;
- (void)fillHolesInGridWithRecentCardsDealt;

@property (nonatomic, readonly) BOOL isMovingCardViews;
@end
