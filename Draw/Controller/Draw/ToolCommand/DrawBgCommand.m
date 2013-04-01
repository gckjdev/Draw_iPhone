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
//    [drawBgBox updateViewsWithSelectedBgId:self.toolHandler.drawBG.bgId];
    return drawBgBox;
}

- (BOOL)execute
{
    
    UIView *view = [self contentView];
    UIView *spView = [[self.control theViewController] view];
    view.center = spView.center;
    [spView addSubview:view];
    return YES;
}

- (void)updateWithDrawBG:(PBDrawBg *)drawBG
{
    [self.toolHandler changeDrawBG:drawBG];
}

- (void)drawBgBox:(DrawBgBox *)drawBgBox didSelectedDrawBg:(PBDrawBg *)drawBg groudId:(NSInteger)groupId
{
    //TODO remove || YES
    if ([self canUseItem:groupId] || YES) {
        [self updateWithDrawBG:drawBg];
        [drawBgBox dismiss];
    }else{

    }
}

- (void)buyItemSuccessfully:(ItemType)type
{
    
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_DRAWBG_BOX);
}


@end
