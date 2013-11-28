//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by Scott Kensell on 11/17/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "CardMatchingGame.h"

@interface CardMatchingGame()
@property (nonatomic, readwrite) NSInteger score; //readwrite is typically only used to make a readonly property readwrite
@property (nonatomic, strong) NSMutableArray *cards; // of Card
@property (nonatomic) NSUInteger numberOfCardsToMatch;
@end

@implementation CardMatchingGame

- (NSMutableArray *)cards {
    if (!_cards) {
        _cards = [[NSMutableArray alloc] init];
    }
    return _cards;
}

- (instancetype)initWithCardCount:(NSUInteger)count
                        usingDeck:(Deck *)deck
{
    return [self initWithCardCount:count usingDeck:deck withNumberOfCardsToMatch:2];
}

- (instancetype)initWithCardCount:(NSUInteger)count
                        usingDeck:(Deck *)deck
         withNumberOfCardsToMatch:(NSUInteger)numberToMatch
{
    self = [super init];
    
    if (self) {
        
        self.numberOfCardsToMatch = numberToMatch;
        
        for (int i = 0; i < count; i++) {
            Card *card = [deck drawRandomCard];
            if (card) {
                [self.cards addObject:card];
            } else {
                self = nil;
                break;
            }
        }
        
    }
    
    return self;
    
}

@synthesize numberOfCardsToMatch = _numberOfCardsToMatch;
- (void)setNumberOfCardsToMatch:(NSUInteger)numberOfCardsToMatch
{
    if ([@[@2, @3] containsObject:@(numberOfCardsToMatch)]) {
        NSLog(@"Matching %@ cards", @(numberOfCardsToMatch));
        _numberOfCardsToMatch = numberOfCardsToMatch;
    } else {
        NSLog(@"Matching 2 cards");
        _numberOfCardsToMatch = 2;
    }
}

- (NSUInteger)numberOfCardsToMatch {
    if (!_numberOfCardsToMatch) _numberOfCardsToMatch = 2;
    return _numberOfCardsToMatch;
}


static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int COST_TO_CHOOSE = 1;

- (void)chooseCardAtIndex:(NSUInteger)index {
    
    Card *theCard = [self cardAtIndex:index];
    
    if (!theCard.isMatched) {
        if (theCard.isChosen){
            theCard.chosen = NO;
        } else {
            // match against other cards if we have enough chosen
            theCard.chosen = YES;
            NSMutableArray *matchableCards = [[NSMutableArray alloc] init];
            
            for (Card *card in self.cards) {
                if (card.isChosen && !card.isMatched) {
                    [matchableCards addObject:card];
                }
            }
            
            if ([matchableCards count] == self.numberOfCardsToMatch) {
                
                int matchScore = [self calculateMatchScoreForCards:matchableCards];
                
                if (matchScore) {
                    self.score += matchScore * MATCH_BONUS;
                    
                    for (Card *card in matchableCards){
                        card.matched = YES;
                    }
                    
                } else {
                    for (Card *card in matchableCards){
                        if (card != theCard) {
                            card.chosen = NO;
                        }
                    }
                    self.score -= MISMATCH_PENALTY;
                }
            }
            
            self.score -= COST_TO_CHOOSE;
            
        }
    }
        
}

- (int)calculateMatchScoreForCards:(NSArray *)cards {
    
    int score = 0;
    
    NSMutableArray *allCards = [cards mutableCopy];
    
    while ([allCards count]) {
        
        Card *firstCard = [allCards firstObject];
        [allCards removeObject:firstCard];
        score += [firstCard match:allCards];
                  
    }
    
    return score;
}

- (Card *)cardAtIndex:(NSUInteger)index {
    return (index < [self.cards count]) ? self.cards[index] : nil;
}

- (instancetype)init
{
    return nil;
}


@end
