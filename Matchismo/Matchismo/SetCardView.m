//
//  SetCardView.m
//  SuperCard
//
//  Created by Scott Kensell on 12/12/13.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "SetCardView.h"

@implementation SetCardView

- (void)setShape:(set_shape_t)shape {
    _shape = shape;
    [self setNeedsDisplay];
}

- (void)setNumber:(set_number_t)number {
    _number = number;
    [self setNeedsDisplay];
}

- (void)setShading:(set_shading_t)shading {
    _shading = shading;
    [self setNeedsDisplay];
}

- (void)setColor:(set_color_t)color {
    _color = color;
    [self setNeedsDisplay];
}

#pragma mark - Drawing

#define CORNER_FONT_STANDARD_HEIGHT 180.0
#define CORNER_RADIUS 12.0

- (CGFloat)cornerScaleFactor { return self.bounds.size.height / CORNER_FONT_STANDARD_HEIGHT; }
- (CGFloat)cornerRadius { return CORNER_RADIUS * [self cornerScaleFactor]; }
- (CGFloat)cornerOffset { return [self cornerRadius] / 3.0; }

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self cornerRadius]];
    
    [roundedRect addClip];
    
    [[self cardBackgroundColor] setFill];
    UIRectFill(self.bounds);
    
    [[UIColor blackColor] setStroke];
    [roundedRect stroke];
    
    [self drawInside];
}

- (void)pushContextAndRotateUpsideDown
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, self.bounds.size.width, self.bounds.size.height);
    CGContextRotateCTM(context, M_PI);
}

- (void)pushContext {
    CGContextSaveGState(UIGraphicsGetCurrentContext());
}

- (void)popContext
{
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}

#define EFFECTIVE_WIDTH_RATIO 1.2 // creates whitespace around the shape

- (CGFloat)shapeWidth { return self.bounds.size.width / 4.0; }
- (CGFloat)shapeHeight { return self.bounds.size.height * (3.0/4.0); }
- (CGFloat)effectiveShapeWidth { return [self shapeWidth] * EFFECTIVE_WIDTH_RATIO; }

#define NUMBER_OF_STRIPES 50
#define STRIPE_WIDTH_RATIO 0.008// as a fraction of the view's height
#define STROKE_WIDTH_RATIO 0.015 // as a fraction of the average of the height and width of view

- (CGFloat)strokeWidth { return STROKE_WIDTH_RATIO * (self.bounds.size.width + self.bounds.size.height)/2.0; }
- (CGFloat)stripeWidth { return STRIPE_WIDTH_RATIO * self.bounds.size.height; }


- (void)drawInside {
    [[self theColor] setStroke];
    [self drawShapesUpsideDown:NO];
    [self drawShapesUpsideDown:YES];
    
}

- (void)drawShapesUpsideDown:(BOOL)upsideDown {
    if (upsideDown) [self pushContextAndRotateUpsideDown];
    
    CGPoint middle = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat xDelta;
    if (self.number % 2) {
        xDelta = [self shapeWidth]/2.0;
    } else {
        xDelta = -([self effectiveShapeWidth] - [self shapeWidth])/2.0;
    }
    
    // We always begin drawing a shape from it's middle-left
    CGPoint shapeOrigin = CGPointMake(
                                    middle.x-xDelta-(self.number/2)*[self effectiveShapeWidth],
                                    middle.y
                                    );
    
    for (int i=1; i <= self.number ; i++) {
        [self drawShapeAtPoint:shapeOrigin];
        shapeOrigin.x += [self effectiveShapeWidth];
    }
    
    if (upsideDown) [self popContext];
}

