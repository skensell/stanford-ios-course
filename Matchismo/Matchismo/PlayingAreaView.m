//
//  PlayingAreaView.m
//  Matchismo
//
//  Created by Scott Kensell on 12/26/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "PlayingAreaView.h"
#import "CardView.h"
#import "Grid.h"
#import "Common.h"

@interface PlayingAreaView()
@property (nonatomic, strong) Grid *grid;
@property (nonatomic) CGFloat cardAspectRatio;
@property (nonatomic) BOOL prefersWideCards;
@property (nonatomic) NSUInteger minimumNumberOfCardsOnBoard;
@property (nonatomic) NSUInteger maximumNumberOfCardsOnBoard;

@property (nonatomic, strong, readwrite) NSArray *indicesOfHolesInGrid;
@property (nonatomic, strong, readwrite) NSArray *indicesOfEmptySpacesInGrid;
@property (nonatomic, strong, readwrite) NSArray *cardViewsInVisualOrder;

@property (nonatomic) BOOL resolved;
@property (nonatomic) BOOL gridLoadedAtLeastOnce;
@end

@implementation PlayingAreaView

#pragma mark - Grid

- (void)resetGridWithCardAspectRatio:(CGFloat)aspectRatio
                     prefersWideCards:(BOOL)prefersWideCards
          minimumNumberOfCardsOnBoard:(NSUInteger)minimumNumberOfCardsOnBoard
          maximumNumberOfCardsOnBoard:(NSUInteger)maximumNumberOfCardsOnBoard {
    
    self.cardAspectRatio = aspectRatio;
    self.prefersWideCards = prefersWideCards;
    self.minimumNumberOfCardsOnBoard = minimumNumberOfCardsOnBoard;
    self.maximumNumberOfCardsOnBoard = maximumNumberOfCardsOnBoard;
    _grid = nil;
    
}

#pragma mark - Computed outputs

- (void)computeOutputs {
    
    NSMutableArray *indicesOfEmptySpaces = [[NSMutableArray alloc] init];
    NSMutableArray *potentialHoleIndices = [[NSMutableArray alloc] init];
    NSMutableArray *indicesOfHoles = [[NSMutableArray alloc] init];
    NSMutableArray *cardViewsInVisualOrder = [[NSMutableArray alloc] init];
    

    for (int i=0; i < self.grid.rowCount; i++) {
        for (int j=0; j < self.grid.columnCount; j++) {
            UIView *hitView = [self hitTest:[self.grid centerOfCellAtRow:i inColumn:j] withEvent:nil];
            if (hitView == self) {
                // hit an empty space
                [indicesOfEmptySpaces addObject:@[@(i),@(j)]];
                [potentialHoleIndices addObject:@[@(i),@(j)]];
            } else {
                // hit a cardView
                if ([potentialHoleIndices count]) {
                    [indicesOfHoles addObjectsFromArray:potentialHoleIndices];
                    [potentialHoleIndices removeAllObjects];
                }
                if ([hitView isKindOfClass:[CardView class]]) {
                    [cardViewsInVisualOrder addObject:hitView];
                } else {
                    ERROR(@"Found a non cardview in playingarea.");
                }
            }
            
        }
    }
    
    // holes on the last row of cards are not actually holes
    if ([indicesOfHoles count]) {
        CardView *lastCardView = [cardViewsInVisualOrder lastObject];
        int lastRowOfCards = floor(lastCardView.center.y / self.grid.cellSize.height);
        while ([[indicesOfHoles lastObject][0] integerValue] == lastRowOfCards) {
            [indicesOfHoles removeLastObject];
        }
    }
    
    DEBUG(@"Computed outputs: %d %d %d", [cardViewsInVisualOrder count], [indicesOfEmptySpaces count], [indicesOfHoles count]);
    
    self.cardViewsInVisualOrder = cardViewsInVisualOrder;
    self.indicesOfHolesInGrid = indicesOfHoles;
    self.indicesOfEmptySpacesInGrid = indicesOfEmptySpaces;
    self.resolved = YES;
}

- (NSArray *)indicesOfEmptySpacesInGrid {
    // returns @[@[@1,@2],@[@3,@6]] if those are open spaces in grid
    if (!_indicesOfEmptySpacesInGrid) _indicesOfEmptySpacesInGrid = [[NSArray alloc] init];
    if (!self.resolved) [self computeOutputs];
    
    return _indicesOfEmptySpacesInGrid;
}

- (NSArray *)indicesOfHolesInGrid {
    if (!_indicesOfHolesInGrid) _indicesOfHolesInGrid = [[NSArray alloc] init];
    if (!self.resolved) [self computeOutputs];
    
    return _indicesOfHolesInGrid;
}

