//
//  Animator.m
//  Matchismo
//
//  Created by Scott Kensell on 12/28/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "Animator.h"
#import "CardView.h"
#import "Common.h"

@interface Animator() <UIDynamicAnimatorDelegate>
@property (strong, nonatomic) PlayingAreaView *playingArea;

@property (strong, nonatomic) UIDynamicAnimator *pileCardsAnimator;
@property (strong, nonatomic) NSMutableArray *attachments; // of UIAttachmentBehavior
@property (nonatomic) CGPoint centerOfPile;

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
        
        // pile cards up when pinched
        UIPinchGestureRecognizer *pinchgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(playingAreaPinched:)];
        [playingArea addGestureRecognizer:pinchgr];
        
    }
    return self;
}

#pragma mark - Properties

- (UIDynamicAnimator *)pileCardsAnimator {
    if (!_pileCardsAnimator) {
        _pileCardsAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.playingArea];
        _pileCardsAnimator.delegate = self;
    }
    return _pileCardsAnimator;
}

- (NSMutableArray *)attachments {
    if (!_attachments) _attachments = [[NSMutableArray alloc] init];
    return _attachments;
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

- (void)animateCardViewsIntoPileAtPoint:(CGPoint)destination {
    NSArray *cardViews = self.playingArea.cardViewsInVisualOrder;
    if (![cardViews count]) return;
    
    [cardViews enumerateObjectsUsingBlock:^(CardView *cardView, NSUInteger idx, BOOL *stop) {
        cardView.transform = CGAffineTransformMakeRotation(M_PI); // flip upside down before rotating
    }];
    
    [UIView animateWithDuration:0.75 animations:^{
        for (int i = 0; i < [cardViews count]; i++) {
            CardView *cardView = (CardView *)cardViews[i];
            cardView.transform = CGAffineTransformMakeRotation(0 + ([cardViews count] - 1 - i)*.02);
            cardView.center = destination;
        }
    } completion:nil];
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
    if (self.isMovingCardViews) {
        DEBUG(@"Animation cancelled. Cards are being moved.");
        return;
    }
    self.isMovingCardViews = YES;
    
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
                                 cardView.transform = CGAffineTransformMakeRotation(0);
                             } completion:^(BOOL fin){
                                 [UIView animateWithDuration:0.2
                                                       delay:0
                                                     options:0
                                                  animations:^{
                                                      cardView.frame = [self.playingArea frameOfCardViewInCellAtRow:i inColumn:j];
                                                  } completion:^(BOOL fin){
                                                      self.isMovingCardViews = NO;
                                                  }];
                             }];
            
            idx++;
        }
    }
    
}

- (NSUInteger)spinCardViews:(NSArray *)cardViews {
    if (![cardViews count]) {
        return 0;
    }
    // I should return the totalDuration
    NSUInteger totalDuration = 1;
    
    AnimationBlock quarterSpin = ^{
        for (CardView *cardView in cardViews) {
            cardView.transform = CGAffineTransformRotate(cardView.transform, M_PI/2);
        }
    };
    
    // TODO - abstract this out to a generic spin method
    [UIView animateWithDuration:totalDuration/4.0
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:quarterSpin
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:totalDuration/4.0
                                               delay:0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:quarterSpin
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:totalDuration/4.0
                                                                    delay:0
                                                                  options:UIViewAnimationOptionCurveLinear
                                                               animations:quarterSpin
                                                               completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:totalDuration/4.0
                                                                                         delay:0
                                                                                       options:UIViewAnimationOptionCurveLinear
                                                                                    animations:quarterSpin
                                                                                    completion:nil];
                                                               }];
                                          }];
                     }];
    
    return totalDuration;
}



#pragma mark - Pile cards when pinched

- (void)playingAreaPinched:(UIPinchGestureRecognizer *)pinchgr {
    // animate cards under a transparent stack view (alpha .5 for testing)
    // this stack will have a pan gesture to move it and the cards via an attachment behavior
    // this stack will have a tap gesture to kill the attachment behavior and return cards to their original spot
    if (pinchgr.state == UIGestureRecognizerStateEnded) {
        if ([self.playingArea.subviews count] == 0 || self.isMovingCardViews) {
            DEBUG(@"Animation cancelled: cards currently being moved or no cards are in play.");
            return;
        }
        self.isMovingCardViews = YES; // don't set to NO until pile is tapped
        
        self.centerOfPile = [pinchgr locationInView:self.playingArea];
        [self animateCardViewsIntoPileAtPoint:self.centerOfPile];
        
        // create transparent view on top of cards called pile
        NSUInteger w = self.playingArea.cellSize.width;
        NSUInteger h = self.playingArea.cellSize.height;
        UIView *pile = [[UIView alloc] initWithFrame:CGRectMake(self.centerOfPile.x - w/2, self.centerOfPile.y - h/2, w, h)];
        pile.backgroundColor = [UIColor clearColor];
        
        UIPanGestureRecognizer *pangr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pilePanned:)];
        UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pileTapped:)];
        [pile addGestureRecognizer:pangr];
        [pile addGestureRecognizer:tapgr];
        
        [self.playingArea addSubview:pile];
        
    }
}

- (void)pilePanned:(UIPanGestureRecognizer *)pangr {
    // moves the pile around
    
    CGPoint gesturePoint = [pangr locationInView:self.playingArea];
    if (pangr.state == UIGestureRecognizerStateBegan) {
        // attach cardViews and pile to currently touched point
        
        for (UIView *subview in self.playingArea.subviews){ // iterates over cardViews and pileView
            UIAttachmentBehavior *ab = [[UIAttachmentBehavior alloc] initWithItem:subview attachedToAnchor:gesturePoint];
            
            [self.pileCardsAnimator addBehavior:ab];
            [self.attachments addObject:ab];
        }
        
    } else if (pangr.state == UIGestureRecognizerStateChanged) {
        // update the centers of cards and pile to the currently touched point
        
        for (UIAttachmentBehavior *ab in self.attachments) {
            ab.length = 0;
            ab.anchorPoint = gesturePoint;
        }
        
    } else if (pangr.state == UIGestureRecognizerStateEnded) {
        // remove attachment behavior from animator
        
        for (UIAttachmentBehavior *ab in self.attachments) {
            [self.pileCardsAnimator removeBehavior:ab];
        }
        [self.attachments removeAllObjects];
    }
}

- (void)pileTapped:(UITapGestureRecognizer *)tapgr {
    // set isMovingCardViews back to NO
    self.isMovingCardViews = NO;
    [self removeThePileView];
    
    // give the cards some rotation so that we can use the realignAndScale method with a little extra flare.
    [self.playingArea.subviews enumerateObjectsUsingBlock:^(CardView *cardView, NSUInteger idx, BOOL *stop) {
        cardView.transform = CGAffineTransformMakeRotation(M_PI);
    }];
    [self realignAndScaleCardViewsToGridCells:self.playingArea.subviews];
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

- (NSArray *)cardViewsInPlayingArea {
    // weeds out the non CardViews that are subviews
    NSMutableArray *cardViews = [[NSMutableArray alloc] init];
    for (UIView *subview in self.playingArea.subviews) {
        if ([subview isKindOfClass:[CardView class]]){
            [cardViews addObject:subview];
        }
    }
    return cardViews;
}

- (void)removeThePileView {
    for (int i=0; i < [self.playingArea.subviews count]; i++) {
        UIView *subview = self.playingArea.subviews[i];
        if (![subview isKindOfClass:[CardView class]]) {
            [subview removeFromSuperview];
            break;
        }
    }
}

#pragma mark - UIDynamicAnimatorDelegate

// Not used.


@end