- (void)drawShapeAtPoint:(CGPoint)origin {
    // origin represents the middle left of the whole shape
    UIBezierPath *pencil = [UIBezierPath bezierPath];
    
    pencil.lineWidth = [self strokeWidth];
    [pencil moveToPoint:origin];
    
    switch (self.shape) {
        case SC_OVAL:
            [self drawHalfOfOvalAtPoint:origin withPencil:pencil];
            break;
            
        case SC_DIAMOND:
            [self drawHalfOfDiamondAtPoint:origin withPencil:pencil];
            break;
            
        case SC_SQUIGGLE:
            [self drawHalfOfSquiggleAtPoint:origin withPencil:pencil];
            break;
            
        default:
            break;
    }
    
    // handles shading
    [pencil moveToPoint:origin];
    switch (self.shading) {
        case SC_HOLLOW:
            break;
            
        case SC_SHADED:
            [self stripeShape:pencil];
            break;
        
        case SC_OPAQUE:
            [self fillShape:pencil];
            break;
            
        default:
            break;
    }
    
}

#define SQUIGGLE_VOFFSET_PERCENTAGE .8 // this * shape-height/2 is how high up the first endpoint of squiggle curve is
#define SQUIGGLE_HOFFSET_PERCENTAGE .875

- (void)drawHalfOfSquiggleAtPoint:(CGPoint)origin withPencil:(UIBezierPath *)pencil {
    CGFloat yDelta = [self shapeHeight]*SQUIGGLE_VOFFSET_PERCENTAGE/2.0;
    CGFloat xDelta = [self shapeWidth]*(1 - SQUIGGLE_HOFFSET_PERCENTAGE);
    
    CGPoint bottomLeft = CGPointMake(origin.x + xDelta, origin.y);
    CGPoint topLeft1 = CGPointMake(origin.x, origin.y - yDelta*7.0/8.0);
    CGPoint topLeft2 = CGPointMake(topLeft1.x, topLeft1.y - yDelta*1.0/8.0);
    CGPoint topRight = CGPointMake(origin.x + [self shapeWidth] - 2*xDelta, origin.y - yDelta);
    CGPoint bottomRight = CGPointMake(origin.x + [self shapeWidth]- xDelta, origin.y);
    
    CGFloat controlXOffset = (1 - SQUIGGLE_HOFFSET_PERCENTAGE)*[self shapeWidth]*2;
    CGFloat controlYOffset = (1 - SQUIGGLE_VOFFSET_PERCENTAGE)*[self shapeHeight];
    
    [pencil moveToPoint:bottomLeft]; // move in a tad
    [pencil addQuadCurveToPoint:topLeft1
                   controlPoint:[self halfwayBetweenPoint:bottomLeft andPoint:topLeft1 withHorizontalOffset:controlXOffset withVerticalOffset:0]];
    
    [pencil addQuadCurveToPoint:topLeft2
                   controlPoint:[self halfwayBetweenPoint:topLeft1 andPoint:topLeft2 withHorizontalOffset:-controlXOffset/8.0 withVerticalOffset:0]];
    
    [pencil addQuadCurveToPoint:topRight
                   controlPoint:[self halfwayBetweenPoint:topLeft2 andPoint:topRight withHorizontalOffset:0 withVerticalOffset:-controlYOffset]];
    
    [pencil addQuadCurveToPoint:bottomRight
                   controlPoint:[self halfwayBetweenPoint:topRight andPoint:bottomRight withHorizontalOffset:controlXOffset withVerticalOffset:0]];
    
    [pencil stroke];
    
}

- (CGPoint)halfwayBetweenPoint:(CGPoint)p andPoint:(CGPoint)q
          withHorizontalOffset:(CGFloat)hoffset
            withVerticalOffset:(CGFloat)voffset{
    CGFloat x = (p.x + q.x)/2.0;
    CGFloat y = (p.y + q.y)/2.0;
    x += hoffset;
    y += voffset;
    return CGPointMake(x, y);
}

