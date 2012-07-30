//
//  PickView.h
//  Draw
//
//  Created by  on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DeviceDetection.h"
#import "PPDebug.h"

@class DrawColor;
@class ColorView;
@class PickView;
@class PenView;
@class ToolView;

@protocol PickViewDelegate <NSObject>

@optional
- (void)didPickedPickView:(PickView *)pickView colorView:(ColorView *)colorView;
- (void)didPickedPickView:(PickView *)pickView lineWidth:(NSInteger)width;
- (void)didPickedMoreColor;
- (void)didPickedPickView:(PickView *)pickView penView:(PenView *)penView;
- (void)didPickedPickView:(PickView *)pickView toolView:(ToolView *)toolView;

@end


@interface PickView : UIImageView
{
    id<PickViewDelegate> _delegate;
}
@property(nonatomic, assign)id<PickViewDelegate>delegate;


- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated withTag:(NSInteger)tag;
- (void)startRunOutAnimation;
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
- (void)startRunInAnimation;

@end
