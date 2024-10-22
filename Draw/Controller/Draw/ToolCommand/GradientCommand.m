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
{
    GradientAction *gradientAction;
}
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


//    CGPoint center = CGPointMake(160, 26);
//    if (ISIPHONE5) {
//        center = CGPointMake(160, 21);
//    }else if(ISIPAD){
//        center = CGPointMake(384, 53);
//    }
    self.gradientSettingView.delegate = self;
    [self.toolPanel showGradientSettingView:self.gradientSettingView];
    self.gradientSettingView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.gradientSettingView.alpha = 1;
    }];
    [self.toolPanel hideColorPanel:YES];
    
    self.showing = YES;
    
    gradientAction = [GradientAction actionWithGradient:gradient];
    [self.drawView addDrawAction:gradientAction show:YES];
    
    
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
    
    [self.drawView finishLastAction:gradientAction refresh:YES];
        
    [self.toolPanel hideColorPanel:NO];
}



- (BOOL)execute
{
    if ([super execute]) {
        DrawAction *lastDrawAction = [self.drawView lastAction];
        
        if (lastDrawAction && ![lastDrawAction isChangeBGAction] && ![lastDrawAction isClipAction] && lastDrawAction.clipAction == nil)
        {
            CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kUseGradientTitle")
                                         message:NSLS(@"kUseGradientMessage")
                                           style:CommonDialogStyleDoubleButton];
            [dialog setClickOkBlock:^(UILabel *label){
                [self showPopTipView];
            }];
            
            [dialog showInView:[self.controller view]];
            
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
    gradientAction.gradient = [[[Gradient alloc] initWithGradient:gradient] autorelease];
    [self.drawView updateLastAction:gradientAction refresh:YES];
}

@end
