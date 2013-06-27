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
    
    //TODO get shadow from common handler
    
    Shadow *shadow = [Shadow shadowWithDrawColor:[DrawColor yellowColor] offset:CGSizeMake(2, 2) blur:3];
    
    ShadowBox *view  = [ShadowBox shadowBoxWithShadow:shadow];
    UIView *spView = [[self.control theViewController] view];
    view.center = spView.center;
    [view showInView:spView];
    self.box = view;
    
    return YES;
}



- (void)shadowBox:(ShadowBox *)box didGetShadow:(Shadow *)shadow
{
    //TODO change shadow
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_DRAWBG_BOX);
}


@end
