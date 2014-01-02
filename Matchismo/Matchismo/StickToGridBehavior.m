//
//  StickToGridBehavior.m
//  Matchismo
//
//  Created by Scott Kensell on 12/30/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "StickToGridBehavior.h"

// This behavior has 2 purposes:
// 1. After finding a set with 15 cards, the cards should regroup to 12.
// 2. When the dimensions of the grid change on rotation, the cards should animate to new spots.
//
// When necessary (if centers of cards do not align, or holes exist)
// each card should gravitate towards its nearest unoccupied center.
// If that center becomes occupied, update the nearest unoccupied center for the card.
// Once they reach the appropriate centers, animate frame to proper size.
//


@interface StickToGridBehavior()
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (nonatomic, strong) UIPushBehavior *push;
@property (nonatomic, strong) UIDynamicItemBehavior *animationOptions;
@end

@implementation StickToGridBehavior

-(UICollisionBehavior *)collision {
    if (!_collision) {
        _collision = [[UICollisionBehavior alloc] init];
        _collision.translatesReferenceBoundsIntoBoundary = YES;
    }
    return _collision;
}

-(UIPushBehavior *)push {
    if (!_push) {
        _push = [[UIPushBehavior alloc] init];
    }
    return _push;
}

- (UIDynamicItemBehavior *)animationOptions
{
    if (!_animationOptions) {
        _animationOptions = [[UIDynamicItemBehavior alloc] init];
        _animationOptions.allowsRotation = NO;
    }
    return _animationOptions;
}


-(void)addItem:(id <UIDynamicItem>)item {
    [self.collision addItem:item];
    [self.push addItem:item];
    [self.animationOptions addItem:item];
}

-(void)removeItem:(id <UIDynamicItem>)item {
    [self.collision removeItem:item];
    [self.push removeItem:item];
    [self.animationOptions addItem:item];
}

-(instancetype)init {
    self = [super init];
    [self addChildBehavior:self.collision];
    [self addChildBehavior:self.push];
    [self addChildBehavior:self.animationOptions];
    return self;
}

@end
