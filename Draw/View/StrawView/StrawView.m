//
//  StrawView.m
//  Draw
//
//  Created by gamy on 13-1-30.
//
//

#import "StrawView.h"

#define VIEW_SIZE (ISIPAD ? 88.0 : 44.0)
#define OUT_CIRCLE_R (VIEW_SIZE/2.0-2)
#define COLOR_CIRCLE_R (OUT_CIRCLE_R-2)
#define IN_CIRCLE_R (VIEW_SIZE/5.0)

@implementation StrawView

- (void)dealloc{
    PPRelease(_color);
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setColor:(UIColor *)color
{
    if (_color != color) {
        PPRelease(_color);
        _color = [color retain];
        [self setNeedsDisplay];
    }
}

+ (id)strawViewWithColor:(UIColor *)color
{
    StrawView *view = [[StrawView alloc] initWithFrame:CGRectMake(0, 0, VIEW_SIZE, VIEW_SIZE)];
    [view setColor:color];
    return [view autorelease];
}

- (CGRect)subRect:(CGRect)rect radius:(CGFloat)radius
{
    CGFloat d = radius * 2;
    CGFloat x = (CGRectGetWidth(rect) - d) / 2 + CGRectGetMinX(rect);
    CGFloat y = (CGRectGetHeight(rect) - d) / 2 + CGRectGetMinY(rect);
    return CGRectMake(x, y, d, d);
}



- (void)drawRect:(CGRect)rect
{
    // Drawing code

//    CGRect rect = [self subRect:rect radius:<#(CGFloat)#>]
    //draw three circles
    
    [super drawRect:rect];
}


@end
