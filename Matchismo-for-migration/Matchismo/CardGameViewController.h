//
//  CardGameViewController.h
//  Matchismo
//
//  Created by Scott Kensell on 11/14/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"

@interface CardGameViewController : UIViewController


// protected for subclasses
@property (nonatomic) NSUInteger numberOfCardsToMatch;
@property (nonatomic) NSInteger scoreDelta;
@property (nonatomic) NSMutableArray *currentlyPickedCards;

- (Deck *)createDeck; // abstract method
- (NSAttributedString *)forStatusDepictCard:(Card *)aCard; // abstract method
- (void)updateStatusWithScoreDelta:(NSInteger)scoreDelta; // abstract method
- (void)updateButton:(UIButton *)cardButton
             forCard:(Card *)card;

@end
