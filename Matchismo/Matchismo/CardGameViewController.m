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
#import "NSArray+Combinations.h"
#import "UIColor+FromHex.h"

@interface CardGameViewController ()
@property (nonatomic, strong) CardMatchingGame *game;
@property (nonatomic) BOOL deckIsEmpty;

// game logic - default is 2
@property (nonatomic) NSUInteger numberOfCardsToMatch;
@property (nonatomic) NSUInteger numberOfCheatsAllowed;
@property (nonatomic) NSUInteger numberOfTimesCheatedSoFar;

// layout of card views
@property (nonatomic) CGFloat cardAspectRatio;
@property (nonatomic) BOOL prefersWideCards;
@property (nonatomic) NSUInteger minimumNumberOfCardsOnBoard;
@property (nonatomic) NSUInteger maximumNumberOfCardsOnBoard;

@property (nonatomic) NSUInteger numberToDealWhenDealMoreButtonIsPressed;
@property (strong, nonatomic) IBOutlet UIButton *dealMoreButton;
@property (strong, nonatomic) IBOutlet UIButton *cheatButton;

// playingarea could also handle the allocation of cardViews,
// but that would complicate some code here I think
@property (strong, nonatomic) IBOutlet PlayingAreaView *playingArea;

@property (strong, nonatomic) Animator *animator;
@property (nonatomic) BOOL allowsFlippingOfCards;


// index of view in cardViews corresponds to index in game.cards
// index does NOT correspond to visual place on screen
// Note: to get current card views you could iterate over the subviews of playingArea
@property (strong, nonatomic) NSMutableArray *cardViews;

// stats UI
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (nonatomic) NSUInteger numberOfCardsInDeckAtStart;
@property (strong, nonatomic) IBOutlet UIProgressView *deckProgressView;

@property (strong, nonatomic) UITextView *gameOverView;
@end

@implementation CardGameViewController


#pragma mark - Properties and setup

- (void)setupGameWithNumberOfCardsToMatch:(NSUInteger)numberOfCardsToMatch
                          CardAspectRatio:(CGFloat)aspectRatio
                         prefersWideCards:(BOOL)prefersWideCards
              minimumNumberOfCardsOnBoard:(NSUInteger)minimumNumberOfCardsOnBoard
              maximumNumberOfCardsOnBoard:(NSUInteger)maximumNumberOfCardsOnBoard
                    allowsFlippingOfCards:(BOOL)allowsFlippingOfCards
  numberToDealWhenDealMoreButtonIsPressed:(NSUInteger)numberToDealWhenDealMoreButtonIsPressed {

    _numberOfCardsToMatch = numberOfCardsToMatch;
    _cardAspectRatio = aspectRatio;
    _prefersWideCards = prefersWideCards;
    _minimumNumberOfCardsOnBoard = minimumNumberOfCardsOnBoard;
    _maximumNumberOfCardsOnBoard = maximumNumberOfCardsOnBoard;
    _allowsFlippingOfCards = allowsFlippingOfCards;
    _numberToDealWhenDealMoreButtonIsPressed = numberToDealWhenDealMoreButtonIsPressed;
    _deckIsEmpty = NO;
    _numberOfTimesCheatedSoFar = 0;
    
    _numberOfCheatsAllowed = 3; // could be a parameter

}

- (CardMatchingGame *)game {
    if (!_game)  {
        Deck *deck = [self createDeck];
        self.numberOfCardsInDeckAtStart = [deck numberOfCards];
        
        _game = [[CardMatchingGame alloc] initWithCardCount:self.minimumNumberOfCardsOnBoard
                                                  usingDeck:deck
                                   withNumberOfCardsToMatch:self.numberOfCardsToMatch];
    }
    return _game;
}

- (Deck *)debugDeck {
    Deck *tempDeck = [self createDeck];
    Deck *deck = [[Deck alloc] init];
    for (int i=0; i < self.minimumNumberOfCardsOnBoard + 3; i++) {
        [deck addCard:[tempDeck drawRandomCard]];
    }
    return deck;
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
        _animator = [[Animator alloc] initWithPlayingArea:self.playingArea allowsFlippingOfCards:self.allowsFlippingOfCards];
    }
    return _animator;
}

- (void)setDeckIsEmpty:(BOOL)deckIsEmpty {
    if (_deckIsEmpty != deckIsEmpty) {
        self.dealMoreButton.enabled = !deckIsEmpty;
        _deckIsEmpty = deckIsEmpty;
    }
}

- (UITextView *)gameOverView {
    if (!_gameOverView) {
        _gameOverView = [[UITextView alloc] initWithFrame:self.playingArea.frame];
        _gameOverView.backgroundColor = [UIColor fromHex:0x86C67C alpha:0.98];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSMutableAttributedString *gameOver = [[NSMutableAttributedString alloc] initWithString:[self highScores]
                                                                                     attributes:@{NSParagraphStyleAttributeName: paragraphStyle,
                                                                                                  NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]}];
        

        
        _gameOverView.attributedText = gameOver;
        
    }
    return _gameOverView;
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
    if (self.animator.isMovingCardViews) return;
    self.game = nil;
    self.dealMoreButton.enabled = YES;
    self.deckIsEmpty = NO;
    self.cheatButton.enabled = YES;
    self.numberOfTimesCheatedSoFar = 0;
    [self.gameOverView removeFromSuperview];
    self.gameOverView = nil;
    
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

