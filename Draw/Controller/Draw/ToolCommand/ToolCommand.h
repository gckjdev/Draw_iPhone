//
//  ToolCommand.h
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import <Foundation/Foundation.h>
#import "ItemType.h"
#import "ToolHandler.h"
#import "AnalyticsManager.h"
#import "CMPopTipView.h"
#import "UIViewUtils.h"
#import "InputAlertView.h"

#define AnalyticsReport(x) [[AnalyticsManager sharedAnalyticsManager] reportDrawClick:x]

@class PPViewController;

@interface ToolCommand : NSObject<CMPopTipViewDelegate>

@property(nonatomic, assign)UIControl *control;
@property(nonatomic, assign)ToolHandler *toolHandler;
@property(nonatomic, assign)DrawToolPanel *toolPanel;
@property(nonatomic, assign)PPViewController *controller;
@property(nonatomic, assign)ItemType itemType;
@property(nonatomic, assign, getter = isShowing)BOOL showing;
@property(nonatomic, retain) CMPopTipView *popTipView;


- (BOOL)canUseItem:(ItemType)type;
- (id)initWithControl:(UIControl *)control itemType:(ItemType)itemType;

- (void)showPopTipView;
- (void)hidePopTipView;
- (void)finish;

- (void)becomeActive;

//need to be override by the sub classes
- (void)sendAnalyticsReport;
- (UIView *)contentView;
- (BOOL)execute;
- (void)buyItemSuccessfully:(ItemType)type;



@end


@interface ToolCommandManager : NSObject
{
    
}

//@property(nonatomic, assign)BOOL canRemoveAllCommand;
@property(nonatomic, assign)NSUInteger version;

- (NSUInteger)createVersion;

- (id)init;

+ (id)defaultManager;

- (void)registerCommand:(ToolCommand *)command;
- (void)unregisterCommand:(ToolCommand *)command;
- (ToolCommand *)commandForControl:(UIControl *)control;
- (void)removeAllCommand:(NSUInteger)version;
- (void)hideAllPopTipViews;
- (void)hideAllPopTipViewsExcept:(ToolCommand *)command;

- (void)updateHandler:(ToolHandler *)handler;
- (void)updatePanel:(DrawToolPanel *)panel;

- (BOOL)isPaletteShowing;
- (void)makeCommanActive:(ToolCommand *)command;


- (void)resetAlpha;
- (InputAlertView *)inputAlertView;
@end

