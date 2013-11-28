//
//  SetCardGameViewController.m
//  Matchismo
//
//  Created by Scott Kensell on 11/22/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "SetCardGameViewController.h"
#import "SetCardDeck.h"
#import "SetCard.h"
#import "UIColor+FromHex.h"

@interface SetCardGameViewController ()

@end

@implementation SetCardGameViewController

-(Deck *)createDeck {
    return [[SetCardDeck alloc] init];
}

#pragma mark Update Buttons
// overriding this section because we don't flip cards

- (void)updateButton:(UIButton *)cardButton
             forCard:(Card *)card {
    if (![card isKindOfClass:[SetCard class]]) {
        NSLog(@"Calling SetCardGame's updateButton for non-Set card.");
        return;
    }
    
    [cardButton setAttributedTitle:[self forStatusDepictCard:card]
                          forState:UIControlStateNormal];
    
    cardButton.backgroundColor = [self backgroundColorForCardButton:card whenCardButtonIsEnabled:cardButton.isEnabled];
}

- (UIColor *)backgroundColorForCardButton:(Card *)card whenCardButtonIsEnabled:(BOOL)isEnabled {
    if (!isEnabled){
        return [UIColor fromHex:0xcdc5bf alpha:.7];
    }
    return card.isChosen ? [UIColor fromHex:0xffe4b5] : [UIColor whiteColor];
}


#pragma mark Update Status

// goes in the StatusView
- (NSAttributedString *)forStatusDepictCard:(Card *)aCard {
    SetCard *card = (SetCard *)aCard;
    
    NSString *cardAsString = [card.shape copy];
    for (int i = 1; i < [card.number integerValue]; i++) {
        cardAsString = [cardAsString stringByAppendingString:card.shape];
    }
    
    UIColor *color;
    if ([card.color isEqualToString:@"green"]) {
        color = [UIColor greenColor];
    } else if ([card.color isEqualToString:@"purple"]) {
        color = [UIColor purpleColor];
    } else if ([card.color isEqualToString:@"red"]) {
        color = [UIColor redColor];
    }
    
    UIColor *shadedColor = [color colorWithAlphaComponent:card.shading.floatValue];
    
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    return [[NSMutableAttributedString alloc] initWithString:cardAsString
                                                  attributes:@{NSForegroundColorAttributeName: shadedColor,
                                                               NSStrokeColorAttributeName: color,
                                                               NSStrokeWidthAttributeName: @-3,
                                                               NSFontAttributeName: font}];
    
}

#pragma mark MVC lifecycle

- (void)viewDidLoad {
    self.numberOfCardsToMatch = 3;
    [super viewDidLoad];
}


@end
