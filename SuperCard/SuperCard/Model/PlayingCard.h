//
//  PlayingCard.h
//  Matchismo
//
//  Created by Scott Kensell on 11/16/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "Card.h"

@interface PlayingCard : Card

@property (strong, nonatomic) NSString *suit;
@property (nonatomic) NSUInteger rank;

+ (NSArray *)validSuits;
+ (NSUInteger)maxRank;


@end
