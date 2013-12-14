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

- (instancetype)initWithShape:(set_shape_t)shape
                   withNumber:(set_number_t)number
                  withShading:(set_shading_t)shading
                    withColor:(set_color_t)color;

+ (NSArray *)validAttributes;

@end
