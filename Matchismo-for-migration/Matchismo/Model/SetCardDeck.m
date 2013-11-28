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
      
        for (NSString *shape in [SetCard validShapes]){
            for (NSNumber *number in [SetCard validNumbers]) {
                for (NSNumber *shading in [SetCard validShadings]) {
                    for (NSString *colorString in [SetCard validColors]){
                       
                        SetCard *card = [[SetCard alloc] initWithShape:shape
                                                            withNumber:number
                                                           withShading:shading
                                                             withColor:colorString];
                        
                        [self addCard:card];
                        
                    }
                }
            }
        }
        
    }
    return self;
}

@end
