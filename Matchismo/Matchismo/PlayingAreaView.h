//
//  PlayingAreaView.h
//  Matchismo
//
//  Created by Scott Kensell on 12/26/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CARDVIEW_FRAME_FRACTION 0.95 // the fraction of the grid cell which a cardView takes up

@interface PlayingAreaView : UIView

// To use this class call this at least once

- (void)createGridWithCardAspectRatio:(CGFloat)aspectRatio
                     prefersWideCards:(BOOL)prefersWideCards
          minimumNumberOfCardsOnBoard:(NSUInteger)minimumNumberOfCardsOnBoard
          maximumNumberOfCardsOnBoard:(NSUInteger)maximumNumberOfCardsOnBoard;

// computed outputs

- (NSArray *)indicesOfEmptySpacesInGrid; // array of @[3,5], @[4,6], ...
- (NSArray *)centersOfEmptySpacesInGrid; // array of NSValue's of CGPoint
- (CGRect)cardSpawnFrame;
@property (nonatomic, readonly) CGSize cardViewSize; // 95% of cell size


// computed outputs from grid

@property (nonatomic, readonly) CGSize cellSize;
@property (nonatomic, readonly) NSUInteger rowCount;
@property (nonatomic, readonly) NSUInteger columnCount;
- (CGPoint)centerOfCellAtRow:(NSUInteger)row inColumn:(NSUInteger)column;
- (CGRect)frameOfCellAtRow:(NSUInteger)row inColumn:(NSUInteger)column;

// utilities

- (CGRect)slightlyInsideFrame:(CGRect)frame fraction:(CGFloat)fraction;

@end
