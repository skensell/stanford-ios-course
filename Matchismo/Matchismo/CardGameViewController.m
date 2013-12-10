//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Scott Kensell on 11/14/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "CardGameViewController.h"
#import "CardMatchingGame.h"
#import "HistoryViewController.h"

@interface CardGameViewController ()
@property (nonatomic, strong) CardMatchingGame *game;

@property (strong, nonatomic) NSMutableArray *cardViews;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (nonatomic) NSUInteger flipCount;
@end

@implementation CardGameViewController


#pragma mark Lazy instantiation


- (CardMatchingGame *)game {
    if (!_game) _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardViews count]
                                                          usingDeck:[self createDeck]
                                           withNumberOfCardsToMatch:self.numberOfCardsToMatch];
    return _game;
}

- (Deck *)createDeck // abstract method
{
    return nil;
}

static const NSUInteger defaultNumberOfCardsToMatch = 2;

- (NSUInteger)numberOfCardsToMatch {
    if (!_numberOfCardsToMatch) _numberOfCardsToMatch = defaultNumberOfCardsToMatch;
    return _numberOfCardsToMatch;
}


#pragma mark Game Actions

- (IBAction)touchCardView:(UIView *)sender {
    NSUInteger cardIndex = [self.cardViews indexOfObject:sender];
    
    [self.game chooseCardAtIndex:cardIndex];
    
    self.flipCount++;
    [self updateUI];
}

- (IBAction)touchRedealButton:(UIButton *)sender {
    [self restart];
}

- (void)restart {
    self.flipCount = 0;
    self.game = nil;
    [self updateUI];
}


#pragma mark - Update All UI


- (void)updateUI {
    
    for (UIView *cardView in self.cardViews) {
        NSUInteger cardIndex = [self.cardViews indexOfObject:cardView];
        Card *card = [self.game cardAtIndex:cardIndex];
        
        // update UI for cardView.
        // If matched, remove it, redeal.
    }

    [self updateScoreLabel];
    
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
