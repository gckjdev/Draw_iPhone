//
//  ColorView.m
//  DrawViewTest
//
//  Created by  on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ColorView.h"
#import "ShareImageManager.h"
#import "DeviceDetection.h"

#define SCALE 1.3
#define SCALE_SMALL_FRAME_IPHONE CGRectMake(0,0,32,34)
#define SCALE_SMALL_FRAME_IPAD CGRectMake(0,0,32*2,34*2)
#define SCALE_SMALL_FRAME ([DeviceDetection isIPAD] ? (SCALE_SMALL_FRAME_IPAD) : (SCALE_SMALL_FRAME_IPHONE))

#define SCALE_LARGE_FRAME_IPHONE CGRectMake(0,0,32*SCALE,34*SCALE)
#define SCALE_LARGE_FRAME_IPAD CGRectMake(0,0,32*2*SCALE,34*2*SCALE)
#define SCALE_LARGE_FRAME ([DeviceDetection isIPAD] ? (SCALE_LARGE_FRAME_IPAD) : (SCALE_LARGE_FRAME_IPHONE))

#define SCALE_SMALL_FILL_RECT_IPHONE CGRectMake(3, 3, 26, 27)
#define SCALE_SMALL_FILL_RECT_IPAD CGRectMake(3*2, 3*2, 26*2, 27*2)
#define SCALE_SMALL_FILL_RECT ([DeviceDetection isIPAD] ? (SCALE_SMALL_FILL_RECT_IPAD) : (SCALE_SMALL_FILL_RECT_IPHONE))

#define SCALE_LARGE_FILL_RECT_IPHONE CGRectMake(3*SCALE, 3*SCALE, 26*SCALE, 27*SCALE)
#define SCALE_LARGE_FILL_RECT_IPAD CGRectMake(3*2*SCALE, 3*2*SCALE, 26*2*SCALE, 27*2*SCALE)
#define SCALE_LARGE_FILL_RECT ([DeviceDetection isIPAD] ? (SCALE_LARGE_FILL_RECT_IPAD) : (SCALE_LARGE_FILL_RECT_IPHONE))

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
- (id)initWithRed:(NSInteger)red 
            green:(NSInteger)green 
             blue:(NSInteger)blue 
            scale:(ColorViewScale)scale
{
    DrawColor *dColor = [DrawColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1];
    return [self initWithDrawColor:dColor scale:scale];
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
    if (scale == _scale) {
        return;
    }
    _scale = scale;
    CGPoint center = self.center;
    if (scale == ColorViewScaleLarge) {
        self.frame = SCALE_LARGE_FRAME;        
    }else{
        self.frame = SCALE_SMALL_FRAME;        
    }
    self.center = center;
    [self setNeedsDisplay];
}

- (ColorViewScale)scale{
    return _scale;
}

- (void)setDrawColor:(DrawColor *)drawColor
{
    if (drawColor != _drawColor) {
        [_drawColor release];
        _drawColor = drawColor;
        [_drawColor retain];
        [self setNeedsDisplay];
    }
}


- (void)dealloc
{
    CGImageRelease(maskImage);
    [_drawColor release];
    [super dealloc];
}


- (void)drawRect:(CGRect)rect
{
    [self initMaskImage];
    self.backgroundColor = [UIColor clearColor];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.drawColor.CGColor);
    
    CGRect fillRect = SCALE_SMALL_FILL_RECT;    
    if (self.scale == ColorViewScaleLarge) {
        fillRect = SCALE_LARGE_FILL_RECT;
    }
    CGContextFillRect(context, fillRect);
    CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, self.bounds, maskImage);
}


- (BOOL)isEqual:(id)object
{
    if ([super isEqual:object]) {
        return YES;
    }else if([object isKindOfClass:[ColorView class]]){
        ColorView *other = (ColorView *)object;
        return [self.drawColor isEqual:other.drawColor];
    }
    return NO;
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
