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


// subclass should call once in viewDidLoad
- (void)setupGameWithNumberOfCardsToMatch:(NSUInteger)numberOfCardsToMatch
                          CardAspectRatio:(CGFloat)aspectRatio
                         prefersWideCards:(BOOL)prefersWideCards
              minimumNumberOfCardsOnBoard:(NSUInteger)minimumNumberOfCardsOnBoard
              maximumNumberOfCardsOnBoard:(NSUInteger)maximumNumberOfCardsOnBoard;

// protected
- (CardView *)createCardViewInFrame:(CGRect)frame fromCard:(Card *)card; // ABSTRACT
- (Deck *)createDeck; // ABSTRACT

@end
