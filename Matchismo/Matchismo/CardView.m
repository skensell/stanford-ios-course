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

- (void)setMatched:(BOOL)matched {
    _matched = matched;
    if (matched) {
        for (UIGestureRecognizer *gr in self.gestureRecognizers) {
            [self removeGestureRecognizer:gr];
        }
        
        [UIView animateWithDuration:3.0 delay:0 options:0 animations:^{
            self.transform = CGAffineTransformMakeTranslation(500, 0);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

- (void)setChosen:(BOOL)chosen {
    if (_chosen != chosen) {
        if (chosen) {
            [self animateChoose];
        } else {
            [self animateUnchoose];
        }
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
