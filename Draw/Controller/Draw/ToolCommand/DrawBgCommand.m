//
//  DrawBgCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "DrawBgCommand.h"

@interface DrawBgCommand()
{
     
}

@property(nonatomic, assign)DrawBgBox *box;

@end

@implementation DrawBgCommand

- (void)dealloc
{
//    PPRelease(_box);
    self.box = nil;
    [super dealloc];
}

- (BOOL)execute
{
    
    DrawBgBox *view = [DrawBgBox drawBgBoxWithDelegate:self];
    UIView *spView = [[self controller] view];
    view.center = spView.center;
    [view showInView:spView];
    self.box = view;
//    [spView addSubview:view];
    return YES;
}

- (void)changeBGImage:(PBDrawBg *)drawBg
{
    ChangeBGImageAction *action = [ChangeBGImageAction actionWithDrawBG:drawBg];
    [self.drawView addDrawAction:action show:YES];
    [self.drawView finishLastAction:action refresh:NO];
}

- (void)drawBgBox:(DrawBgBox *)drawBgBox didSelectedDrawBg:(PBDrawBg *)drawBg groudId:(NSInteger)groupId
{
    if ([self canUseItem:groupId]) {
        [self changeBGImage:drawBg];
        [drawBgBox dismiss];
        self.box = nil;
    }
}

- (void)buyItemSuccessfully:(ItemType)type
{
    [self.box reloadView];
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_DRAWBG_BOX);
}


@end
