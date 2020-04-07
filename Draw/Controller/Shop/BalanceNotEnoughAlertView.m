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
#import "PPConfigManager.h"
#import "PurchaseVipController.h"

@implementation BalanceNotEnoughAlertView


+ (id)createView:(UIViewController *)controller;
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kBalanceNotEnoughTitle")
                                                       message:NSLS(@"kBalanceNotEnoughDesc")
                                                         style:CommonDialogStyleSingleButtonWithCross]; //CommonDialogStyleDoubleButtonWithCross];
    
    [dialog setClickOkBlock:^(UILabel *label){
            
            if (![PPConfigManager isInReviewVersion]) {
                PurchaseVipController* vc = [[PurchaseVipController alloc] init];
                [controller.navigationController pushViewController:vc
                                                           animated:YES];
                [vc release];
            }
            else{
                ChargeController *vc = [[[ChargeController alloc] init] autorelease];
                [controller.navigationController pushViewController:vc animated:YES];
            }
    }];
    /*
    [dialog setClickCancelBlock:^(UILabel *label){
        
        ChargeController *vc = [[[ChargeController alloc] init] autorelease];
        [controller.navigationController pushViewController:vc animated:YES];
    }];
    */
    
    if ([PPConfigManager isInReviewVersion]) {
//        [dialog.oKButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
        [dialog.oKButton setTitle:NSLS(@"kCharge") forState:UIControlStateNormal];
    }else{
//        [dialog.oKButton setTitle:NSLS(@"kFreeIngots") forState:UIControlStateNormal];
        [dialog.oKButton setTitle:NSLS(@"kUpgradeVIP") forState:UIControlStateNormal];
    }
    
//    [dialog.cancelButton setTitle:NSLS(@"kCharge") forState:UIControlStateNormal];

    return dialog;
}

+ (void)showInController:(UIViewController *)controller
{
    if (controller) {
        CommonDialog *view = [self createView:controller];
        [view showInView:controller.view];        
    }
}


@end
