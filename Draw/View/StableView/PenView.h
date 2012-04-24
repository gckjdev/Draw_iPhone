//
//  PenView.h
//  DrawViewTest
//
//  Created by  on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawColor.h"


@interface PenView : UIButton
{
    CGImageRef maskImage;
}

@property(nonatomic, retain)DrawColor *penColor;

- (id)initWithPenColor:(DrawColor *)penColor;
+ (PenView *)viewWithColor:(DrawColor *)color;

@end
