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
@property(nonatomic, retain) Gradient *lastGradient;


@end

@implementation GradientCommand

- (void)dealloc
{
    PPRelease(_lastGradient);
    [super dealloc];
}

- (void)showPopTipView
{
    
    
    
    //create an gradient setting view and add to tool panel
    
    CGRect rect = self.toolHandler.drawView.bounds;
    if (self.toolHandler.drawView.currentClip) {
        rect = self.toolHandler.drawView.currentClip.pathRect;
    }
    
    if (self.lastGradient) {
        self.lastGradient = [[[Gradient alloc] initWithGradient:_lastGradient] autorelease];
        self.lastGradient.rect = rect;
        [self.lastGradient setDegree:self.lastGradient.degree];
    }else{
        Gradient *graident = [[Gradient alloc] initWithDegree:0
                                                   startColor:[DrawColor whiteColor]
                                                     endColor:[DrawColor blackColor]
                                                     division:0.5
                                                       inRect:rect];
        self.lastGradient = graident;
        [graident release];
    }
    
    [self.toolHandler startGradient:self.lastGradient];
    
    
    self.gradientSettingView = [GradientSettingView gradientSettingViewWithGradient: self.lastGradient];


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
    [self.toolHandler confirmGradient:self.lastGradient];
}




- (BOOL)execute
{
    if ([super execute]) {
        DrawAction *lastAction = [self.toolHandler.drawView lastAction];
        if (lastAction && !self.toolHandler.drawView.currentClip) {
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
    [self.toolHandler updateGradient:gradient];
    
}
/*

//click the ok/cancel button
- (void)gradientSettingView:(GradientSettingView *)view
       didFinishSetGradient:(Gradient *)gradient
                     cancel:(BOOL) cancel{
    
    if (cancel) {
        [self.toolHandler cancelGradient];
    }else{
        [self.toolHandler confirmGradient:gradient];
    }
    [self hidePopTipView];
}

*/

@end
