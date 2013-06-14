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

@property(nonatomic, retain)DrawBgBox *box;

@end

@implementation DrawBgCommand

- (void)dealloc
{
    PPRelease(_box);
    [super dealloc];
}

- (BOOL)execute
{
    
    DrawBgBox *view = [DrawBgBox drawBgBoxWithDelegate:self];
    UIView *spView = [[self.control theViewController] view];
    view.center = spView.center;
    [view showInView:spView];
    self.box = view;
//    [spView addSubview:view];
    return YES;
}

- (void)drawBgBox:(DrawBgBox *)drawBgBox didSelectedDrawBg:(PBDrawBg *)drawBg groudId:(NSInteger)groupId
{
    if ([self canUseItem:groupId]) {
        [self.toolHandler changeDrawBG:drawBg];
        [drawBgBox dismiss];
        self.box = nil;

        if (self.toolHandler.touchActionType == TouchActionTypeShape) {
            [self.toolHandler enterShapeMode];
        }else{
            [self.toolHandler enterDrawMode];
        }
        
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
