//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Scott Kensell on 11/14/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "CardGameViewController.h"
#import "CardMatchingGame.h"

@interface CardGameViewController ()
@property (nonatomic) Deck *deck;
@property (nonatomic, strong) CardMatchingGame *game;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons; // order is not known
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *numberOfCardsToMatchButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic) NSUInteger numberOfCardsToMatch;
@property (nonatomic) NSUInteger flipCount;
@property (nonatomic) NSInteger scoreDelta;
@property (nonatomic) NSMutableArray *currentlyPickedCards;
@end

@implementation CardGameViewController

- (CardMatchingGame *)game {
    if (!_game) _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count]
                                                          usingDeck:[self createDeck]
                                           withNumberOfCardsToMatch:self.numberOfCardsToMatch];
    return _game;
}

- (Deck *)createDeck // abstract method
{
    return nil;
}

- (NSMutableArray *)currentlyPickedCards {
    if (!_currentlyPickedCards) {
        _currentlyPickedCards = [[NSMutableArray alloc] init];
    }
    return _currentlyPickedCards;
}

- (NSUInteger)numberOfCardsToMatch {
    if (!_numberOfCardsToMatch) _numberOfCardsToMatch = 2;
    return _numberOfCardsToMatch;
}

- (IBAction)selectNumberOfCards:(UISegmentedControl *)sender {
    self.numberOfCardsToMatch = [sender selectedSegmentIndex] + 2;
    
    [self restart];
}

- (IBAction)touchCardButton:(UIButton *)sender {
    int cardIndex = [self.cardButtons indexOfObject:sender];
    
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

- (void)updateStatusLabel:(NSArray *)currentlyPickedCards withScoreDelta:(NSInteger)scoreDelta{
    NSString *cardContents = @"";
    for (Card *card in currentlyPickedCards) {
        cardContents = [cardContents stringByAppendingString:card.contents];
    }

    if ([currentlyPickedCards count] == self.numberOfCardsToMatch){
        
        if (self.scoreDelta > 0) {
            self.statusLabel.text = [NSString stringWithFormat:@"%@ MATCH: %d points!",
                                     cardContents, scoreDelta];
        } else {
            self.statusLabel.text = [NSString stringWithFormat:@"%@ mismatch: %d!", cardContents, scoreDelta];
        }
        
    } else {
        self.statusLabel.text = [NSString stringWithFormat:@"%@", cardContents];
    }
    
    
}

- (void)updateUI {
    if (self.flipCount) {
        [self.numberOfCardsToMatchButton setEnabled:NO];
    } else {
        [self.numberOfCardsToMatchButton setEnabled:YES];
        self.statusLabel.text = @"";
    }

    
    for (UIButton *cardButton in self.cardButtons) {
        
        int cardIndex = [self.cardButtons indexOfObject:cardButton];
        Card *card = [self.game cardAtIndex:cardIndex];
        [cardButton setTitle:[self titleForCard:card]
                    forState:UIControlStateNormal];
        [cardButton setBackgroundImage:[self backgroundImageForCard:card]
                              forState:UIControlStateNormal];
        
        if (cardButton.enabled && card.isChosen
            && ![self.currentlyPickedCards containsObject:card] ) {
            
            [self.currentlyPickedCards addObject:card];
            
        }
        
        cardButton.enabled = !card.isMatched;
    }
    
    self.scoreDelta = self.game.score - self.scoreDelta;
    
    [self updateStatusLabel:self.currentlyPickedCards withScoreDelta:self.scoreDelta];
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
    
    if ([self.currentlyPickedCards count] == self.numberOfCardsToMatch) {
        [self.currentlyPickedCards removeAllObjects];
    }
    
    self.scoreDelta = self.game.score;
}

- (NSString *)titleForCard:(Card *)card {
    return card.isChosen ? card.contents : @"";
}

- (UIImage *)backgroundImageForCard:(Card *)card {
    return [UIImage imageNamed:card.isChosen ? @"cardfront" : @"cardback"];
}


@end
