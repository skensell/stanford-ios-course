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
    if (self.isChosen != chosen) {
        if (chosen) {
            [self animateChoose];
        } else {
            [self animateUnchoose];
        }
    }
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
