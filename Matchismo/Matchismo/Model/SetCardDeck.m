//
//  SetCardDeck.m
//  Matchismo
//
//  Created by Scott Kensell on 11/22/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "SetCardDeck.h"
#import "SetCard.h"

@implementation SetCardDeck

- (instancetype)init {
    self = [super init];
    if (self) {
        for (int i = 1; i <=3; i++){
            for (int j = 1; j <=3; j++){
                for (int k = 1; k <=3; k++){
                    for (int l = 1; l <=3; l++){
                        SetCard *card = [[SetCard alloc] initWithShape:i
                                                            withNumber:j
                                                           withShading:k
                                                             withColor:l];
                        
                        [self addCard:card];
                    }
                }
            }
        }
        
    }
    return self;
}

@end
