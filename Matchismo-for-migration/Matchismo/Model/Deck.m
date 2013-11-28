//
//  Deck.m
//  Matchismo
//
//  Created by Scott Kensell on 11/16/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "Deck.h"

@interface Deck()

@property (strong, nonatomic) NSMutableArray *cards;

@end

@implementation Deck

- (BOOL)isEmpty {
    if (![self.cards count]) {
        _empty = YES;
    } else {
        _empty = NO;
    }
    return _empty;
}

- (NSMutableArray *)cards
{
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

- (void)addCard:(Card *)card atTop:(BOOL)atTop
{
    if (atTop){
        [self.cards insertObject:card atIndex:0];
    } else {
        [self.cards addObject:card];
    }

}

- (void)addCard:card
{
    [self addCard:card atTop:NO];
}

- (Card *)drawRandomCard
{
    Card *randomCard = nil;
    
    NSUInteger num_cards = [self.cards count];
    if (num_cards) {
        NSUInteger idx = arc4random_uniform(num_cards);
        randomCard = self.cards[idx];
        [self.cards removeObjectAtIndex:idx];
    }

    return randomCard;
}
@end