- (IBAction)touchDealMoreButton:(UIButton *)sender {
    NSUInteger numberToDeal = self.numberToDealWhenDealMoreButtonIsPressed;
    if (!numberToDeal) return;
    
    if (!self.animator.isMovingCardViews &&
        [[self getCardsInPlayFromGame] count] + numberToDeal <= self.maximumNumberOfCardsOnBoard &&
        [[self.playingArea centersOfEmptySpacesInGrid] count] >= numberToDeal) {
        
        NSArray *overlookedCardViews = [self overlookedCardViews];
        [self dealMoreCardsIntoPlay:numberToDeal];
        
        if (!self.deckIsEmpty) {
            [self.animator spinCardViews:overlookedCardViews]; // the overlooked set being punished for
        }
        
    }
}

- (IBAction)touchCheatButton:(UIButton *)sender {
    if (++self.numberOfTimesCheatedSoFar >= self.numberOfCheatsAllowed) {
        sender.enabled = NO;
    }
    [self showOneMatchingSetIfThereIsOne];
}


- (void)dealMoreCardsIntoPlay:(NSUInteger)numberOfCards{
    // deal cards in the model
    NSUInteger numberDealt = [self.game dealMoreCards:numberOfCards];
    if (numberDealt < numberOfCards) self.deckIsEmpty = YES;
    if (numberDealt == 0) {
        if ([self gameIsOver]){
            [self showGameOverView];
        }
        return;
    }
    
    NSArray *cardsInPlay = [self getCardsInPlayFromGame];
    NSArray *cardsJustDealt = [cardsInPlay subarrayWithRange:NSMakeRange([cardsInPlay count] - numberDealt, numberDealt)];
    NSArray *cardViews = [self makeCardViewsFromCards:cardsJustDealt];
    
    [self.animator animateCardViewsIntoEmptySpaces:cardViews];
    
    [self updateScoreLabel]; // unnecessary deals are punished
    [self updateDeckProgressBar];
}

static NSString* const highScoresKey = @"highScores";
- (NSString *)highScores {
    // returns a string of top 10 scores separated by \n
    NSMutableArray *topTen = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:highScoresKey]];
    
    for (int i=0; i < [topTen count]; i++) {
        if (self.game.score > [topTen[i] intValue]) {
            [topTen insertObject:@(self.game.score) atIndex:i];
            break;
        } else if (i < 10 && i == [topTen count] - 1) {
            [topTen addObject:@(self.game.score)];
            break;
        }
    }
    
    if (!topTen) {
        [topTen addObject:@(self.game.score)];
    }
    
     NSArray *theTopTen = [topTen subarrayWithRange:NSMakeRange(0, MIN(10,[topTen count]))];
    
    [[NSUserDefaults standardUserDefaults] setObject:theTopTen forKey:highScoresKey];
    
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"High Scores"];
    for (NSNumber *score in theTopTen){
        [result appendString:[NSString stringWithFormat:@"\n%@", score]];
    }
    return result;
}

#pragma mark - Update UI

- (void)updateUI {
    if ([self noCardViewsDealtYet]) {
        
        NSArray *cardViews = [self makeCardViewsFromCards:[self getCardsInPlayFromGame]];
        [self.animator animateCardViewsIntoEmptySpaces:cardViews];
        
    } else {
        // set chosen and matched, then remove matched cards
        [self animateChosenAndMatchedCardViews];
        
    }
    
    [self updateScoreLabel];
    [self updateDeckProgressBar]; // insert same line after dealing too
}


- (void)updateScoreLabel {
    self.scoreLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", self.game.score]
                                                                     attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (void)updateDeckProgressBar {
    float progress = [self.cardViews count]/(float)self.numberOfCardsInDeckAtStart;
    [self.deckProgressView setProgress:progress animated:YES];
}

- (void)showOneMatchingSetIfThereIsOne {
    // spins a matching set
    [self.animator spinCardViews:[self overlookedCardViews]];
}

- (void)showGameOverView {
    [self.view addSubview:self.gameOverView];
}

- (NSArray *)overlookedCardViews {
    NSArray *indicesFormingMatch = [self.game indicesOfMatchingSetOfCards];
    if ([indicesFormingMatch count]) {
        DEBUG(@"Overlooked match at indices %@", indicesFormingMatch);
        
        NSMutableArray *overlookedCardViews = [[NSMutableArray alloc] init];
        for (int i=0; i < [indicesFormingMatch count]; i++) {
            [overlookedCardViews addObject:[self.cardViews objectAtIndex:[indicesFormingMatch[i] intValue]]];
        }
        return overlookedCardViews;
        // TODO - sleep here, but have the main animation run on another thread
        // [NSThread sleepForTimeInterval:animationDuration];
    }
    return nil;
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

- (BOOL)thereIsNoSet {
    return [[self.game indicesOfMatchingSetOfCards] count] == 0;
}

- (BOOL)gameIsOver {
    return self.deckIsEmpty && [self thereIsNoSet];
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
    // cardViews will not be dealloced until redeal because they are always in self.cardViews
    if ([matchedCardViews count] == 0) return;
    
    __weak CardGameViewController *weakSelf = self;
    [self.animator animateMatchedCardViewsOffScreen:matchedCardViews completion:^(BOOL finished) {
        if (finished) {
            [matchedCardViews enumerateObjectsUsingBlock:^(CardView *cardView, NSUInteger idx, BOOL *stop) {
                [cardView removeAllGestureRecognizers];
                [cardView removeFromSuperview]; // its superview is playingArea
            }];
            
            [weakSelf updateScoreLabel];
            
            if ([weakSelf gameIsOver]) {
                [weakSelf showGameOverView];
            } else if ([weakSelf tooFewCardViewsInPlay]){
                [weakSelf dealMoreCardsIntoPlay:[weakSelf numberOfCardsToMatch]];
            } else if (weakSelf.playingArea.hasHolesInGrid) {
                [weakSelf.animator fillHolesInGridWithRecentCardsDealt];
            }
            

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
