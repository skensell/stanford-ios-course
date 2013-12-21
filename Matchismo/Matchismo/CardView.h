//
//  CardView.h
//  Matchismo
//
//  Created by Scott Kensell on 12/20/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardView : UIView

@property (nonatomic, getter = isChosen) BOOL chosen;
@property (nonatomic, getter = isMatched) BOOL matched;

// abstract, protected for subclasses
- (void)animateChoose;
- (void)animateUnchoose;

@end
