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
#import "CommonDialog.h"

@implementation VersionUpdateView

+ (id)createView
{
//    CustomInfoView *view = [CustomInfoView createWithTitle:NSLS(@"kUpdateTips") info:NSLS(@"kVersionIsOld") hasCloseButton:NO buttonTitles:[NSArray arrayWithObjects:NSLS(@"kCancel"), NSLS(@"kOK"), nil]];
//    [view setActionBlock:^(UIButton *button, UIView *infoView){
//        if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLS(@"kOK")]) {
//            [UIUtils openApp:[GameApp appId]];
//        }
//        [view dismiss];
//    }];

    CommonDialog *view = [CommonDialog createDialogWithTitle:NSLS(@"kUpdateTips") message:NSLS(@"kVersionIsOld") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
        [UIUtils openApp:[GameApp appId]];

    } clickCancelBlock:^{
        
    }];
    
    return view;
}

+ (void)showInView:(UIView *)view
{
    CustomInfoView *cusInfoView = [self createView];
    [cusInfoView showInView:view];
}


@end
