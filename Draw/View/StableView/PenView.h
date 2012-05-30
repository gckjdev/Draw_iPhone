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
    Pencil = 0,
    WaterPen = 1,
    Pen = 2,
    IcePen = 3,
    Quill = 4
}PenType;

@interface PenView : UIButton
{
//    CGImageRef maskImage;
    PenType _penType;
}

- (id)initWithPenType:(PenType)type;
@property(nonatomic, assign)PenType penType;

//@property(nonatomic, retain)DrawColor *penColor;
//
//- (id)initWithPenColor:(DrawColor *)penColor;
//+ (PenView *)viewWithColor:(DrawColor *)color;

@end
