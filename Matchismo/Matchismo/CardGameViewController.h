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


// any subclass should call this setup method once in viewDidLoad

- (void)setupGameWithNumberOfCardsToMatch:(NSUInteger)numberOfCardsToMatch
                          CardAspectRatio:(CGFloat)aspectRatio // width/height of card
                         prefersWideCards:(BOOL)prefersWideCards // if an aspect ratio >= 1 is preferred
              minimumNumberOfCardsOnBoard:(NSUInteger)minimumNumberOfCardsOnBoard // this many cards will be dealt at start and always kept on board
              maximumNumberOfCardsOnBoard:(NSUInteger)maximumNumberOfCardsOnBoard // enough space will be left for this many cards
                    allowsFlippingOfCards:(BOOL)allowsFlippingOfCards // if NO, then chosen cards are animated by blinking
  numberToDealWhenDealMoreButtonIsPressed:(NSUInteger)numberToDealWhenDealMoreButtonIsPressed; // ctrl-drag to touchDealMoreButton if using this

// protected
- (CardView *)createCardViewInFrame:(CGRect)frame fromCard:(Card *)card; // ABSTRACT
- (Deck *)createDeck; // ABSTRACT

@end
