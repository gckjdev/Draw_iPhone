//
//  DrawToolPanel.h
//  Draw
//
//  Created by gamy on 12-12-24.
//
//

#import <UIKit/UIKit.h>
#import "ColorPoint.h"
#import "PenView.h"
#import "ItemType.h"
#import "Palette.h"
#import "DrawInfo.h"
#import "DrawView.h"
#import "PanelUtil.h"

@class DrawToolPanel;

@protocol DrawToolPanelDelegate <NSObject>

- (void)drawToolPanel:(DrawToolPanel *)panel didClickTool:(UIButton *)toolButton;

@end

@interface DrawToolPanel : UIView<ColorPointDelegate, UIScrollViewDelegate>
{
    
}

@property(nonatomic, assign)NSInteger timerDuration;
@property(nonatomic, assign)DrawView *drawView;
@property(nonatomic, assign)id<DrawToolPanelDelegate> delegate;


- (void)updateWithDrawInfo:(DrawInfo *)drawInfo;

+ (id)createViewWithDrawView:(DrawView *)drawView;

////

- (void)bindController:(PPViewController *)controller;
- (void)updateView;
- (void)setPanelForOnline:(BOOL)isOnline;
- (void)updateRecentColorViewWithColor:(DrawColor *)color updateModel:(BOOL)updateModel;

- (void)registerToolCommands;
- (IBAction)clickTool:(UIButton *)sender;
- (void)hideColorPanel:(BOOL)hide;

- (void)showGradientSettingView:(UIView *)gradientSettingView;

#pragma mark - Timer

- (void)startTimer;
- (void)stopTimer;
@end
