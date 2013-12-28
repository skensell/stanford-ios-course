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
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) MatchedBehavior *matchedBehavior;
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

- (UIDynamicAnimator *)animator {
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.playingArea];
        _animator.delegate = self;
    }
    return _animator;
}

- (MatchedBehavior *)matchedBehavior {
    if (!_matchedBehavior) {
        _matchedBehavior = [[MatchedBehavior alloc] init];
        [self.animator addBehavior:_matchedBehavior];
    }
    return _matchedBehavior;
}

#pragma mark - DynamicAnimator animations

- (void)animateMatchedCardViewsOffScreen:(NSArray *)matchedCardViews {
    if (![matchedCardViews count]) return;
    
    [matchedCardViews enumerateObjectsUsingBlock:^(CardView *cardView, NSUInteger idx, BOOL *stop) {
        [self.matchedBehavior addItem:cardView];
    }];
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

@end
