//
//  ColorView.h
//  DrawViewTest
//
//  Created by  on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawColor.h"

typedef enum{
    ColorViewScaleSmall = 0,
    ColorViewScaleLarge = 1
}ColorViewScale;

@interface ColorView : UIButton
{
    CGImageRef maskImage;
    ColorViewScale _scale;
}

@property(nonatomic, retain)DrawColor *drawColor;

- (id)initWithDrawColor:(DrawColor *)drawColor 
                  scale:(ColorViewScale)scale;
+ (id)colorViewWithDrawColor:(DrawColor *)drawColor 
                       scale:(ColorViewScale)scale;

- (id)initWithRed:(NSInteger)red 
            green:(NSInteger) green 
             blue:(NSInteger)blue 
            scale:(ColorViewScale)scale;

- (void)setScale:(ColorViewScale)scale;
- (ColorViewScale)scale;
- (BOOL)isEqual:(id)object;


+ (ColorView *)blueColorView;
+ (ColorView *)redColorView;
+ (ColorView *)blackColorView;
+ (ColorView *)yellowColorView;

+ (ColorView *)orangeColorView;
+ (ColorView *)greenColorView;
+ (ColorView *)pinkColorView;
+ (ColorView *)brownColorView;
+ (ColorView *)skyColorView;
+ (ColorView *)whiteColorView;


@end
