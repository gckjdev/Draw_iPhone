//
//  GradientSettingView.h
//  TestCodePool
//
//  Created by gamy on 13-7-2.
//  Copyright (c) 2013年 ict. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GradientAction.h"
#import "DrawSlider.h"
#import "CMPopTipView.h"
#import "Palette.h"


@class GradientSettingView;

@protocol GradientSettingViewDelegate <NSObject>

//change degree, division, color
- (void)gradientSettingView:(GradientSettingView *)view
           didChangeradient:(Gradient *)gradient;

@end


@interface GradientSettingView : UIView<DrawSliderDelegate, ColorPickingBoxDelegate, CMPopTipViewDelegate>

@property(nonatomic, assign) id<GradientSettingViewDelegate>delegate;

+ (id)gradientSettingViewWithGradient:(Gradient *)gradient;

- (void)clear;

- (IBAction)moveDivisionButton:(UIButton *)sender forEvent:(UIEvent *)event;

@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;

@end
