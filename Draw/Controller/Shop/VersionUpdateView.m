//
//  VersionUpdateView.m
//  Draw
//
//  Created by haodong on 13-3-14.
//
//

#import "VersionUpdateView.h"
#import "CustomInfoView.h"
#import "UIUtils.h"

@implementation VersionUpdateView

+ (id)createView
{
    CustomInfoView *cusInfoView = [CustomInfoView createWithTitle:NSLS(@"kUpdateTips") info:NSLS(@"kVersionIsOld") hasCloseButton:NO buttonTitles:[NSArray arrayWithObjects:NSLS(@"kCancel"), NSLS(@"kOK"), nil]];
    [cusInfoView setActionBlock:^(UIButton *button, UIView *infoView){
        if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLS(@"kOK")]) {
            [UIUtils openApp:[GameApp appId]];
        }
        [cusInfoView dismiss];
    }];
    
    return cusInfoView;
}

+ (void)showInView:(UIView *)view
{
    [view addSubview:[self createView]];
}


@end
