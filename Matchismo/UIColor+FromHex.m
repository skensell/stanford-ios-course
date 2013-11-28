//
//  UIColor+FromHex.m
//  glPrezi
//
//  Created by Belényesi Viktor on 09/18/2013.
//  Copyright (c) 2013 Prezi. All rights reserved.
//


#import "UIColor+FromHex.h"


@implementation UIColor (FromHex)

+ (UIColor *)fromHex:(NSUInteger)rgbValue {
    return [self fromHex:rgbValue alpha:1.0f];
}

+ (UIColor *)fromHex:(NSUInteger)rgbValue alpha:(float)alpha {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((float)((rgbValue & 0xFF00) >> 8))/255.0
                            blue:((float)(rgbValue & 0xFF))/255.0
                           alpha:alpha];
}

@end