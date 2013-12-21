//
//  SetCard.h
//  Matchismo
//
//  Created by Scott Kensell on 11/22/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "Card.h"
#import "SetCardAttributes.h"

@interface SetCard : Card

@property (nonatomic) set_shape_t shape;
@property (nonatomic) set_shading_t shading;
@property (nonatomic) set_number_t number;
@property (nonatomic) set_color_t color;

- (instancetype)initWithShape:(NSUInteger)shape
                   withNumber:(NSUInteger)number
                  withShading:(NSUInteger)shading
                    withColor:(NSUInteger)color;

+ (NSArray *)validAttributes;

@end
