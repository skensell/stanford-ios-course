//
//  SetCard.m
//  Matchismo
//
//  Created by Scott Kensell on 11/22/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "SetCard.h"

@implementation SetCard

- (instancetype)initWithShape:(set_shape_t)shape
                   withNumber:(set_number_t)number
                  withShading:(set_shading_t)shading
                    withColor:(set_color_t)color {
    
    self = [super init];
    if (self) {
        
        _shape = shape;
        _number = number;
        _shading = shading;
        _color = color;
        
    }
    return self;
}


# pragma mark -- Matching logic

- (int)match:(NSArray *)otherCards {
    int score = 0;
    
    if ([otherCards count] != 2) {
        NSLog(@"Match returns 0");
        return 0;
    }
    
    NSArray *cards = [otherCards arrayByAddingObject:self];
    for (NSString *attribute in [SetCard validAttributes]){
        
        int goodMatch = [SetCard allSameOrDifferentCards:cards
                                  withRespectToAttribute:attribute];
        if (goodMatch) {
            score += goodMatch;
        } else {
            score = 0;
            break;
        }
    }
    
    return score;
}


+ (int)allSameOrDifferentCards:(NSArray *)cards
        withRespectToAttribute:(NSString *)attribute {
    int goodMatch = 0;
    
    if ([cards count] != 3 || ![[SetCard validAttributes] containsObject:attribute]) {
        return 0;
    }
    
    NSMutableSet *attributeSet = [[NSMutableSet alloc] init];
    
    for (SetCard *card in cards){
        SEL property = NSSelectorFromString(attribute);
        if ([card respondsToSelector:property]){
            [attributeSet addObject:[NSNumber numberWithInt:(NSUInteger)[card performSelector:property]]];
        }
    }
    
    if ([attributeSet count] == 1) {
        NSLog(@"All are the same with respect to %@", attribute);
        goodMatch = 1;
    } else if ([attributeSet count] == 3) {
        NSLog(@"All are different with respect to %@", attribute);
        goodMatch = 2;
    }
    
    return goodMatch;
}

#pragma mark -- utility methods



//
////
////+ (NSArray *)validShapes {
////    return @[@"●", @"▲", @"■"];
////}
////
////+ (NSArray *)validNumbers {
////    return @[@1, @2, @3];
////}
////
////+ (NSArray *)validShadings {
////    return @[@0.0, @0.35, @1.0];
////}
////
////+ (NSArray *)validColors {
////    return @[@"green", @"red", @"purple"];
//}

+ (NSArray *)validAttributes {
    return @[@"shape", @"number", @"shading", @"color"];
}


@end
