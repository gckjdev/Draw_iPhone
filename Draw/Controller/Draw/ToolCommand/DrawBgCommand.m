//
//  DrawBgCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "DrawBgCommand.h"

@implementation DrawBgCommand

- (UIView *)contentView
{
    DrawBgBox *drawBgBox = [DrawBgBox drawBgBoxWithDelegate:self];
    [drawBgBox updateViewsWithSelectedBgId:self.toolHandler.drawBG.bgId];
    return drawBgBox;
}

- (BOOL)execute
{
    if ([super execute]) {
        [self showPopTipView];
        return YES;
    }
    return NO;
}

- (void)drawBgBox:(DrawBgBox *)drawBgBox didSelectedDrawBg:(PBDrawBg *)drawBg
{
    [self.toolHandler changeDrawBG:drawBg];
    [self hidePopTipView];
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_DRAWBG_BOX);
}


@end
