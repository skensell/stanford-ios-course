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

@interface PlayingAreaView()
@property (nonatomic, strong) Grid *grid;
@property (nonatomic) CGFloat cardAspectRatio;
@property (nonatomic) BOOL prefersWideCards;
@property (nonatomic) NSUInteger minimumNumberOfCardsOnBoard;
@property (nonatomic) NSUInteger maximumNumberOfCardsOnBoard;
@end

@implementation PlayingAreaView

#pragma mark - Grid

- (void)createGridWithCardAspectRatio:(CGFloat)aspectRatio
                     prefersWideCards:(BOOL)prefersWideCards
          minimumNumberOfCardsOnBoard:(NSUInteger)minimumNumberOfCardsOnBoard
          maximumNumberOfCardsOnBoard:(NSUInteger)maximumNumberOfCardsOnBoard {
    
    self.cardAspectRatio = aspectRatio;
    self.prefersWideCards = prefersWideCards;
    self.minimumNumberOfCardsOnBoard = minimumNumberOfCardsOnBoard;
    self.maximumNumberOfCardsOnBoard = maximumNumberOfCardsOnBoard;
    _grid = nil;
    
}

- (NSArray *)indicesOfEmptySpacesInGrid {
    // returns @[@[@1,@2],@[@3,@6]] if those are open spaces in grid
    
    NSMutableArray *indices = [[NSMutableArray alloc] init];
    
    for (int i=0; i < self.grid.rowCount; i++) {
        for (int j=0; j < self.grid.columnCount; j++) {
            
            UIView *hitView = [self hitTest:[self.grid centerOfCellAtRow:i inColumn:j] withEvent:nil];
            if (hitView == self) {
                // hit an empty space
                [indices addObject:@[@(i),@(j)]];
            }
            
        }
    }
    
    return indices;
}

- (CGRect)cardSpawnFrame {
    // just to the top left off the screen
    CGFloat x = self.bounds.origin.x - self.grid.cellSize.width - 100;
    CGFloat y = self.bounds.origin.y - self.grid.cellSize.height - 100;
    CGFloat w = self.grid.cellSize.width;
    CGFloat h = self.grid.cellSize.height;
    return [self slightlyInsideFrame:CGRectMake(x, y, w, h) fraction:0.95];
}

- (NSArray *)centersOfEmptySpacesInGrid {
    NSArray *indices = [self indicesOfEmptySpacesInGrid];
    NSMutableArray *centers = [[NSMutableArray alloc] init];
    for (NSArray *ij in indices) {
        [centers addObject:[NSValue valueWithCGPoint:[self.grid centerOfCellAtRow:[ij[0] intValue] inColumn:[ij[1] intValue]]]];
    }
    return centers;
}

#pragma mark - Private

- (CGRect)slightlyInsideFrame:(CGRect)frame fraction:(CGFloat)fraction {
    // scales height and width by percent and moves origin appropriateley
    if (!fraction) fraction = 0.95;
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
        _grid.minimumNumberOfCells = self.minimumNumberOfCardsOnBoard;
        _grid.prefersWideCards = self.prefersWideCards;
        
        if (!_grid.inputsAreValid) {
            NSLog(@"Invalid inputs for grid");
            NSLog(@"aspect ratio: %f", self.cardAspectRatio);
            NSLog(@"min number of cells: %d", self.minimumNumberOfCardsOnBoard);
        }
    }
    return _grid;
}

#pragma mark - View lifecycle

- (void)setup
{
    // possibly unnecessary
    self.contentMode = UIViewContentModeRedraw;
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

-(void)layoutSubviews {
    NSLog(@"Calling PlayingAreaView:layoutSubviews");
    [super layoutSubviews];
    
    if (!CGSizeEqualToSize(self.grid.size, self.bounds.size)){
        NSLog(@"INFO: Grid not equal to playingArea. Resetting grid to nil.");
        self.grid = nil;
    }
}

@end
