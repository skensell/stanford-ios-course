//
//  Animator.m
//  Matchismo
//
//  Created by Scott Kensell on 12/28/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "Animator.h"
#import "MatchedBehavior.h"
#import "CardView.h"

@interface Animator() <UIDynamicAnimatorDelegate>
@property (strong, nonatomic) PlayingAreaView *playingArea;

@property (strong, nonatomic) UIDynamicAnimator *matchedAnimator;
@property (strong, nonatomic) MatchedBehavior *matchedBehavior;

@property (strong, nonatomic) NSMutableArray *matchedCardsCompletionBlocks;
@end

@implementation Animator

#pragma mark - Initialization

- (instancetype)initWithPlayingArea:(PlayingAreaView *)playingArea {
    self = [super init];
    if (self) {
        _playingArea = playingArea;
    }
    return self;
}

#pragma mark - Properties

- (UIDynamicAnimator *)matchedAnimator {
    if (!_matchedAnimator) {
        _matchedAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.playingArea];
        _matchedAnimator.delegate = self;
    }
    return _matchedAnimator;
}

- (MatchedBehavior *)matchedBehavior {
    if (!_matchedBehavior) {
        _matchedBehavior = [[MatchedBehavior alloc] init];
        [self.matchedAnimator addBehavior:_matchedBehavior];
    }
    return _matchedBehavior;
}

#pragma mark - Normal animations

- (void)animateCardViewsIntoEmptySpaces:(NSArray *)cardViews {
    NSArray *centersOfEmptySpacesInGrid = [self.playingArea centersOfEmptySpacesInGrid];
    
    if ([centersOfEmptySpacesInGrid count] < [cardViews count]) {
        NSLog(@"ERROR: More cards to place on grid than empty spaces.");
        return;
    }
    
    int idx=0;
    for (CardView *cardView in cardViews) {
        CGPoint center = [centersOfEmptySpacesInGrid[idx] CGPointValue];
        
        cardView.transform = CGAffineTransformMakeRotation(M_PI);
        [UIView animateWithDuration:0.5 delay:0.04*idx options:0 animations:^{
            cardView.center = center;
            cardView.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL fin){
            if (fin) {
            }
        }];
        
        idx++;
    }
}

- (void)animateMatchedCardViewsOffScreen:(NSArray *)matchedCardViews completion:(CompletionBlock)completion {
    // bring to front and center then slide off bottom
    
    if (![matchedCardViews count]) return;
    
    // bring to front and center
    
    [matchedCardViews enumerateObjectsUsingBlock:^(CardView *cardView, NSUInteger idx, BOOL *stop) {
        [cardView removeFromSuperview];
        [self.playingArea addSubview:cardView]; // brings to front
    }];
    
    // bring to center
    AnimationBlock animation1 = ^{
        NSUInteger centerRowIndex = self.playingArea.rowCount/2;
        for (int i=0; i < [matchedCardViews count]; i++) {
            CardView *cardView = matchedCardViews[i];
            cardView.center = [self.playingArea centerOfCellAtRow:centerRowIndex inColumn:i];
            cardView.frame = [self.playingArea frameOfCellAtRow:centerRowIndex inColumn:i];
        }
    };
    // slide off bottom of screen
    AnimationBlock animation2 = ^{
        for (int i=0; i < [matchedCardViews count]; i++) {
            CardView *cardView = matchedCardViews[i];
            cardView.center = CGPointMake(cardView.center.x, cardView.center.y + self.playingArea.bounds.size.height);
        }
    };
    
    [UIView animateWithDuration:1.0
                     animations:animation1
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:1.0
                                          animations:animation2
                                          completion:completion];
                     }];
    
}

- (void)animateChosenCardViews:(NSArray *)chosenCardViews {
    // they pulsate together until unchosen
//    for (CardView *cardView in chosenCardViews){
//        cardView.alpha = 1.0;
//    }
//    
    AnimationBlock animation1 = ^{
        for (CardView *cardView in chosenCardViews){
            cardView.alpha = 0.75;
        }
    };
    
    // this ensures the alpha will be 1.0 when finished
    AnimationBlock animation2 = ^{
        for (CardView *cardView in chosenCardViews){
            cardView.alpha = 1.0;
        }
    };
    
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction |
     UIViewAnimationOptionCurveEaseIn
                     animations:animation1
                     completion:^(BOOL fin){
                         
                         [UIView animateWithDuration:0.25
                                               delay:0
                                             options:UIViewAnimationOptionAllowUserInteraction |
                          UIViewAnimationOptionCurveEaseOut |
                          UIViewAnimationOptionAutoreverse |
                          UIViewAnimationOptionRepeat
                                          animations:animation2
                                          completion:nil];
                         
                     }];
    
}

- (void)animateRedealGivenCardViews:(NSArray *)cardViews completion:(CompletionBlock)completion {
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        for (CardView *cardView in cardViews) {
            cardView.alpha = 0.0;
        }
    } completion:completion];
    
}

#pragma mark - UIDynamicAnimatorDelegate

//- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
//    if ([animator isEqual:self.matchedAnimator]) {
//        
//        while ([self.matchedCardsCompletionBlocks count]) {
//            CompletionBlock completion = [self.matchedCardsCompletionBlocks firstObject];
//            completion(YES);
//            [self.matchedCardsCompletionBlocks removeObjectAtIndex:0];
//        }
//
//    }
//}


@end
