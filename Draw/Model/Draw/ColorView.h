//
//  ColorView.h
//  Draw
//
//  Created by  on 12-4-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    ColorViewScaleSmall = 0,
    ColorViewScaleLarge = 1
}ColorViewScale;

@class DrawColor;
@interface ColorView : UIButton
{
    DrawColor *_drawColor;
    ColorViewScale _scale;
}
@property(nonatomic, retain)DrawColor *drawColor;
- (void)setImage:(UIImage *)image;
- (id)initWithDrawColor:(DrawColor *)drawColor 
                  image:(UIImage *)image 
                  scale:(ColorViewScale)scale;
- (void)setScale:(ColorViewScale)scale;
- (ColorViewScale)scale;

+ (id)colorViewWithDrawColor:(DrawColor *)drawColor 
                  image:(UIImage *)image 
                  scale:(ColorViewScale)scale;
+ (ColorView *)blueColorView;
+ (ColorView *)redColorView;
+ (ColorView *)blackColorView;
+ (ColorView *)yellowColorView;
@end
