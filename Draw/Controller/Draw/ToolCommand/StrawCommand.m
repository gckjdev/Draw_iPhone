//
//  StrawCommand.m
//  Draw
//
//  Created by gamy on 13-3-26.
//
//

#import "StrawCommand.h"

@implementation StrawCommand

- (id)initWithControl:(UIControl *)control itemType:(ItemType)itemType
{
    self = [super initWithControl:control itemType:itemType];
    if (self) {
        [self.control setSelected:NO];
    }
    return self;
}

- (void)setToolHandler:(ToolHandler *)toolHandler
{
    [super setToolHandler:toolHandler];
    toolHandler.drawView.strawDelegate = self;
}

- (BOOL)execute
{
//    if ([super execute]) {
//        [self showPopTipView];
//        return YES;
//    }
//    return NO;
    if ([self canUseItem:self.itemType]) {
        [self sendAnalyticsReport];
        [self showPopTipView];
        return YES;
    }
    return NO;
}


- (void)showPopTipView
{
    [self becomeActive];
    self.showing = YES;
    [self.control setSelected:YES];
    [self.toolHandler enterStrawMode];
}

- (void)hidePopTipView
{
    self.showing = NO;
    [self.control setSelected:NO];
    [self.toolHandler enterDrawMode];
}

- (void)sendAnalyticsReport
{
    AnalyticsReport(DRAW_CLICK_STRAW);
}

- (void)buyItemSuccessfully:(ItemType)type
{
    [self showPopTipView];
}

- (void)didStrawGetColor:(DrawColor *)color
{
    [self.toolPanel updateRecentColorViewWithColor:color updateModel:YES];
    [self.toolHandler changeAlpha:1];
    [self.toolHandler changePenColor:color];
    [[ToolCommandManager defaultManager] resetAlpha];
    [self hidePopTipView];
}

@end
