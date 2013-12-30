//
//  CardView.m
//  Matchismo
//
//  Created by Scott Kensell on 12/20/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "CardView.h"

@implementation CardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _chosen = NO;
        _matched = NO;
    }
    return self;
}

- (void)setChosen:(BOOL)chosen {
    if (_chosen != chosen) {
        if (chosen) {
            [self animateChoose];
        } else {
            if (!self.matched){ // we don't want to flip matched cards back over
                [self animateUnchoose];
            }
        }
    } else if (self.matched) {
        // the last chosen card which matches actually is never "chosen" in the game
        [self animateChoose];
    }
    _chosen = chosen;
    [self setNeedsDisplay];
}

- (void)animateChoose {
    // abstract method
}

- (void)animateUnchoose {
    // abstract method
}

- (void)removeAllGestureRecognizers {
    int numberOfGRs = [self.gestureRecognizers count];
    for (int i = 0; i < numberOfGRs; i++) {
        [self removeGestureRecognizer:self.gestureRecognizers[i]];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
