//
//  MatchedBehavior.m
//  Matchismo
//
//  Created by Scott Kensell on 12/27/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "MatchedBehavior.h"

@interface MatchedBehavior()
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UICollisionBehavior *collision;
@end

@implementation MatchedBehavior


-(UIGravityBehavior *)gravity {
    if (!_gravity) {
        _gravity = [[UIGravityBehavior alloc] init];
    }
    return _gravity;
}

-(UICollisionBehavior *)collision {
    if (!_collision) {
        _collision = [[UICollisionBehavior alloc] init];
        _collision.translatesReferenceBoundsIntoBoundary = YES;
    }
    return _collision;
}

-(void)addItem:(id <UIDynamicItem>)item {
    [self.gravity addItem:item];
    [self.collision addItem:item];
}

-(void)removeItem:(id <UIDynamicItem>)item {
    [self.gravity removeItem:item];
    [self.collision removeItem:item];
}

-(instancetype)init {
    self = [super init];
    [self addChildBehavior:self.gravity];
    [self addChildBehavior:self.collision];
    return self;
}

@end
