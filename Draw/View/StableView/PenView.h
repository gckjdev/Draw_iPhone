//
//  PenView.h
//  DrawViewTest
//
//  Created by  on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawColor.h"


typedef enum {
    Pencil = 1000,
    WaterPen,
    Pen,
    IcePen,
    Quill,
    PenCount
}PenType;

#define PenStartType Pencil

@interface PenView : UIButton
{
//    CGImageRef maskImage;
    PenType _penType;
}

- (id)initWithPenType:(PenType)type;
+ (PenView *)penViewWithType:(PenType)type;
+ (CGFloat)height;
+ (CGFloat)width;
- (BOOL)isLeftDownRotate;
@property(nonatomic, assign)PenType penType;


//@property(nonatomic, retain)DrawColor *penColor;
//
//- (id)initWithPenColor:(DrawColor *)penColor;
//+ (PenView *)viewWithColor:(DrawColor *)color;

@end
