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
@property (nonatomic) NSUInteger indexOfNextCard;

@property (nonatomic, strong) Grid *grid;
@property (strong, nonatomic) IBOutlet UIView *playingArea;

// index of view in cardViews corresponds to index in game.cards
// index may  NOT correspond to visual place on screen
@property (strong, nonatomic) NSMutableArray *cardViews;
// to get current card views I can iterate over the subviews of playingArea


@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

// I will have a matchedBehavior which removes matched cards
// I will have an init cardView point off screen where I init new cards in a frame of right aspect ratio.

@end

@implementation CardGameViewController


#pragma mark - Lazy instantiation


- (CardMatchingGame *)game {
    if (!_game)  {
        // initing the game draws every card of the deck so it will be nil
        _game = [[CardMatchingGame alloc] initWithCardCount:[self minimumNumberOfCardsOnBoard]
                                                  usingDeck:[self createDeck]
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

- (void)tapCardView:(UITapGestureRecognizer *)sender {
    CardView *cardView = (CardView *)sender.view;
    NSUInteger cardIndex = [self.cardViews indexOfObject:cardView];
    
    [self.game chooseCardAtIndex:cardIndex];
    
    [self updateUI];
}

- (IBAction)touchRedealButton:(UIButton *)sender {
    self.game = nil;
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        for (CardView *cardView in self.cardViews) {
            cardView.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        if (finished) {
            [self.cardViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self.cardViews removeAllObjects];
            [self updateUI];
        }
    }];
}

- (void)dealMoreCardsIntoPlay:(NSUInteger)numberOfCards{
    // deal cards in the model
    [self.game dealMoreCards:numberOfCards];
    
    NSArray *cardsInPlay = [self getCardsInPlayFromGame];
    NSArray *cardsJustDealt = [cardsInPlay subarrayWithRange:NSMakeRange([cardsInPlay count] - numberOfCards - 1, numberOfCards)];
    NSArray *cardViews = [self makeCardViewsFromCards:cardsJustDealt];
    
    [self animateCardViewsIntoEmptySpaces:cardViews];

}

#pragma mark - Grid

- (NSArray *)indicesOfEmptySpacesInGrid {
    // returns @[@[@1,@2],@[@3,@6]] if those are open spaces in grid
    
    NSMutableArray *indices = [[NSMutableArray alloc] init];

    for (int i=0; i < self.grid.rowCount; i++) {
        for (int j=0; j < self.grid.columnCount; j++) {

            UIView *hitView = [self.playingArea hitTest:[self.grid centerOfCellAtRow:i inColumn:j] withEvent:nil];
            if (hitView == self.playingArea) {
                // hit an empty space
                [indices addObject:@[@(i),@(j)]];
            }
            
        }
    }
    
    return indices;
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

- (CGRect)cardSpawnFrame {
    // just to the top left off the screen
    CGFloat x = self.view.bounds.origin.x - self.grid.cellSize.width - 100;
    CGFloat y = self.view.bounds.origin.y - self.grid.cellSize.height - 100;
    CGFloat w = self.grid.cellSize.width;
    CGFloat h = self.grid.cellSize.height;
    return [self slightlyInsideFrame:CGRectMake(x, y, w, h) fraction:0.95];
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

#pragma mark - Update UI and animations

- (void)updateUI {
    if ([self noCardsDealtYet]) {
        NSArray *cardsInPlay = [self getCardsInPlayFromGame];
        NSArray *cardViews = [self makeCardViewsFromCards:cardsInPlay];
        [self animateCardViewsIntoEmptySpaces:cardViews];

        [self updateScoreLabel];
        return;
    }
    
    BOOL needToDealMoreCards = NO;
    for (CardView *cardView in self.cardViews) {
        if ([cardView superview] != self.playingArea) continue; // matched views are removed from superview but not cardViews
        
        NSUInteger cardIndex = [self.cardViews indexOfObject:cardView];
        Card *card = [self.game cardAtIndex:cardIndex];
        
        if (card.isMatched) {
            cardView.matched = YES; // add to matched behavior
            needToDealMoreCards = YES;
        } else if (card.isChosen) {
            cardView.chosen = YES; // animated by subclass of CardView
        } else {
            cardView.chosen = NO; // animated by subclass of CardView
        }
    }
    
    if (needToDealMoreCards) {
        // I need to deal more cards only after the matched animations finished.
        // I can create a PlayingAreaView which serves as a layer between the CardGameViewController
        // and the cardViews.  Here I can handle some animations much better.
        [self dealMoreCardsIntoPlay:[self numberOfCardsToMatch]];
    }
//    [self removeMatchedCards]; in its completion block I should call deal
    
    [self updateScoreLabel];
}

- (void)animateCardViewsIntoEmptySpaces:cardViews {
    NSArray *indicesOfEmptySpacesInGrid = [self indicesOfEmptySpacesInGrid];
    
    if ([indicesOfEmptySpacesInGrid count] < [cardViews count]) {
        NSLog(@"ERROR: More cards to place on grid than empty spaces.");
        return;
    }
    
    int idx=0;
    for (CardView *cardView in cardViews) {
        int i = [indicesOfEmptySpacesInGrid[idx][0] intValue];
        int j = [indicesOfEmptySpacesInGrid[idx][1] intValue];
        
        cardView.transform = CGAffineTransformMakeRotation(M_PI);
        [UIView animateWithDuration:0.5 delay:0.04*idx options:0 animations:^{
            cardView.center = [self.grid centerOfCellAtRow:i inColumn:j];
            cardView.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL fin){
            if (fin) {
            }
        }];
        
        idx++;
    }
}

- (void)updateScoreLabel {
    self.scoreLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Score: %d", self.game.score]
                                                                     attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}



#pragma mark - Private

- (NSArray *)getCardsInPlayFromGame {
    NSUInteger n = [self.game numberOfCardsInPlay];
    NSMutableArray *cardsInPlay = [[NSMutableArray alloc] init];
    
    int i=0;
    while (n--) {
        BOOL isInPlay = NO;
        while (!isInPlay) {
            Card *card = [self.game cardAtIndex:i];
            if (card && !card.isMatched) {
                isInPlay = YES;
                [cardsInPlay addObject:card];
            }
            i++;
        }
    }
    
    return cardsInPlay;
}

- (NSArray *)makeCardViewsFromCards:(NSArray *)cards{
    
    NSMutableArray *cardViews = [[NSMutableArray alloc] init];
    [cards enumerateObjectsUsingBlock:^(Card *card, NSUInteger idx, BOOL *stop) {
        CardView *cardView = [self createCardViewInFrame:[self cardSpawnFrame] fromCard:card];
        [self.playingArea addSubview:cardView];
        [self.cardViews addObject:cardView];
        UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCardView:)];
        [cardView addGestureRecognizer:tapgr];
        
        [cardViews addObject:cardView];
    }];
    
    return cardViews;
}

- (BOOL)noCardsDealtYet {
    return [self.cardViews count] == 0;
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

#pragma mark - MVC lifecycle

//- (void)viewDidLoad {
//    [self updateUI];
//}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"Calling viewDidAppear.");
    [self updateUI];
}

- (void)viewDidLayoutSubviews {
    NSLog(@"Calling viewDidLayoutSubviews.");
    [super viewDidLayoutSubviews];
    
    if (!CGSizeEqualToSize(self.grid.size, self.playingArea.bounds.size)){
        NSLog(@"INFO: Grid not equal to playing area. Resetting grid to nil.");
        self.grid = nil;
    }
    //[self updateUI];
}


@end
