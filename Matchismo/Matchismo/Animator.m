//
//  Animator.m
//  Matchismo
//
//  Created by Scott Kensell on 12/28/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "Animator.h"
#import "CardView.h"
#import "StickToGridBehavior.h"
#import "Common.h"

@interface Animator() <UIDynamicAnimatorDelegate>
@property (strong, nonatomic) PlayingAreaView *playingArea;

@property (strong, nonatomic) UIDynamicAnimator *stickToGridAnimator;
@property (strong, nonatomic) StickToGridBehavior *stickToGridBehavior;

@property (nonatomic) BOOL allowsFlippingOfCards;
@property (nonatomic, readwrite) BOOL isMovingCardViews;
@end

@implementation Animator

#pragma mark - Initialization

- (instancetype)initWithPlayingArea:(PlayingAreaView *)playingArea allowsFlippingOfCards:(BOOL)allowsFlippingOfCards {
    self = [super init];
    if (self) {
        _playingArea = playingArea;
        _isMovingCardViews = NO;
        _allowsFlippingOfCards = allowsFlippingOfCards;
    }
    return self;
}

#pragma mark - Properties

- (UIDynamicAnimator *)stickToGridAnimator {
    if (!_stickToGridAnimator) {
        _stickToGridAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.playingArea];
        _stickToGridAnimator.delegate = self;
    }
    return _stickToGridAnimator;
}

- (StickToGridBehavior *)stickToGridBehavior {
    if (!_stickToGridBehavior) {
        _stickToGridBehavior = [[StickToGridBehavior alloc] init];
        [self.stickToGridAnimator addBehavior:_stickToGridBehavior];
    }
    return _stickToGridBehavior;
}

#pragma mark - Normal animations

- (void)animateCardViewsIntoEmptySpaces:(NSArray *)cardViews {
//    [self waitToMoveCardViews];
    NSArray *centersOfEmptySpacesInGrid = [self.playingArea centersOfEmptySpacesInGrid];
    
    if ([centersOfEmptySpacesInGrid count] < [cardViews count]) {
        ERROR(@"More cards to place on grid than empty spaces.");
        ERROR(@"Only %d empty spaces in grid and %d cardViews to place.", [centersOfEmptySpacesInGrid count], [cardViews count]);
        return;
    }
    self.isMovingCardViews = YES;
    
    __weak Animator *weakSelf = self;
    CompletionBlock completion;
    int idx = 0;
    BOOL isLast = NO;
    for (CardView *cardView in cardViews) {
        
        if (idx == [cardViews count] - 1) {
            isLast = YES;
            completion = ^(BOOL finished) {
                weakSelf.isMovingCardViews = NO;
            };
        }
        
        CGPoint center = [centersOfEmptySpacesInGrid[idx] CGPointValue];
        cardView.transform = CGAffineTransformMakeRotation(M_PI);
        [UIView animateWithDuration:0.5 delay:0.04*idx options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            cardView.center = center;
            cardView.transform = CGAffineTransformMakeRotation(0);
        } completion:(isLast ? completion : nil)];
        
        idx++;
    }
}

