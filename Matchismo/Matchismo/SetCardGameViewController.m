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


#pragma mark MVC lifecycle

- (void)viewDidLoad {
    self.numberOfCardsToMatch = 3;
    [super viewDidLoad];
}


@end
