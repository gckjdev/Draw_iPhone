//
//  ColorView.m
//  Draw
//
//  Created by  on 12-4-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ColorView.h"
#import "DrawColor.h"
#import "ShareImageManager.h"

@implementation ColorView
@synthesize drawColor = _drawColor;
- (void)setImage:(UIImage *)image
{
//    [self setImage:image forState:UIControlStateNormal];
    [self setBackgroundImage:image forState:UIControlStateNormal];
}

#define SCALE_SMALL_FRAME CGRectMake(0,0,32,34)
#define SCALE_LARGE_FRAME CGRectMake(0,0,32.0*1.5,34.0*1.5)

- (id)initWithDrawColor:(DrawColor *)drawColor 
                  image:(UIImage *)image 
                  scale:(ColorViewScale)scale
{
    if (scale == ColorViewScaleLarge) {
        self = [super initWithFrame:SCALE_LARGE_FRAME];
    }else{
        self = [super initWithFrame:SCALE_SMALL_FRAME];
    }
    if (self) {
        _scale = scale;
        [self setImage:image];
        [self setDrawColor:drawColor];
    }
    return self;
}

- (void)setScale:(ColorViewScale)scale
{
    _scale = scale;
    CGPoint center = self.center;
    if (scale == ColorViewScaleLarge) {
        [self setFrame:SCALE_LARGE_FRAME];
    }else{
        [self setFrame:SCALE_SMALL_FRAME];
    }
    self.center = center;
}
- (ColorViewScale)scale
{
    return _scale;
}

+ (id)colorViewWithDrawColor:(DrawColor *)drawColor 
                      image:(UIImage *)image 
                      scale:(ColorViewScale)scale
{
    return [[[ColorView alloc] initWithDrawColor:drawColor 
                                           image:image 
                                           scale:scale]autorelease];
}

+ (ColorView *)blueColorView
{
    ShareImageManager *manager = [ShareImageManager defaultManager];
    return [ColorView colorViewWithDrawColor:[DrawColor blueColor] image:[manager blueColorImage] scale:ColorViewScaleSmall];
}
+ (ColorView *)redColorView
{
    ShareImageManager *manager = [ShareImageManager defaultManager];
    return [ColorView colorViewWithDrawColor:[DrawColor redColor] image:[manager redColorImage] scale:ColorViewScaleSmall];
    
}
+ (ColorView *)blackColorView
{
    ShareImageManager *manager = [ShareImageManager defaultManager];
    return [ColorView colorViewWithDrawColor:[DrawColor blackColor] image:[manager blackColorImage] scale:ColorViewScaleSmall];
    
}
+ (ColorView *)yellowColorView
{
    ShareImageManager *manager = [ShareImageManager defaultManager];
    return [ColorView colorViewWithDrawColor:[DrawColor yellowColor] image:[manager yellowColorImage] scale:ColorViewScaleSmall];
    
}

@end
