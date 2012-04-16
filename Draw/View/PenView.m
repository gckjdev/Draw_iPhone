//
//  PenView.m
//  DrawViewTest
//
//  Created by  on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PenView.h"
#import "ShareImageManager.h"

#define VIEW_FRAME CGRectMake(0,0,21,33)
#define TOTAL_HEIGHT 30.0
#define BODY_HEIGHT 20.0
#define BODY_WIDTH 17.5



@implementation PenView
@synthesize penColor = _penColor;


- (void)initMaskImage
{
    if (!maskImage) {
        maskImage = [[ShareImageManager defaultManager] penMaskImage].CGImage;
        CGImageRetain(maskImage);
        self.backgroundColor = [UIColor clearColor];                        
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initMaskImage];
    }
    return self;
}

- (id)initWithPenColor:(DrawColor *)penColor
{
    self = [self initWithFrame:VIEW_FRAME];
    if (self) {
        self.penColor = penColor;
    }
    return self;
}

+ (PenView *)viewWithColor:(DrawColor *)color
{
    return [[[PenView alloc] initWithPenColor:color] autorelease];
}
- (void)dealloc
{
    CGImageRelease(maskImage);
    [_penColor release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    
    [self initMaskImage];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.penColor.CGColor);
    
    const CGFloat X = 1.5;
    const CGFloat Y = 30;
    const CGFloat xArray[] = {X + BODY_WIDTH, X + BODY_WIDTH, X + BODY_WIDTH / 2.0, X, X};
    const CGFloat yArray[] = {Y,Y - BODY_HEIGHT, Y - TOTAL_HEIGHT, Y-BODY_HEIGHT, Y};
    const NSInteger size = 5;
    
    CGContextMoveToPoint(context, X, Y);
    for (int i = 0; i < size;  ++ i) {
        CGContextAddLineToPoint(context, xArray[i], yArray[i]);
    }
    CGContextClosePath(context);
    CGContextFillPath(context);
    

    CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, self.bounds, maskImage);
    CGContextSaveGState(context);
}

- (void)setPenColor:(DrawColor *)penColor
{
    if (self.penColor != penColor) {
        [_penColor release];
        _penColor = penColor;
        [_penColor retain];
    }
    [self setNeedsDisplay];
}

@end
