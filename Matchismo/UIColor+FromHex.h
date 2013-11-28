//
//  UIColor+FromHex.h
//  glPrezi
//
//  Created by Belényesi Viktor on 09/18/2013.
//  Copyright (c) 2013 Prezi. All rights reserved.
//


@interface UIColor (FromHex)

+ (UIColor *)fromHex:(NSUInteger)rgbValue;
+ (UIColor *)fromHex:(NSUInteger)rgbValue alpha:(float)alpha;

@end
