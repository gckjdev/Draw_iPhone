//
//  ColorView.m
//  DrawViewTest
//
//  Created by  on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ColorView.h"
#import "ShareImageManager.h"

#define SCALE_SMALL_FRAME CGRectMake(0,0,32,34)
#define SCALE_LARGE_FRAME CGRectMake(0,0,32.0*1.5,34.0*1.5)

@implementation ColorView
@synthesize drawColor = _drawColor;


- (void)initMaskImage
{
    if (!maskImage) {
        maskImage = [[ShareImageManager defaultManager] colorMaskImage].CGImage;
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


- (id)initWithDrawColor:(DrawColor *)drawColor 
                  scale:(ColorViewScale)scale
{
    
    if (scale == ColorViewScaleLarge) {
        self = [self initWithFrame:SCALE_LARGE_FRAME];
    }else{
        self = [self initWithFrame:SCALE_SMALL_FRAME];
    }
    if (self) {
        _scale = scale;
        self.drawColor = drawColor;
    }
    return self;
}

- (void)setScale:(ColorViewScale)scale
{
    _scale = scale;
    [self setNeedsDisplay];
}

- (ColorViewScale)scale{
    return _scale;
}


- (void)dealloc
{
    CGImageRelease(maskImage);
    [_drawColor release];
    [super dealloc];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self initMaskImage];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.drawColor.CGColor);
    
    CGRect fillRect = CGRectMake(3, 3, 26, 27);
    if (self.scale == ColorViewScaleLarge) {
        fillRect = CGRectMake(3*1.5, 3*1.5, 26*1.5, 27*1.5);
    }
    
    
    CGContextFillRect(context, fillRect);
    //    CGContextMoveToPoint(context, X, Y);
    //    for (int i = 0; i < size;  ++ i) {
    //        CGContextAddLineToPoint(context, xArray[i], yArray[i]);
    //    }
    //    CGContextClosePath(context);
    //    CGContextFillPath(context);
    
    
    CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, self.bounds, maskImage);
}

+ (id)colorViewWithDrawColor:(DrawColor *)drawColor 
                       scale:(ColorViewScale)scale
{
    return [[[ColorView alloc] initWithDrawColor:drawColor 
                                           scale:scale]autorelease];
}

+ (ColorView *)blueColorView
{
    return [ColorView colorViewWithDrawColor:[DrawColor blueColor] scale:ColorViewScaleSmall];
}
+ (ColorView *)redColorView
{
    return [ColorView colorViewWithDrawColor:[DrawColor redColor] scale:ColorViewScaleSmall];
    
}
+ (ColorView *)blackColorView
{
    return [ColorView colorViewWithDrawColor:[DrawColor blackColor]  scale:ColorViewScaleSmall];
    
}
+ (ColorView *)yellowColorView
{
    return [ColorView colorViewWithDrawColor:[DrawColor yellowColor] scale:ColorViewScaleSmall];
    
}

+ (ColorView *)orangeColorView
{
    return [ColorView colorViewWithDrawColor:[DrawColor orangeColor] scale:ColorViewScaleSmall];
    
}
+ (ColorView *)greenColorView
{
    return [ColorView colorViewWithDrawColor:[DrawColor greenColor] scale:ColorViewScaleSmall];
    
}
+ (ColorView *)pinkColorView
{
    return [ColorView colorViewWithDrawColor:[DrawColor pinkColor] scale:ColorViewScaleSmall];
    
}
+ (ColorView *)brownColorView
{
    return [ColorView colorViewWithDrawColor:[DrawColor brownColor] scale:ColorViewScaleSmall];
    
}
+ (ColorView *)skyColorView
{
    return [ColorView colorViewWithDrawColor:[DrawColor skyColor] scale:ColorViewScaleSmall];
    
}
+ (ColorView *)whiteColorView
{
    return [ColorView colorViewWithDrawColor:[DrawColor whiteColor] scale:ColorViewScaleSmall];
    
}


@end
