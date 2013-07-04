//
//  GradientCommand.m
//  Draw
//
//  Created by gamy on 13-7-4.
//
//

#import "GradientCommand.h"
#import "GradientSettingView.h"
#import "GradientAction.h"

@interface GradientCommand()
@property(nonatomic, assign) GradientSettingView *gradientSettingView;

@end

@implementation GradientCommand

- (void)showPopTipView
{
    
    //create an gradient setting view and add to tool panel
    Gradient *graident = [[Gradient alloc] initWithDegree:0
                                               startColor:[DrawColor whiteColor]
                                                 endColor:[DrawColor blackColor]
                                                 division:0.5
                                                   inRect:self.toolHandler.drawView.bounds];
    
    self.gradientSettingView = [GradientSettingView gradientSettingViewWithGradient: graident];
    [graident release];
    CGPoint center = CGPointMake(160, 26);
    if (ISIPHONE5) {
        center = CGPointMake(160, 21);
    }else if(ISIPAD){
        center = CGPointMake(384, 53);
    }
    self.gradientSettingView.center = center;
    self.gradientSettingView.delegate = self;
    [self.toolPanel addSubview:self.gradientSettingView];
    [self.toolPanel hideColorPanel:YES];
    self.showing = YES;
    
}
- (void)hidePopTipView
{
    self.showing = NO;
    [self.gradientSettingView removeFromSuperview];
    self.gradientSettingView = nil;
    [self.toolPanel hideColorPanel:NO];
}

- (BOOL)execute
{
    if ([super execute]) {
        //TODO add an gradient action to the draw view.
        [self showPopTipView];
        return YES;
    }
    return NO;
}

//need to be override by the sub classes
-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_GRADIENT);
}
//change degree, division, color
- (void)gradientSettingView:(GradientSettingView *)view
           didChangeradient:(Gradient *)gradient
{
    
}

//click the ok/cancel button
- (void)gradientSettingView:(GradientSettingView *)view
       didFinishSetGradient:(Gradient *)gradient
                     cancel:(BOOL) cancel{
                     
}



@end
