//
//  SetCardView.h
//  SuperCard
//
//  Created by Scott Kensell on 12/12/13.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetCardAttributes.h"

@interface SetCardView : UIView

@property (nonatomic) set_shape_t shape;
@property (nonatomic) set_shading_t shading;
@property (nonatomic) set_number_t number;
@property (nonatomic) set_color_t color;

@end
