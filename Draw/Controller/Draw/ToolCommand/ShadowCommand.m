//
//  DrawBgCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "ShadowCommand.h"

@interface ShadowCommand()
{
     
}

@property(nonatomic, retain)ShadowBox *box;

@end

@implementation ShadowCommand

- (void)dealloc
{
    PPRelease(_box);
    [super dealloc];
}

- (BOOL)execute
{

    Shadow *shadow = [Shadow shadowWithShadow:self.toolHandler.shadow];
    
    ShadowBox *view  = [ShadowBox shadowBoxWithShadow:shadow];
    UIView *spView = [[self.control theViewController] view];
    view.center = spView.center;
    [view showInView:spView];
    view.delegate = self;
    self.box = view;
    
    
    return YES;
}



- (void)shadowBox:(ShadowBox *)box didGetShadow:(Shadow *)shadow
{
    if ([shadow isEmpty]) {
        shadow = nil;
    }
    [self.toolHandler changeShadow:shadow];
    [box dismiss];
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_DRAWBG_BOX);
}


@end
