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
#import "CMPopTipView.h"

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


@interface PickView : UIImageView<CMPopTipViewDelegate>
{
    id<PickViewDelegate> _delegate;
    CMPopTipView *_popTipView;
    BOOL _dismiss;
}
@property(nonatomic, assign)id<PickViewDelegate>delegate;
@property(nonatomic, assign)BOOL dismiss;
@property(nonatomic, retain)CMPopTipView *popTipView;

/*
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated withTag:(NSInteger)tag;
- (void)startRunOutAnimation;
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
- (void)startRunInAnimation;
*/
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
           animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;

@end
