//
//  SetCard.h
//  Matchismo
//
//  Created by Scott Kensell on 11/22/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "Card.h"

@interface SetCard : Card

@property (nonatomic, strong) NSString *shape;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSNumber *shading; // alpha
@property (nonatomic, strong) NSString *color;

- (instancetype)initWithShape:(NSString *)shape
                   withNumber:(NSNumber *)number
                  withShading:(NSNumber *)shading
                    withColor:(NSString *)color;

+ (NSArray *)validShapes;
+ (NSArray *)validNumbers;
+ (NSArray *)validShadings;
+ (NSArray *)validColors;
+ (NSArray *)validAttributes;

@end
