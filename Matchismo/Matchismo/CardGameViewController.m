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
#import "PlayingAreaView.h"
#import "Animator.h"
#import "Common.h"

@interface CardGameViewController ()
@property (nonatomic, strong) CardMatchingGame *game;
@property (nonatomic) BOOL deckIsEmpty;

// game logic - default is 2
@property (nonatomic) NSUInteger numberOfCardsToMatch;

// layout of card views
@property (nonatomic) CGFloat cardAspectRatio;
@property (nonatomic) BOOL prefersWideCards;
@property (nonatomic) NSUInteger minimumNumberOfCardsOnBoard;
@property (nonatomic) NSUInteger maximumNumberOfCardsOnBoard;


// playingarea could also handle the allocation of cardViews,
// but that would complicate some code here I think
@property (strong, nonatomic) IBOutlet PlayingAreaView *playingArea;

@property (strong, nonatomic) Animator *animator;


// index of view in cardViews corresponds to index in game.cards
// index does NOT correspond to visual place on screen
// Note: to get current card views I could iterate over the subviews of playingArea
@property (strong, nonatomic) NSMutableArray *cardViews;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@end

@implementation CardGameViewController


#pragma mark - Properties and setup

- (void)setupGameWithNumberOfCardsToMatch:(NSUInteger)numberOfCardsToMatch
                          CardAspectRatio:(CGFloat)aspectRatio
                         prefersWideCards:(BOOL)prefersWideCards
              minimumNumberOfCardsOnBoard:(NSUInteger)minimumNumberOfCardsOnBoard
              maximumNumberOfCardsOnBoard:(NSUInteger)maximumNumberOfCardsOnBoard {

    _numberOfCardsToMatch = numberOfCardsToMatch;
    _cardAspectRatio = aspectRatio;
    _prefersWideCards = prefersWideCards;
    _minimumNumberOfCardsOnBoard = minimumNumberOfCardsOnBoard;
    _maximumNumberOfCardsOnBoard = maximumNumberOfCardsOnBoard;
    _deckIsEmpty = NO;

}

- (CardMatchingGame *)game {
    if (!_game)  {
        _game = [[CardMatchingGame alloc] initWithCardCount:self.minimumNumberOfCardsOnBoard
                                                  usingDeck:[self createDeck]
                                   withNumberOfCardsToMatch:self.numberOfCardsToMatch];
    }
    return _game;
}

- (NSMutableArray *)cardViews {
    // the index of a view here corresponds to index of card in game
    if (!_cardViews) {
        _cardViews = [[NSMutableArray alloc] init];
    }
    return _cardViews;
}

- (Animator *)animator {
    if (!_animator) {
        _animator = [[Animator alloc] initWithPlayingArea:self.playingArea];
    }
    return _animator;
}


#pragma mark - Game actions

- (void)tapCardView:(UITapGestureRecognizer *)sender {
    if (self.animator.isMovingCardViews) return;
    
    CardView *cardView = (CardView *)sender.view;
    NSUInteger cardIndex = [self.cardViews indexOfObject:cardView];
    
    [self.game chooseCardAtIndex:cardIndex];
    
    [self updateUI];
}

