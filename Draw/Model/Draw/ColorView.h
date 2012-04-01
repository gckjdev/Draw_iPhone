//
//  ColorView.h
//  Draw
//
//  Created by  on 12-4-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    ColorViewScaleSmall = 1,
    ColorViewScaleLarge = 2
}ColorViewScale;

@class DrawColor;
@interface ColorView : UIButton
{
    DrawColor *_drawColor;
}
@property(nonatomic, retain)DrawColor *drawColor;
- (void)setImage:(UIImage *)image;
- (id)initWithDrawColor:(DrawColor *)drawColor 
                  image:(UIImage *)image 
                  scale:(ColorViewScale)scale;

+ (id)colorViewWithDrawColor:(DrawColor *)drawColor 
                  image:(UIImage *)image 
                  scale:(ColorViewScale)scale;


@end
