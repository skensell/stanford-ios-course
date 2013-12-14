//
//  SetCard.h
//  Matchismo
//
//  Created by Scott Kensell on 11/22/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "Card.h"

typedef enum {
    OVAL = 1,
    SQUIGGLE,
    DIAMOND
} set_shape_t;

typedef enum {
    OPAQUE = 1,
    SHADED,
    HOLLOW
} set_shading_t;

typedef enum {
    ONE = 1,
    TWO,
    THREE
} set_number_t;

typedef enum {
    GREEN = 1,
    RED,
    PURPLE
} set_color_t;

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
