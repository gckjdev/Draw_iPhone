//
//  DrawBgCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "DrawBgCommand.h"

@implementation DrawBgCommand

- (BOOL)execute
{
    
    DrawBgBox *view = [DrawBgBox drawBgBoxWithDelegate:self];
    UIView *spView = [[self.control theViewController] view];
    view.center = spView.center;
    [view showInView:spView];
//    [spView addSubview:view];
    return YES;
}

- (void)drawBgBox:(DrawBgBox *)drawBgBox didSelectedDrawBg:(PBDrawBg *)drawBg groudId:(NSInteger)groupId
{
    if ([self canUseItem:groupId]) {
        [self.toolHandler changeDrawBG:drawBg];
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
