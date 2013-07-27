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
#import "ClipAction.h"
#import "CommonDialog.h"

@interface GradientCommand()
@property(nonatomic, assign) GradientSettingView *gradientSettingView;

@end

@implementation GradientCommand

- (void)dealloc
{
    [super dealloc];
}

- (void)showPopTipView
{
    //create an gradient setting view and add to tool panel
    
    CGRect rect = self.drawView.bounds;
    Gradient *gradient = self.drawInfo.gradient;
    if (gradient) {
        gradient = [[[Gradient alloc] initWithGradient:gradient] autorelease];
        gradient.rect = rect;
        [gradient updatePointsWithDegreeAndDivision]; 
    }else{
        gradient = [[[Gradient alloc] initWithDegree:0
                                         startColor:[DrawColor whiteColor]
                                           endColor:[DrawColor blackColor]
                                           division:0.5
                                             inRect:rect] autorelease];
    }
    self.drawInfo.gradient = gradient;
    self.gradientSettingView = [GradientSettingView gradientSettingViewWithGradient: gradient];


    CGPoint center = CGPointMake(160, 26);
    if (ISIPHONE5) {
        center = CGPointMake(160, 21);
    }else if(ISIPAD){
        center = CGPointMake(384, 53);
    }
    self.gradientSettingView.center = center;
    self.gradientSettingView.delegate = self;
    [self.toolPanel addSubview:self.gradientSettingView];
    self.gradientSettingView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.gradientSettingView.alpha = 1;
    }];
    [self.toolPanel hideColorPanel:YES];
    self.showing = YES;
    
}
- (void)hidePopTipView
{
    self.showing = NO;
    [self.gradientSettingView clear];
    
    self.gradientSettingView.alpha = 1;
    [UIView animateWithDuration:0.5 animations:^{
    self.gradientSettingView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.gradientSettingView removeFromSuperview];
        self.gradientSettingView = nil;
    }];
    
    
    [self.toolPanel hideColorPanel:NO];

    GradientAction *gradientAction = [self.drawView lastAction];
    
    if ([gradientAction isKindOfClass:[GradientAction class]]) {
        [self.drawView finishLastAction:gradientAction refresh:NO];
    }
}




- (BOOL)execute
{
    if ([super execute]) {
        DrawAction *lastAction = [self.drawView lastAction];
        
        if (lastAction && ![lastAction isKindOfClass:[ClipAction class]])
        {
            [[CommonDialog createDialogWithTitle:NSLS(@"kUseGradientTitle")
                                         message:NSLS(@"kUseGradientMessage")
                                           style:CommonDialogStyleDoubleButton
                                        delegate:nil
                                    clickOkBlock:^{
                                        [self showPopTipView];
                                    } clickCancelBlock:NULL]
             showInView:[self.control theTopView]];
            
        }else{
            [self showPopTipView];
        }

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

    GradientAction *gradientAction = [self.drawView lastAction];
    if ([gradientAction isKindOfClass:[GradientAction class]]) {
        gradientAction.gradient = [[[Gradient alloc] initWithGradient:gradient] autorelease];
        [self.drawView updateLastAction:gradientAction refresh:YES];
    }
}

@end
