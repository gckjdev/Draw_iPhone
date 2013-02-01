//
//  ColorPoint.m
//  Draw
//
//  Created by gamy on 12-12-25.
//
//

#import "ColorPoint.h"

//48*50

#define VALUE(x) (ISIPAD ? x*2 : x)

#define WIDTH VALUE(26.0)
#define HEIGHT VALUE(27.0)
#define CIRCLE_WIDTH VALUE(23.0)
#define SELECTED_CIRCLE_WIDTH VALUE(8.0)

@interface ColorPoint()
{
    UIColor *_selectedPointColor;
}
@end

@implementation ColorPoint
@synthesize color = _color;
@synthesize delegate = _delegate;

- (void)dealloc
{
    self.delegate = nil;
    PPRelease(_color);
    PPRelease(_selectedPointColor);
    [super dealloc];
}



- (id)initWithColor:(DrawColor *)color
{
    self = [super initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    if (self) {
        self.color = color;
        self.backgroundColor = [UIColor clearColor];
        _selectedPointColor = [[UIColor colorWithRed:163/255.0
                                              green:163/255.0
                                               blue:163/255.0
                                              alpha:1] retain];
        [self addTarget:self action:@selector(clickColorPoint:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

+ (id)pointWithColor:(DrawColor *)color
{
    id point = [[[ColorPoint alloc] initWithColor:color] autorelease];
    return point;
}

- (void)setColor:(DrawColor *)color
{
    if (_color != color) {
        PPRelease(_color);
        _color = [color retain];
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //draw circle
    
    CGContextSetFillColorWithColor(context, _color.CGColor);
    
    CGFloat edge = (WIDTH - CIRCLE_WIDTH)/2.0;
    CGSize offset = CGSizeMake(edge, edge);
    CGContextSetShadowWithColor(context, offset, edge/2.0, [UIColor blackColor].CGColor);
    CGRect circle = CGRectMake(edge, edge, CIRCLE_WIDTH, CIRCLE_WIDTH);
    CGContextFillEllipseInRect(context, circle);
    
    if (self.isSelected) {
        //draw selected
        CGContextSetShadow(context, CGSizeMake(0, 0), 0);
        CGFloat x = CGRectGetMidX(circle) - (SELECTED_CIRCLE_WIDTH/2);
        CGFloat y = CGRectGetMidY(circle) - (SELECTED_CIRCLE_WIDTH/2);
        CGRect selectRect = CGRectMake(x, y, SELECTED_CIRCLE_WIDTH, SELECTED_CIRCLE_WIDTH);
        CGContextSetFillColorWithColor(context, _selectedPointColor.CGColor);
            CGContextFillEllipseInRect(context, selectRect);
    }
    // Drawing code
    [super drawRect:rect];
}

- (void)clickColorPoint:(id)sender
{
    [self setSelected:!self.selected];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectColorPoint:)]) {
        [self.delegate didSelectColorPoint:self];
    }
}

@end