- (void)animateMatchedCardViewsOffScreen:(NSArray *)matchedCardViews completion:(CompletionBlock)completion {
    // bring to front and center then slide off bottom
//    TODO: Make this wait function actually work or implement a queue.
//    (Multithreading? I think I need a different delegate)
//    [self waitToMoveCardViews];
    if (![matchedCardViews count]) return;
    self.isMovingCardViews = YES;
    
    // bring to front and center
    
    [matchedCardViews enumerateObjectsUsingBlock:^(CardView *cardView, NSUInteger idx, BOOL *stop) {
        [cardView removeFromSuperview];
        [self.playingArea addSubview:cardView]; // brings to front
    }];
    
    __weak Animator *weakSelf = self;
    // bring to center
    AnimationBlock animation1 = ^{
        NSUInteger centerRowIndex = weakSelf.playingArea.rowCount/2;
        for (int i=0; i < [matchedCardViews count]; i++) {
            CardView *cardView = matchedCardViews[i];
            cardView.center = [weakSelf.playingArea centerOfCellAtRow:centerRowIndex inColumn:i];
            cardView.frame = [weakSelf.playingArea frameOfCellAtRow:centerRowIndex inColumn:i];
        }
    };
    // slide off bottom of screen
    AnimationBlock animation2 = ^{
        for (int i=0; i < [matchedCardViews count]; i++) {
            CardView *cardView = matchedCardViews[i];
            cardView.center = CGPointMake(cardView.center.x, weakSelf.playingArea.superview.bounds.size.height + weakSelf.playingArea.cellSize.height);
        }
    };
    
    CompletionBlock totalCompletion = ^(BOOL finished) {
        weakSelf.isMovingCardViews = NO;
        completion(finished);
    };
    
    [UIView animateWithDuration:1.0
                     animations:animation1
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:1.0
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:animation2
                                          completion:totalCompletion];
                     }];
    
}

- (void)animateChosenCardViews:(NSArray *)chosenCardViews {
    // This method is only meant to distinguish cards when flipping is not an option.
    // Typically a card's flip animation is animated by the cardView itself when it becomes chosen.
    if (self.allowsFlippingOfCards) return;
    
    
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
    // Just fades the cards off screen.
    __weak Animator *weakSelf = self;
    CompletionBlock totalCompletion = ^(BOOL finished) {
        completion(finished);
        weakSelf.isMovingCardViews = NO;
    };
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:0
                     animations:^{
                         for (CardView *cardView in cardViews) {
                             cardView.alpha = 0.0;
                         }
                     }
                     completion:totalCompletion];
    
}

- (void)fillHolesInGridWithRecentCardsDealt {
    // get the X indices of holes
    // get the last X cardViews
    // animate those cardViews to empty spaces by calling above method
    NSUInteger numberOfHolesInGrid = [self.playingArea.indicesOfHolesInGrid count];
    NSArray *cardviews = self.playingArea.cardViewsInVisualOrder;
    if (numberOfHolesInGrid > [cardviews count]) {
        ERROR(@"Too many holes to fill.");
        return;
    }
    NSArray *bottomCardViews = [cardviews subarrayWithRange:NSMakeRange([cardviews count] - numberOfHolesInGrid, numberOfHolesInGrid)];
    
    [self animateCardViewsIntoEmptySpaces:bottomCardViews];
}

- (void)realignAndScaleCardViewsToGridCells:(NSArray *)cardViews {
    // move and scale each cardView to the top of the grid
    
    int idx = 0;
    for (int i = 0; i < self.playingArea.rowCount; i++) {
        for (int j=0; j < self.playingArea.columnCount; j++) {
            if (idx >= [cardViews count]) return;
            
            CardView *cardView = cardViews[idx];
            [UIView animateWithDuration:0.5
                                  delay:0
                                options:0
                             animations:^{
                                 cardView.center = [self.playingArea centerOfCellAtRow:i inColumn:j];
                                 cardView.frame = [self.playingArea frameOfCardViewInCellAtRow:i inColumn:j];
                             } completion:nil];
            
            idx++;
        }
    }
    
}

#pragma mark - Private

- (void)waitToMoveCardViews {
    float timeWaiting = 0;
    float delta = 0.1;
    int limit = 2;
    
    while (self.isMovingCardViews && timeWaiting < limit) {
        [NSThread sleepForTimeInterval:delta];
        timeWaiting += delta;
    }
    
    if (self.isMovingCardViews) {
        ERROR(@"Waited too long to move card views.");
    } else {
        self.isMovingCardViews = YES;
    }
}

#pragma mark - UIDynamicAnimatorDelegate

//- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
//    if ([animator isEqual:self.stickToGridAnimator]) {
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
