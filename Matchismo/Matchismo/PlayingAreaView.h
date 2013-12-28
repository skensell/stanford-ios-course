//
//  PlayingAreaView.h
//  Matchismo
//
//  Created by Scott Kensell on 12/26/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayingAreaView : UIView

// call at least once
- (void)createGridWithCardAspectRatio:(CGFloat)aspectRatio
                     prefersWideCards:(BOOL)prefersWideCards
          minimumNumberOfCardsOnBoard:(NSUInteger)minimumNumberOfCardsOnBoard
          maximumNumberOfCardsOnBoard:(NSUInteger)maximumNumberOfCardsOnBoard;

// computed outputs
- (NSArray *)indicesOfEmptySpacesInGrid; // array of @[3,5], @[4,6], ...
- (NSArray *)centersOfEmptySpacesInGrid; // array of NSValue's of CGPoint
- (CGRect)cardSpawnFrame;

@end
