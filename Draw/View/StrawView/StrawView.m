//
//  StrawView.m
//  Draw
//
//  Created by gamy on 13-1-30.
//
//

#import "StrawView.h"


#define VALUE(x) (ISIPAD ? 2.0*x : x)

#define VIEW_SIZE VALUE(60.0)
#define CONTENT_VIEW_SIZE VALUE(52.0)
#define OUT_CIRCLE_WIDTH VALUE(1)
#define IN_CIRCLE_WIDTH VALUE(1)
#define COLOR_CIRCLE_WIDTH VALUE(18)
#define CIRCLE_BLUR VALUE(1)

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
    CGRect subRect = CGRectMake(x, y, d, d);
//    PPDebug(@"radius = %f, Rect = %@, SubRect = %@", radius, NSStringFromCGRect(rect), NSStringFromCGRect(subRect));
    return subRect;
}


#define CIRCLE_LINE_COLOR [[UIColor lightGrayColor] CGColor]

- (void)drawRect:(CGRect)rect
{
    // Drawing code

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //color circle
    CGContextSetStrokeColorWithColor(context, _color.CGColor);
    CGContextSetLineWidth(context, COLOR_CIRCLE_WIDTH);
    CGFloat radius = (CONTENT_VIEW_SIZE - COLOR_CIRCLE_WIDTH) / 2;
    CGRect subRect = [self subRect:rect radius:radius];
    CGContextStrokeEllipseInRect(context, subRect);
    
    //out circle
    CGContextSetStrokeColorWithColor(context, CIRCLE_LINE_COLOR);
    CGContextSetLineWidth(context, OUT_CIRCLE_WIDTH);
    CGContextSetShadow(context, CGSizeMake(-1, 0), CIRCLE_BLUR);
    radius = (CONTENT_VIEW_SIZE - OUT_CIRCLE_WIDTH) / 2;
    subRect = [self subRect:rect radius:radius];
    CGContextStrokeEllipseInRect(context, subRect);
    
    CGContextSetStrokeColorWithColor(context, CIRCLE_LINE_COLOR);
    CGContextSetLineWidth(context, IN_CIRCLE_WIDTH);
    radius = CONTENT_VIEW_SIZE/2 - COLOR_CIRCLE_WIDTH;
    subRect = [self subRect:rect radius:radius];
    CGContextStrokeEllipseInRect(context, subRect);
        
    [super drawRect:rect];
}


@end
