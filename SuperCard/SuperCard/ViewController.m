//
//  ViewController.m
//  SuperCard
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "ViewController.h"
#import "PlayingCardView.h"
#import "PlayingCardDeck.h"
#import "PlayingCard.h"
#import "SetCard.h"
#import "SetCardView.h"
#import "SetCardDeck.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet PlayingCardView *playingCardView;
@property (weak, nonatomic) IBOutlet SetCardView *setCardView;
@property (strong, nonatomic) Deck *deck;
@property (strong, nonatomic) Deck *aSetDeck;
@end

@implementation ViewController

- (Deck *)deck
{
    if (!_deck) _deck = [[PlayingCardDeck alloc] init];
    return _deck;
}

-(Deck *)aSetDeck {
    if (!_aSetDeck) _aSetDeck = [[SetCardDeck alloc] init];
    return _aSetDeck;
}

- (void)drawRandomPlayingCard
{
    Card *card = [self.deck drawRandomCard];
    if ([card isKindOfClass:[PlayingCard class]]) {
        PlayingCard *playingCard = (PlayingCard *)card;
        self.playingCardView.rank = playingCard.rank;
        self.playingCardView.suit = playingCard.suit;
    }
}

- (void)drawRandomSetCard {
    Card *card = [self.aSetDeck drawRandomCard];
    if ([card isKindOfClass:[SetCard class]]) {
        SetCard *aSetCard = (SetCard *)card;
        self.setCardView.number = aSetCard.number;
        self.setCardView.shape = aSetCard.shape;
        self.setCardView.shading = aSetCard.shading;
        self.setCardView.color = aSetCard.color;
    }
}

- (IBAction)swipe:(UISwipeGestureRecognizer *)sender
{
    if (!self.playingCardView.faceUp) [self drawRandomPlayingCard];
    self.playingCardView.faceUp = !self.playingCardView.faceUp;
}

- (void)swipeSetCard:(UISwipeGestureRecognizer *)sender {
    [self drawRandomSetCard];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.playingCardView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.playingCardView action:@selector(pinch:)]];
    
    [self.setCardView addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeSetCard:)]];
}

@end
