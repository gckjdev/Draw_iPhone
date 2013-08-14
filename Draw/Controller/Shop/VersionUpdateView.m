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
    CommonDialog *view = [CommonDialog createDialogWithTitle:NSLS(@"kUpdateTips") message:NSLS(@"kVersionIsOld") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
        [UIUtils openApp:[GameApp appId]];
    } clickCancelBlock:^{
    }];
    
    return view;
}

+ (void)showInView:(UIView *)inView
{
    CommonDialog *view = [self createView];
    [view showInView:inView];
}


@end
