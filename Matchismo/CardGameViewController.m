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
@property (weak, nonatomic) IBOutlet UITextView *StatusTextView;
@property (nonatomic, strong) NSMutableArray *history; // of attributed strings

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons; // order is not known
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (nonatomic) NSUInteger flipCount;
@end

@implementation CardGameViewController


#pragma mark Lazy instantiation


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

static const NSUInteger defaultNumberOfCardsToMatch = 2;

- (NSUInteger)numberOfCardsToMatch {
    if (!_numberOfCardsToMatch) _numberOfCardsToMatch = defaultNumberOfCardsToMatch;
    return _numberOfCardsToMatch;
}

- (NSMutableArray *)history {
    if (!_history) _history = [[NSMutableArray alloc] init];
    return _history;
}

#pragma mark Game Actions

- (IBAction)touchCardButton:(UIButton *)sender {
    NSUInteger cardIndex = [self.cardButtons indexOfObject:sender];
    
    Card *card = [self.game cardAtIndex:cardIndex];

    if (card.isChosen) {
        [self.currentlyPickedCards removeObject:card];
    } else {
        [self.currentlyPickedCards addObject:card];
    }
    
    [self.game chooseCardAtIndex:cardIndex];
    
    self.flipCount++;
    [self updateUI];
}

- (IBAction)touchRedealButton:(UIButton *)sender {
    [self restart];
}

- (void)restart {
    self.flipCount = 0;
    self.scoreDelta = 0;
    self.game = nil;
    [self.currentlyPickedCards removeAllObjects];
    [self.history removeAllObjects];
    [self updateUI];
}


#pragma mark Update All UI


- (void)updateUI {
    
    for (UIButton *cardButton in self.cardButtons) {
        NSUInteger cardIndex = [self.cardButtons indexOfObject:cardButton];
        Card *card = [self.game cardAtIndex:cardIndex];
        
        [self updateButton:cardButton forCard:card];
        
        cardButton.enabled = !card.isMatched;
    }
    
    [self updateStatus];
    [self updateScoreLabel];
    
}


#pragma mark Update Buttons

// override if you don't want to flip cards
- (void)updateButton:(UIButton *)cardButton forCard:(Card *)card {
    [cardButton setTitle:[self titleForCard:card]
                forState:UIControlStateNormal];
    [cardButton setBackgroundImage:[self backgroundImageForCard:card]
                          forState:UIControlStateNormal];
}

- (NSString *)titleForCard:(Card *)card {
    return card.isChosen ? card.contents : @"";
}

- (UIImage *)backgroundImageForCard:(Card *)card {
    return [UIImage imageNamed:card.isChosen ? @"cardfront" : @"cardback"];
}


#pragma mark Update Score


- (void)updateScoreLabel {
    self.scoreLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Score: %d", self.game.score]
                                                                     attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}


#pragma mark Update Status


- (void)updateStatus {
    self.scoreDelta = self.game.score - self.scoreDelta;
    
    [self updateStatusWithScoreDelta:self.scoreDelta];
    
    if ([self.currentlyPickedCards count] == self.numberOfCardsToMatch) {
        self.currentlyPickedCards = [[NSMutableArray alloc] initWithObjects:self.currentlyPickedCards[self.numberOfCardsToMatch - 1], nil];
        Card *card = self.currentlyPickedCards[0];
        if (card.isMatched) {
            [self.currentlyPickedCards removeObjectAtIndex:0];
        }
    }
    
    self.scoreDelta = self.game.score;
    
}

// updates status before currentlyPickedCards is emptied
- (void)updateStatusWithScoreDelta:(NSInteger)scoreDelta {
    NSMutableAttributedString *status = [[NSMutableAttributedString alloc] initWithString:@""];
    
    NSAttributedString *newline = [[NSAttributedString alloc] initWithString:@"\n"
                                                                  attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
    for (Card *card in self.currentlyPickedCards) {
        [status appendAttributedString:[self forStatusDepictCard:card]];
    }
    
    [status appendAttributedString:newline];
    [status appendAttributedString:[self matchMessageForScoreDelta:scoreDelta]];
    
    [status appendAttributedString:newline];
    [status appendAttributedString:[self coloredScoreDelta:scoreDelta]];

    self.StatusTextView.attributedText = status;
    self.StatusTextView.textAlignment = NSTextAlignmentCenter;
    
    if ([self.currentlyPickedCards count] == self.numberOfCardsToMatch) {
        [self.history addObject:status];
    }
    
}

- (NSAttributedString *)forStatusDepictCard:(Card *)aCard { //abstract method
    return nil;
}

- (NSAttributedString *)matchMessageForScoreDelta:(NSInteger)scoreDelta {
    if ([self.currentlyPickedCards count] == self.numberOfCardsToMatch){
        return [[NSAttributedString alloc] initWithString:((scoreDelta > 0) ? @"Match!" : @"Mismatch!")
                                               attributes:@{NSForegroundColorAttributeName: [self colorForScoreDelta:scoreDelta],
                                                            NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
    } else {
        return [[NSAttributedString alloc] initWithString:@""];
    }
}

- (NSAttributedString *)coloredScoreDelta:(NSInteger)scoreDelta {
    
    return [[NSAttributedString alloc] initWithString:[self pointStringForScoreDelta:scoreDelta]
                                           attributes:@{NSForegroundColorAttributeName: [self colorForScoreDelta:scoreDelta],
                                                        NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]}];
}

- (NSString *)pointStringForScoreDelta:(NSInteger)scoreDelta {
    return (scoreDelta > 0) ? [NSString stringWithFormat:@"+%d", scoreDelta] : [NSString stringWithFormat:@"%d", scoreDelta];
}

- (UIColor *)colorForScoreDelta:(NSInteger)scoreDelta {
    if (scoreDelta > 0) {
        return [UIColor blueColor];
    } else if (scoreDelta < -1) {
        return [UIColor redColor];
    } else {
        return [UIColor blackColor];
    }
}

- (NSMutableArray *)currentlyPickedCards {
    if (!_currentlyPickedCards) {
        _currentlyPickedCards = [[NSMutableArray alloc] init];
    }
    return _currentlyPickedCards;
}


#pragma mark MVC lifecycle and Navigation

- (void)viewDidLoad {
    // see if I can edit this on storyboard
    self.StatusTextView.editable = NO;
    self.StatusTextView.backgroundColor = [UIColor whiteColor];
    
    [self updateUI];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier hasSuffix:@"HistorySegue"]) {
        if ([segue.destinationViewController isKindOfClass:[HistoryViewController class]]) {
            HistoryViewController *HVC = (HistoryViewController *)segue.destinationViewController;
            
            HVC.history = self.history;
            
        }
    }
    
}

@end
