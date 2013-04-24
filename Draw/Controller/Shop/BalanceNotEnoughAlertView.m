//
//  BalanceNotEnoughAlertView.m
//  Draw
//
//  Created by 王 小涛 on 13-3-20.
//
//

#import "BalanceNotEnoughAlertView.h"
#import "CommonDialog.h"
#import "FreeIngotController.h"
#import "ChargeController.h"
#import "ConfigManager.h"

@implementation BalanceNotEnoughAlertView


+ (id)createView:(UIViewController *)controller;
{
    CommonDialog *view = [CommonDialog createDialogWithTitle:NSLS(@"kBalanceNotEnoughTitle") message:NSLS(@"kBalanceNotEnoughDesc") style:CommonDialogStyleDoubleButtonWithCross delegate:nil clickOkBlock:^{
        
        if (![ConfigManager isInReviewVersion]) {
            FreeIngotController *vc = [[[FreeIngotController alloc] init] autorelease];
            [controller.navigationController pushViewController:vc animated:YES];
        }

    } clickCancelBlock:^{
        
        ChargeController *vc = [[[ChargeController alloc] init] autorelease];
        [controller.navigationController pushViewController:vc animated:YES];
        
    }];
    
    if ([ConfigManager isInReviewVersion]) {
        [view.oKButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    }else{
        [view.oKButton setTitle:NSLS(@"kFreeIngots") forState:UIControlStateNormal];
    }
    
    [view.backButton setTitle:NSLS(@"kCharge") forState:UIControlStateNormal];

    return view;
}

+ (void)showInController:(UIViewController *)controller
{
    if (controller) {
        CommonDialog *view = [self createView:controller];
        [view showInView:controller.view];        
    }
}


@end
