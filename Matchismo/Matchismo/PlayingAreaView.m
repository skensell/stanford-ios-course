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

@end

@implementation PlayingAreaView

#pragma mark - Grid

- (void)createGridWithCardAspectRatio:(CGFloat)aspectRatio
                     prefersWideCards:(BOOL)prefersWideCards
          minimumNumberOfCardsOnBoard:(NSUInteger)minimumNumberOfCardsOnBoard
          maximumNumberOfCardsOnBoard:(NSUInteger)maximumNumberOfCardsOnBoard {
    
    _grid = [[Grid alloc] init];
    _grid.size = self.bounds.size;
    _grid.cellAspectRatio = aspectRatio;
    _grid.minimumNumberOfCells = minimumNumberOfCardsOnBoard;
    _grid.prefersWideCards = prefersWideCards;
    
    if (!_grid.inputsAreValid) {
        NSLog(@"Invalid inputs for grid");
        NSLog(@"aspect ratio: %f", aspectRatio);
        NSLog(@"min number of cells: %d", minimumNumberOfCardsOnBoard);
    }
    
}

- (Grid *)grid {
    if (!_grid) _grid = [[Grid alloc] init];
    return _grid;
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

#pragma mark - Animations

- (void)animateCardViewsIntoEmptySpaces:cardViews {
    NSArray *indicesOfEmptySpacesInGrid = [self indicesOfEmptySpacesInGrid];
    
    if ([indicesOfEmptySpacesInGrid count] < [cardViews count]) {
        NSLog(@"ERROR: More cards to place on grid than empty spaces.");
        return;
    }
    
    int idx=0;
    for (CardView *cardView in cardViews) {
        int i = [indicesOfEmptySpacesInGrid[idx][0] intValue];
        int j = [indicesOfEmptySpacesInGrid[idx][1] intValue];
        
        cardView.transform = CGAffineTransformMakeRotation(M_PI);
        [UIView animateWithDuration:0.5 delay:0.04*idx options:0 animations:^{
            cardView.center = [self.grid centerOfCellAtRow:i inColumn:j];
            cardView.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL fin){
            if (fin) {
            }
        }];
        
        idx++;
    }
}

#pragma mark - Private

- (CGRect)cardSpawnFrame {
    // just to the top left off the screen
    CGFloat x = self.bounds.origin.x - self.grid.cellSize.width - 100;
    CGFloat y = self.bounds.origin.y - self.grid.cellSize.height - 100;
    CGFloat w = self.grid.cellSize.width;
    CGFloat h = self.grid.cellSize.height;
    return [self slightlyInsideFrame:CGRectMake(x, y, w, h) fraction:0.95];
}

- (CGRect)slightlyInsideFrame:(CGRect)frame fraction:(CGFloat)fraction {
    // scales height and width by percent and moves origin appropriateley
    if (!fraction) fraction = 0.95;
    CGFloat h = frame.size.height * fraction;
    CGFloat w = frame.size.width * fraction;
    CGPoint origin = CGPointMake(frame.origin.x + (1 - fraction) * frame.size.width / 2,
                                 frame.origin.y + (1 - fraction) * frame.size.height / 2);
    
    return CGRectMake(origin.x, origin.y, w, h);
}

#pragma mark - View lifecycle

- (void)setup
{
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

@end
