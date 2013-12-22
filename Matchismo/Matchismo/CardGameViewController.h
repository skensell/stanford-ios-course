//
//  CardGameViewController.h
//  Matchismo
//
//  Created by Scott Kensell on 11/14/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"
#import "Grid.h"
#import "CardView.h"

@interface CardGameViewController : UIViewController


// game logic
@property (nonatomic) NSUInteger numberOfCardsToMatch;

// layout of card views
@property (nonatomic) CGFloat cardAspectRatio; // ABSTRACT
@property (nonatomic) NSUInteger minimumNumberOfCardsOnBoard; // ABSTRACT
@property (nonatomic) NSUInteger maximumNumberOfCardsOnBoard; // ABSTRACT
@property (nonatomic) BOOL prefersWideCards;
- (CardView *)createCardViewInFrame:(CGRect)frame fromCard:(Card *)card; // ABSTRACT

// deck specific
- (Deck *)createDeck; // abstract method


// I don't think this needs to be public
- (void)removeMatchedCards;


@end
