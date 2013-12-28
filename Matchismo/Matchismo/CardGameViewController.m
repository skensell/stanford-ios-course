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
#import "MatchedBehavior.h"

@interface CardGameViewController () <UIDynamicAnimatorDelegate>
@property (nonatomic, strong) CardMatchingGame *game;

// game logic - default is 2
@property (nonatomic) NSUInteger numberOfCardsToMatch;

// layout of card views
@property (nonatomic) CGFloat cardAspectRatio;
@property (nonatomic) BOOL prefersWideCards;
@property (nonatomic) NSUInteger minimumNumberOfCardsOnBoard;
@property (nonatomic) NSUInteger maximumNumberOfCardsOnBoard;

// playing area could have an animation delegate which handles all of its animations
// this would ensure that no two animations run at the same time
// playingarea could also handle the allocation of cardViews,
// but that would complicate some code here I think
@property (strong, nonatomic) IBOutlet PlayingAreaView *playingArea;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) MatchedBehavior *matchedBehavior;

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

}

- (CardMatchingGame *)game {
    if (!_game)  {
        // initing the game draws every card of the deck so it will be nil
        _game = [[CardMatchingGame alloc] initWithCardCount:self.minimumNumberOfCardsOnBoard
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

- (UIDynamicAnimator *)animator {
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.playingArea];
        _animator.delegate = self;
    }
    return _animator;
}

- (MatchedBehavior *)matchedBehavior {
    if (!_matchedBehavior) {
        _matchedBehavior = [[MatchedBehavior alloc] init];
        [self.animator addBehavior:_matchedBehavior];
    }
    return _matchedBehavior;
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
    
    [self.playingArea animateCardViewsIntoEmptySpaces:cardViews];

}

#pragma mark - Update UI

- (void)updateUI {
    if ([self noCardsDealtYet]) {
        NSArray *cardsInPlay = [self getCardsInPlayFromGame];
        NSArray *cardViews = [self makeCardViewsFromCards:cardsInPlay];
        [self.playingArea animateCardViewsIntoEmptySpaces:cardViews];

        [self updateScoreLabel];
        return;
    }
    
    NSMutableArray *matchedCardViews = [[NSMutableArray alloc] init];
    for (CardView *cardView in self.cardViews) {
        if (cardView.isMatched) continue;
        
        NSUInteger cardIndex = [self.cardViews indexOfObject:cardView];
        Card *card = [self.game cardAtIndex:cardIndex];
        
        cardView.matched = card.isMatched;
        cardView.chosen = card.isChosen; // animated by subclass if not matched
        
        if (cardView.isMatched) [matchedCardViews addObject:cardView];
    }
    
    [self animateMatchedCardViewsOffScreen:matchedCardViews];
    
//    // This should go in the DidPause delegate call
//    if (needToDealMoreCards) {
//        // I need to deal more cards only after the matched animations finished.
//        [self dealMoreCardsIntoPlay:[self numberOfCardsToMatch]];
//    }
//    [self removeMatchedCards]; in its completion block I should call deal
    
    [self updateScoreLabel];
}

- (void)animateMatchedCardViewsOffScreen:(NSArray *)matchedCardViews {
    if (![matchedCardViews count]) return;
    
    [matchedCardViews enumerateObjectsUsingBlock:^(CardView *cardView, NSUInteger idx, BOOL *stop) {
        [self.matchedBehavior addItem:cardView];
    }];
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
        CardView *cardView = [self createCardViewFromCard:card];
        [self.playingArea addSubview:cardView];
        [self.cardViews addObject:cardView];
        UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCardView:)];
        [cardView addGestureRecognizer:tapgr];
        
        [cardViews addObject:cardView];
    }];
    
    return cardViews;
}

- (CardView *)createCardViewFromCard:(Card *)card {
    return [self createCardViewInFrame:[self.playingArea cardSpawnFrame] fromCard:card];
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
    [self.playingArea createGridWithCardAspectRatio:self.cardAspectRatio
                                   prefersWideCards:self.prefersWideCards
                        minimumNumberOfCardsOnBoard:self.minimumNumberOfCardsOnBoard
                        maximumNumberOfCardsOnBoard:self.maximumNumberOfCardsOnBoard];
    [self updateUI];
}

- (void)viewDidLayoutSubviews {
    NSLog(@"Calling viewDidLayoutSubviews.");
    [super viewDidLayoutSubviews];
}


@end
