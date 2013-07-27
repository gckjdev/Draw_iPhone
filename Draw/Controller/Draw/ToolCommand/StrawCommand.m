//
//  StrawCommand.m
//  Draw
//
//  Created by gamy on 13-3-26.
//
//

#import "StrawCommand.h"

@interface StrawCommand ()
{
    TouchActionType type;
}

@end

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
    self.drawView.strawDelegate = self;
}

- (BOOL)execute
{
    if ([self canUseItem:self.itemType]) {
        [self showPopTipView];
        return YES;
    }
    return NO;
}


- (void)showPopTipView
{
    type = self.drawInfo.touchType;
    self.drawInfo.touchType = TouchActionTypeGetColor;
    self.showing = YES;
}

- (void)hidePopTipView
{
    self.showing = NO;
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
    self.drawInfo.penColor = color;
    self.drawInfo.alpha = color;
    self.drawInfo.touchType = type;
    [self hidePopTipView];
    [self updateToolPanel];
}

@end
