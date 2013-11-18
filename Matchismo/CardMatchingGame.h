//
//  CardMatchingGame.h
//  Matchismo
//
//  Created by Scott Kensell on 11/17/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deck.h"

@interface CardMatchingGame : NSObject


- (instancetype)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck;
// designated initializer
- (instancetype)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck withNumberOfCardsToMatch:(NSUInteger)numberToMatch;

- (void)chooseCardAtIndex:(NSUInteger)index;
- (Card *)cardAtIndex:(NSUInteger)index;

@property (nonatomic, readonly) NSInteger score; // don't want there to be any public setter, but privately this will be read-write

@end
