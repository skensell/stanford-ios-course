//
//  CardGameViewController.h
//  Matchismo
//
//  Created by Scott Kensell on 11/14/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"

@interface CardGameViewController : UIViewController


// protected for subclasses
- (Deck *)createDeck; // abstract method

@end
