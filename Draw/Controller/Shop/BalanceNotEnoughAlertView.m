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

@implementation BalanceNotEnoughAlertView


+ (id)createView:(UIViewController *)controller;
{
    CommonDialog *view = [CommonDialog createDialogWithTitle:NSLS(@"kBalanceNotEnoughTitle") message:NSLS(@"kBalanceNotEnoughDesc") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
        FreeIngotController *vc = [[[FreeIngotController alloc] init] autorelease];
        [controller.navigationController pushViewController:vc animated:YES];
        
    } clickCancelBlock:^{
        ChargeController *vc = [[[ChargeController alloc] init] autorelease];
        [controller.navigationController pushViewController:vc animated:YES];
    }];
    
    [view.oKButton setTitle:NSLS(@"kGetFreeIngot") forState:UIControlStateNormal];
    [view.backButton setTitle:NSLS(@"kCharge") forState:UIControlStateNormal];

    return view;
}

+ (void)showInView:(UIViewController *)controller
{
    CommonDialog *view = [self createView:controller];
    [view showInView:controller.view];
}


@end