- (NSArray *)cardViewsInVisualOrder {
    if (!_cardViewsInVisualOrder) _cardViewsInVisualOrder = [[NSArray alloc] init];
    if (!self.resolved) [self computeOutputs];
    
    return _cardViewsInVisualOrder;
}

- (BOOL)hasHolesInGrid {
    return [self.indicesOfHolesInGrid count] > 0;
}

- (CGRect)cardSpawnFrame {
    // just to the top left off the screen
    CGFloat x = self.bounds.origin.x - self.grid.cellSize.width - 100;
    CGFloat y = self.bounds.origin.y - self.grid.cellSize.height - 100;
    CGFloat w = self.grid.cellSize.width;
    CGFloat h = self.grid.cellSize.height;
    return [self slightlyInsideFrame:CGRectMake(x, y, w, h) fraction:CARDVIEW_FRAME_FRACTION];
}

- (NSArray *)centersOfEmptySpacesInGrid {
    NSArray *indices = self.indicesOfEmptySpacesInGrid;
    NSMutableArray *centers = [[NSMutableArray alloc] init];
    for (NSArray *ij in indices) {
        [centers addObject:[NSValue valueWithCGPoint:[self.grid centerOfCellAtRow:[ij[0] intValue] inColumn:[ij[1] intValue]]]];
    }
    return centers;
}

- (CGSize)cardViewSize {
    return CGSizeMake(self.cellSize.width*CARDVIEW_FRAME_FRACTION, self.cellSize.height*CARDVIEW_FRAME_FRACTION);
}

- (CGSize)cellSize {
    return self.grid.cellSize;
}

- (NSUInteger)rowCount {
    return self.grid.rowCount;
}

- (NSUInteger)columnCount {
    return self.grid.columnCount;
}

- (CGPoint)centerOfCellAtRow:(NSUInteger)row inColumn:(NSUInteger)column {
    return [self.grid centerOfCellAtRow:row inColumn:column];
}

- (CGRect)frameOfCellAtRow:(NSUInteger)row inColumn:(NSUInteger)column {
    return [self.grid frameOfCellAtRow:row inColumn:column];
}

- (CGRect)frameOfCardViewInCellAtRow:(NSUInteger)row inColumn:(NSUInteger)column {
    return [self slightlyInsideFrame:[self.grid frameOfCellAtRow:row inColumn:column] fraction:CARDVIEW_FRAME_FRACTION];
}

#pragma mark - Private

- (CGRect)slightlyInsideFrame:(CGRect)frame fraction:(CGFloat)fraction {
    // scales height and width by percent and moves origin appropriateley
    // could be moved to more general utility
    if (!fraction) fraction = CARDVIEW_FRAME_FRACTION;
    CGFloat h = frame.size.height * fraction;
    CGFloat w = frame.size.width * fraction;
    CGPoint origin = CGPointMake(frame.origin.x + (1 - fraction) * frame.size.width / 2,
                                 frame.origin.y + (1 - fraction) * frame.size.height / 2);
    
    return CGRectMake(origin.x, origin.y, w, h);
}

- (Grid *)grid {
    if (!_grid) {
        _grid = [[Grid alloc] init];
        _grid.size = self.bounds.size;
        _grid.cellAspectRatio = self.cardAspectRatio;
        _grid.minimumNumberOfCells = self.maximumNumberOfCardsOnBoard; // need to allow space for a maximum deal
        _grid.prefersWideCards = self.prefersWideCards;
        
        if (!_grid.inputsAreValid && self.gridLoadedAtLeastOnce) {
            WARNING(@"Invalid inputs for grid: %f %d", self.cardAspectRatio, self.minimumNumberOfCardsOnBoard);
            _grid = nil;
        } else {
            INFO(@"Grid inputs valid.");
            self.gridLoadedAtLeastOnce = YES;
        }
    }
    return _grid;
}

#pragma mark - View lifecycle

- (void)setup
{
    // possibly unnecessary
    self.contentMode = UIViewContentModeRedraw;
    self.clipsToBounds = YES;
    self.opaque = NO;
    self.gridLoadedAtLeastOnce = NO;
    
}

// I need this because I'm being awoken from the freeze-dried storyboard state
- (void)awakeFromNib
{
    [self setup];
}

// The designated initializer if inserting from code.
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)willRemoveSubview:(UIView *)subview {
    self.resolved = NO;
}

- (void)didAddSubview:(UIView *)subview {
    self.resolved = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!CGSizeEqualToSize(self.grid.size, self.bounds.size)){
        // Happens at startup and on device rotation
        INFO(@"Grid not equal to playingArea. Resetting grid to nil.");
        self.grid = nil;
    }
    
    self.resolved = NO;
}

@end
