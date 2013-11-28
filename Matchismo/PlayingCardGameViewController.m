//
//  PlayingCardGameViewController.m
//  Matchismo
//
//  Created by Scott Kensell on 11/20/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "PlayingCardGameViewController.h"
#import "PlayingCardDeck.h"
#import "PlayingCard.h"

@interface PlayingCardGameViewController ()

@end

@implementation PlayingCardGameViewController

- (Deck *)createDeck {
    return [[PlayingCardDeck alloc] init];
}

- (NSAttributedString *)forStatusDepictCard:(Card *)aCard {
    PlayingCard *card = (PlayingCard *)aCard;
    
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    return [[NSAttributedString alloc] initWithString:card.contents
                                           attributes:@{NSForegroundColorAttributeName:[self colorOfSuit:card.suit],
                                                        NSFontAttributeName: font}];
    
}

- (UIColor *)colorOfSuit:(NSString *)suit {
    return ([@[@"♦", @"♥"] containsObject:suit]) ? [UIColor redColor] : [UIColor blackColor];
}

@end
