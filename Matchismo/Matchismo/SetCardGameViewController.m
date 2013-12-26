//
//  SetCardGameViewController.m
//  Matchismo
//
//  Created by Scott Kensell on 11/22/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "SetCardGameViewController.h"
#import "SetCardDeck.h"
#import "SetCard.h"
#import "SetCardView.h"

@interface SetCardGameViewController ()

@end

@implementation SetCardGameViewController

-(Deck *)createDeck {
    return [[SetCardDeck alloc] init];
}

- (CardView *)createCardViewInFrame:(CGRect)frame fromCard:(Card *)card {
    SetCard *setCard = (SetCard *)card;
    SetCardView *setCardView = [[SetCardView alloc] initWithFrame:frame];
    setCardView.shape = setCard.shape;
    setCardView.shading = setCard.shading;
    setCardView.number = setCard.number;
    setCardView.color = setCard.color;
    return setCardView;
}

- (void)removeMatchedCards {
    // remove from the screen and from superview
}



#pragma mark MVC lifecycle

- (void)viewDidLoad {
    self.numberOfCardsToMatch = 3;
    
//    [self.playingArea createGridWithCardAspectRatio:7.0/5.0
//                                   prefersWideCards:YES
//                        minimumNumberOfCardsOnBoard:12
//                        maximumNumberOfCardsOnBoard:18];
    self.cardAspectRatio = 7.0/5.0;
    self.prefersWideCards = YES;
    self.minimumNumberOfCardsOnBoard = 12;
    self.maximumNumberOfCardsOnBoard = 18;
    [super viewDidLoad];
}


@end
