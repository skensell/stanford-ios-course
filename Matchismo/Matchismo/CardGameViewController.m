//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Scott Kensell on 11/14/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "CardGameViewController.h"
#import "CardMatchingGame.h"
#import "CardView.h"
#import "Grid.h"

@interface CardGameViewController ()
@property (nonatomic, strong) CardMatchingGame *game;
@property (nonatomic, strong) Deck *deck;

@property (strong, nonatomic) IBOutlet UIView *playingArea;
@property (strong, nonatomic) NSMutableArray *cardViews;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@end

@implementation CardGameViewController


#pragma mark - Lazy instantiation


- (CardMatchingGame *)game {
    if (!_game)  {
        _game = [[CardMatchingGame alloc] initWithCardCount:[self.deck numberOfCards]
                                                  usingDeck:self.deck
                                   withNumberOfCardsToMatch:self.numberOfCardsToMatch];
    }
    return _game;
}

- (Deck *)deck {
    if (!_deck){
        _deck = [self createDeck];
    }
    return _deck;
}



- (NSMutableArray *)cardViews {
    if (!_cardViews) {
        _cardViews = [[NSMutableArray alloc] init];
        for (UIView *subView in self.view.subviews) {
            if ([subView isKindOfClass:[CardView class]]) {
                [_cardViews addObject:subView];
            }
        }
    }
    return _cardViews;
}

static const NSUInteger defaultNumberOfCardsToMatch = 2;

- (NSUInteger)numberOfCardsToMatch {
    if (!_numberOfCardsToMatch) _numberOfCardsToMatch = defaultNumberOfCardsToMatch;
    return _numberOfCardsToMatch;
}


#pragma mark - Game Actions

- (IBAction)touchCardView:(UIView *)sender {
    // touchCard animation (disable things while happening)
    
    NSUInteger cardIndex = [self.cardViews indexOfObject:sender];
    
    [self.game chooseCardAtIndex:cardIndex];
    
    [self updateUI];
}

- (IBAction)touchRedealButton:(UIButton *)sender {
    [self deal];
}

- (void)deal{
    self.game = nil;
    self.deck = nil;
    // init the deck
    // draw X cards from it and init their views
    // place the views on the board (animated)
    
    Grid *grid = [self initializeGrid];
    if (!grid) return;
    
    for (int i=0; i < grid.rowCount; i++) {
        for (int j=0; j < grid.columnCount; j++) {
            Card *card = [self.deck drawRandomCard];
        }
    }
    
    Card *card = [self.deck drawRandomCard];
    
    
    [self updateUI];
}


- (Grid *)initializeGrid {
    Grid *grid = [[Grid alloc] init];
    grid.cellAspectRatio = [self cardAspectRatio];
    grid.size = self.playingArea.bounds.size;
    grid.minimumNumberOfCells = 12;
    
    if (!grid.inputsAreValid) {
        NSLog(@"Invalid inputs for grid");
        return nil;
    }
    return grid;
}


#pragma mark - Update All UI


- (void)updateUI {
    for (CardView *cardView in self.cardViews) {
        NSUInteger cardIndex = [self.cardViews indexOfObject:cardView];
        Card *card = [self.game cardAtIndex:cardIndex];
        
        if (card.isMatched) {
            cardView.matched = YES;
        } else if (card.isChosen) {
            cardView.chosen = YES; // animated by subclass
        } else {
            cardView.chosen = NO; // animated by subclass
        }
    }
    
//    [self removeMatchedCards];
//    self.cardViews = nil;
//    [self dealMoreCards];

    [self updateScoreLabel];
    
}

#pragma mark - Protected

- (Deck *)createDeck // abstract method
{
    return nil;
}

- (CGFloat)cardAspectRatio {
    // protected for subclasses
    return 0;
}

- (void)removeMatchedCards {
    // remove from the screen and from superview
}


- (void)dealMoreCards {
    // replace the ones removed
}


#pragma mark - Update cardViews

- (NSString *)titleForCard:(Card *)card {
    return card.isChosen ? card.contents : @"";
}

- (UIImage *)backgroundImageForCard:(Card *)card {
    return [UIImage imageNamed:card.isChosen ? @"cardfront" : @"cardback"];
}


#pragma mark - Update Score


- (void)updateScoreLabel {
    self.scoreLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Score: %d", self.game.score]
                                                                     attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}


#pragma mark - MVC lifecycle and Navigation

- (void)viewDidLoad {
    [self updateUI];
}


@end
