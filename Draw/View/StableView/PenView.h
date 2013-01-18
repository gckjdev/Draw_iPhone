//
//  PenView.h
//  DrawViewTest
//
//  Created by  on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawColor.h"
#import "ItemType.h"


//#define PenStartType Pencil
#define PenStartType 1000
@interface PenView : UIButton
{
//    CGImageRef maskImage;
    ItemType _penType;
    NSInteger _price;
}

- (id)initWithPenType:(ItemType)type;
+ (PenView *)penViewWithType:(ItemType)type;
+ (CGFloat)height;
+ (CGFloat)width;
+ (ItemType)lastPenType;
+ (void)savePenType:(ItemType)type;

@property(nonatomic, assign)ItemType penType;
@property(nonatomic, assign)NSInteger price;

//@property(nonatomic, retain)DrawColor *penColor;
//
//- (id)initWithPenColor:(DrawColor *)penColor;
//+ (PenView *)viewWithColor:(DrawColor *)color;

@end
