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
#import "PlayingCardView.h"
#import "Common.h"

@interface PlayingCardGameViewController ()

@end

@implementation PlayingCardGameViewController

- (Deck *)createDeck {
    return [[PlayingCardDeck alloc] init];
}

- (CardView *)createCardViewInFrame:(CGRect)frame fromCard:(Card *)card {
    PlayingCard *playingCard = (PlayingCard *)card;
    PlayingCardView *playingCardView = [[PlayingCardView alloc] initWithFrame:frame];
    playingCardView.suit = playingCard.suit;
    playingCardView.rank = playingCard.rank;
    playingCardView.faceUp = NO;
    return playingCardView;
}

- (void)viewDidLoad {
    [self setupGameWithNumberOfCardsToMatch:2
                            CardAspectRatio:5.0/7.0
                           prefersWideCards:NO
                minimumNumberOfCardsOnBoard:16
                maximumNumberOfCardsOnBoard:16
                      allowsFlippingOfCards:YES
    numberToDealWhenDealMoreButtonIsPressed:0];
    
    [super viewDidLoad];
}

@end
