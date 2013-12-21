//
//  Deck.h
//  Matchismo
//
//  Created by Scott Kensell on 11/16/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface Deck : NSObject

@property (nonatomic, getter = isEmpty) BOOL empty;
@property (nonatomic, readonly) NSUInteger numberOfCards;

- (void)addCard:(Card *)card atTop:(BOOL)atTop;
- (void)addCard:(Card *)card;

- (Card *)drawRandomCard;

@end