- (void)drawHalfOfDiamondAtPoint:(CGPoint)origin withPencil:(UIBezierPath *)pencil {
    [pencil addLineToPoint:CGPointMake(
                                       origin.x + [self shapeWidth]/2.0,
                                       origin.y - [self shapeHeight]/2.0
                                       )];
    [pencil addLineToPoint:CGPointMake(
                                       origin.x + [self shapeWidth],
                                       origin.y
                                       )];
    [pencil stroke];
}

- (void)drawHalfOfOvalAtPoint:(CGPoint)origin withPencil:(UIBezierPath *)pencil {
    // requires origin = midleft
    // ends at midright
    CGFloat radius = [self shapeWidth]/2.0; //always
    CGPoint centerOfArc = CGPointMake(
                                      origin.x + [self shapeWidth]/2.0,
                                      origin.y - ([self shapeHeight] - [self shapeWidth])/2.0
                                      );
    CGFloat yDelta = MAX(0, ([self shapeHeight] - [self shapeWidth])/2.0);
    CGPoint startOfArc = CGPointMake(
                                     origin.x,
                                     origin.y - yDelta
                                     );
    

    [pencil addLineToPoint:startOfArc];

    
    [self pushContext]; // clip a rectangle around the shape
    CGRect shapeRect = CGRectMake(origin.x - [self strokeWidth]/2,
                                  origin.y - [self shapeHeight]/2.0 - [self strokeWidth]/2,
                                  [self shapeWidth] + [self strokeWidth],
                                  [self shapeHeight] + [self strokeWidth]);
    UIBezierPath *clippingArea = [UIBezierPath bezierPathWithRect:shapeRect];
    [clippingArea addClip];

    [[self theColor] setStroke];
    [pencil addArcWithCenter:centerOfArc
                      radius:radius
                  startAngle:M_PI
                    endAngle:0.0
                   clockwise:YES];
    
    [pencil addLineToPoint:CGPointMake(startOfArc.x + [self shapeWidth], startOfArc.y)];
    [pencil addLineToPoint:CGPointMake(origin.x + [self shapeWidth], origin.y)];
    [pencil stroke];
    [self popContext]; // pencil.currentpoint will still be midright but there will be no clip
}

- (void)fillShape:(UIBezierPath *)pencil {
    [self pushContext];
    
    [[self theColor] setFill];
    [pencil closePath];
    [pencil fill];
    
    [self popContext];
}

- (void)stripeShape:(UIBezierPath *)pencil {
    // requires current point at midleft
    [self pushContext];
    
    [[[self theColor] colorWithAlphaComponent:0.5] setStroke];
    pencil.lineWidth = [self stripeWidth];
    [pencil addClip]; // clips within shape drawn so far
    
    CGPoint basePoint = pencil.currentPoint; // should be midleft
    while (basePoint.y - pencil.currentPoint.y < [self shapeHeight]/2 ) {
        [pencil addLineToPoint:CGPointMake(
                                           pencil.currentPoint.x + [self shapeWidth],
                                           pencil.currentPoint.y
                                           )];
        [pencil moveToPoint:CGPointMake(
                                        pencil.currentPoint.x - [self shapeWidth],
                                        pencil.currentPoint.y - 2.5*pencil.lineWidth
                                        )];
        
    }
    [pencil stroke];
    
    [self popContext];
}

- (UIColor *)theColor {
    switch (self.color) {
        case SC_RED:
            return [UIColor redColor];
            break;
        case SC_GREEN:
            return [UIColor colorWithRed:34.0/256.0 green:134.0/256.0 blue:34.0/256.0 alpha:1];
            break;
        case SC_PURPLE:
            return [UIColor purpleColor];
        default:
            return [UIColor blueColor];
            break;
    }
}

- (UIColor *)cardBackgroundColor {
    return (self.isChosen)? [UIColor yellowColor] : [UIColor whiteColor];
}

#pragma mark - Animations


#pragma mark - View lifecycle

- (void)setup
{
    self.backgroundColor = nil;
    self.opaque = NO;
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