- (IBAction)touchRedealButton:(UIButton *)sender {
    self.game = nil;
    if (self.animator.isMovingCardViews) return;
    
    __weak CardGameViewController *weakSelf = self;
    CompletionBlock completion = ^(BOOL finished) {
        if (finished) {
            [weakSelf.cardViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [weakSelf.cardViews removeAllObjects];
            [weakSelf updateUI];
        }
    };
    
    [self.animator animateRedealGivenCardViews:self.cardViews completion:completion];
}

// TODO: I should move this to SetCardGameController
- (IBAction)touchThreeMoreButton:(UIButton *)sender {
    if (!self.animator.isMovingCardViews &&
        [[self getCardsInPlayFromGame] count] + 3 <= self.maximumNumberOfCardsOnBoard &&
        [[self.playingArea centersOfEmptySpacesInGrid] count] >= 3) {
        [self dealMoreCardsIntoPlay:3];
    }
}

- (void)dealMoreCardsIntoPlay:(NSUInteger)numberOfCards{
    // deal cards in the model
    NSUInteger numberDealt = [self.game dealMoreCards:numberOfCards];
    if (numberDealt < numberOfCards) self.deckIsEmpty = YES;
    if (numberDealt == 0) return;
    
    NSArray *cardsInPlay = [self getCardsInPlayFromGame];
    NSArray *cardsJustDealt = [cardsInPlay subarrayWithRange:NSMakeRange([cardsInPlay count] - numberDealt, numberOfCards)];
    NSArray *cardViews = [self makeCardViewsFromCards:cardsJustDealt];
    
    [self.animator animateCardViewsIntoEmptySpaces:cardViews];

}

#pragma mark - Update UI

- (void)updateUI {
    if ([self noCardViewsDealtYet]) {
        
        NSArray *cardViews = [self makeCardViewsFromCards:[self getCardsInPlayFromGame]];
        [self.animator animateCardViewsIntoEmptySpaces:cardViews];
        
    } else if ([self tooFewCardViewsInPlay]){
        
        [self dealMoreCardsIntoPlay:[self numberOfCardsToMatch]];
        
    } else if (self.playingArea.hasHolesInGrid) {
        
        [self.animator fillHolesInGridWithRecentCardsDealt];
        
    } else {
        // set chosen and matched, then remove matched cards
        [self animateChosenAndMatchedCardViews];
    }
    
    [self updateScoreLabel];
}


- (void)updateScoreLabel {
    self.scoreLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", self.game.score]
                                                                     attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}



#pragma mark - Game status

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

- (BOOL)noCardViewsDealtYet {
    return [self.cardViews count] == 0;
}

- (BOOL)tooFewCardViewsInPlay {
    
    return ([self.playingArea.subviews count] < self.minimumNumberOfCardsOnBoard) && !self.deckIsEmpty;
}


#pragma mark - CardView management

- (NSArray *)makeCardViewsFromCards:(NSArray *)cards{
    
    NSMutableArray *cardViews = [[NSMutableArray alloc] init];
    [cards enumerateObjectsUsingBlock:^(Card *card, NSUInteger idx, BOOL *stop) {
        CardView *cardView = [self createCardViewFromCard:card];
        [self.playingArea addSubview:cardView];
        [self.cardViews addObject:cardView];
        UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCardView:)];
        [cardView addGestureRecognizer:tapgr];
        
        [cardViews addObject:cardView];
    }];
    
    return cardViews;
}

- (void)removeMatchedCardViews:(NSArray *)matchedCardViews {
    // cardViews will not be dealloced because they are always in self.cardViews
    if ([matchedCardViews count] == 0) return;
    
    __weak CardGameViewController *weakSelf = self;
    [self.animator animateMatchedCardViewsOffScreen:matchedCardViews completion:^(BOOL finished) {
        if (finished) {
            [matchedCardViews enumerateObjectsUsingBlock:^(CardView *cardView, NSUInteger idx, BOOL *stop) {
                [cardView removeAllGestureRecognizers];
                [cardView removeFromSuperview]; // its superview is playingArea
            }];
            [weakSelf updateUI]; // needs to deal more cards
        }
    }];
}

- (void)animateChosenAndMatchedCardViews {
    NSMutableArray *matchedCardViews = [[NSMutableArray alloc] init];
    NSMutableArray *chosenCardViews = [[NSMutableArray alloc] init];
    
    for (CardView *cardView in self.cardViews) {
        if (cardView.isMatched) continue;
        [cardView.layer removeAllAnimations];
        
        Card *card = [self.game cardAtIndex:[self.cardViews indexOfObject:cardView]];
        cardView.matched = card.isMatched;
        cardView.chosen = card.isChosen; // unchosen cards get all animations removed
        
        if (cardView.isChosen) {
            [chosenCardViews addObject:cardView];
        }
        
        if (cardView.isMatched) [matchedCardViews addObject:cardView];
    }
    
    if ([chosenCardViews count]) {
        [self.animator animateChosenCardViews:chosenCardViews];
        DEBUG(@"There are %d chosen cardViews.", [chosenCardViews count]);
    }
    
    if ([matchedCardViews count]) {
        DEBUG(@"There are %d matched cardViews.", [matchedCardViews count]);
        [self removeMatchedCardViews:matchedCardViews];
    }
}

- (CardView *)createCardViewFromCard:(Card *)card {
    return [self createCardViewInFrame:[self.playingArea cardSpawnFrame] fromCard:card];
}


#pragma mark - Protected

- (Deck *)createDeck // abstract method
{
    return nil;
}

- (CardView *)createCardViewInFrame:(CGRect)frame fromCard:(Card *)card {
    // ABSTRACT METHOD: alloc init a card view
    return nil;
}

#pragma mark - MVC lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.playingArea resetGridWithCardAspectRatio:self.cardAspectRatio
                                   prefersWideCards:self.prefersWideCards
                        minimumNumberOfCardsOnBoard:self.minimumNumberOfCardsOnBoard
                        maximumNumberOfCardsOnBoard:self.maximumNumberOfCardsOnBoard];
    
    if ([self.playingArea.subviews count]) {
        // cards on board already
        [self.animator realignAndScaleCardViewsToGridCells:self.playingArea.subviews];
    } else {
        [self updateUI];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.animator realignAndScaleCardViewsToGridCells:self.playingArea.subviews];
}

@end
