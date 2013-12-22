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

@interface CardGameViewController ()
@property (nonatomic, strong) CardMatchingGame *game;
@property (nonatomic, strong) Deck *deck;
@property (nonatomic) NSUInteger indexOfNextCard;

@property (nonatomic, strong) Grid *grid;

@property (strong, nonatomic) IBOutlet UIView *playingArea;
@property (strong, nonatomic) NSMutableArray *cardViews;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@end

@implementation CardGameViewController


#pragma mark - Lazy instantiation


- (CardMatchingGame *)game {
    if (!_game)  {
        Deck *deck = [self createDeck];
        // initing the game draws every card of the deck so it will be nil
        _game = [[CardMatchingGame alloc] initWithCardCount:[deck numberOfCards]
                                                  usingDeck:deck
                                   withNumberOfCardsToMatch:self.numberOfCardsToMatch];
    }
    return _game;
}

- (NSMutableArray *)cardViews {
    // the index of a view here corresponds to index in game
    if (!_cardViews) {
        _cardViews = [[NSMutableArray alloc] init];
    }
    return _cardViews;
}


#pragma mark - Game Actions

- (IBAction)touchCardView:(UIView *)sender {
    // touchCard animation (disable things while happening)
    
    NSUInteger cardIndex = [self.cardViews indexOfObject:sender];
    
    [self.game chooseCardAtIndex:cardIndex];
    
    [self updateUI];
}

- (IBAction)touchRedealButton:(UIButton *)sender {
    self.game = nil;
    // remove views, etc.
    [self updateUI];
}

- (void)deal{
    int cellNumber = 0;
    for (int i=0; i < self.grid.rowCount; i++) {
        for (int j=0; j < self.grid.columnCount; j++) {
            if (self.maximumNumberOfCardsOnBoard && ++cellNumber > self.maximumNumberOfCardsOnBoard) return;
            UIView *hitView = [self.playingArea hitTest:[self.grid centerOfCellAtRow:i inColumn:j] withEvent:nil];
            if (hitView == self.playingArea) {
                // hit an empty space, deal a card there
                
                Card *card = [self.game cardAtIndex:self.indexOfNextCard];
                if (card) {
                    // alloc init a Set card or Playing card
                    // frame below should be off screen
                    CGRect frame = [self slightlyInsideFrame:[self.grid frameOfCellAtRow:i inColumn:j] fraction:0.95];
                    CardView *cardView = [self createCardViewInFrame:frame fromCard:card];
                    
                    [self.playingArea addSubview:cardView];
                    [self.cardViews insertObject:cardView atIndex:self.indexOfNextCard];
                    self.indexOfNextCard++;
                }
                
            }
        }
    }
}


- (Grid *)grid {
    if (!_grid){
        _grid = [[Grid alloc] init];
        _grid.size = self.playingArea.bounds.size;
        _grid.cellAspectRatio = self.cardAspectRatio;
        _grid.minimumNumberOfCells = self.minimumNumberOfCardsOnBoard;
        _grid.prefersWideCards = self.prefersWideCards;
        
        if (!_grid.inputsAreValid) {
            NSLog(@"Invalid inputs for grid");
            NSLog(@"aspect ratio: %f",self.cardAspectRatio);
            NSLog(@"min number of cells: %d", self.minimumNumberOfCardsOnBoard);
            
            return nil;
        }
    }
    return _grid;
}

- (CGRect)slightlyInsideFrame:(CGRect)frame fraction:(CGFloat)fraction {
    // scales height and width by percent and moves origin appropriateley
    if (!fraction) fraction = 0.95;
    CGFloat h = frame.size.height * fraction;
    CGFloat w = frame.size.width * fraction;
    CGPoint origin = CGPointMake(frame.origin.x + (1 - fraction) * frame.size.width / 2,
                                 frame.origin.y + (1 - fraction) * frame.size.height / 2);
    
    return CGRectMake(origin.x, origin.y, w, h);
}

#pragma mark - Update All UI


- (void)updateUI {
    for (CardView *cardView in self.cardViews) {
        if (!cardView) continue;
        NSUInteger cardIndex = [self.cardViews indexOfObject:cardView];
        Card *card = [self.game cardAtIndex:cardIndex];
        
        if (card.isMatched) {
            cardView.matched = YES;
            // add to matched behavior
        } else if (card.isChosen) {
            cardView.chosen = YES; // animated by subclass
        } else {
            cardView.chosen = NO; // animated by subclass
        }
    }
    
//    [self removeMatchedCards];
    [self deal];

    [self updateScoreLabel];
    
}

#pragma mark - Protected

- (Deck *)createDeck // abstract method
{
    return nil;
}

- (CardView *)createCardViewInFrame:(CGRect)frame fromCard:(Card *)card {
    // alloc init a card view
    return nil;
}

- (void)removeMatchedCards {
    // remove from the screen and from superview
}

- (void)setDefaults {
    // subclasses should override these
    self.numberOfCardsToMatch = 2;
    
    self.minimumNumberOfCardsOnBoard = 12;
    self.maximumNumberOfCardsOnBoard = 100;
    self.cardAspectRatio = 5.0/7.0;
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
