//
//  SuperUserManageAction.m
//  Draw
//
//  Created by Kira on 13-2-18.
//
//

#import "SuperUserManageAction.h"
#import "InputDialog.h"
#import "CommonDialog.h"
#import "AccountService.h"
#import "CommonMessageCenter.h"

typedef enum
{
    SuperUserManageActionIndexCharge = 0,
    SuperUserManageActionIndexBlackList,
}SuperUserManageActionIndex;

@implementation SuperUserManageAction

- (id)initWithTargetUserId:(NSString*)userId
                    nickName:(NSString*)nickName
                     balance:(int)balance
{
    self = [super init];
    if (self) {
        _targetUserId = userId;
        _targetUserNickName = nickName;
        _targetUserCurrentBalance = balance;
        
    }
    return self;
}

- (void)showInController:(UIViewController*)controller
{
    UIActionSheet* actionSheet = [[[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:@"充值" otherButtonTitles:@"列入黑名单", nil] autorelease];
    
    [actionSheet showInView:controller.view];
    _superController = controller;
}

- (BOOL)isInputValid:(NSString*)inputString
{
    NSScanner* scan = [NSScanner scannerWithString:inputString];
    int val;
    if (!([scan scanInt:&val] && [scan isAtEnd])) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:@"无效输入" delayTime:1];
        return NO;
    }
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (buttonIndex) {
        case SuperUserManageActionIndexCharge: {
            InputDialog* dialog = [InputDialog dialogWith:@"请输入要充值的金额" clickOK:^(NSString *inputStr) {
                if ([self isInputValid:inputStr]) {
                    [[AccountService defaultService] chargeAccount:inputStr.intValue toUser:_targetUserId source:SuperUserCharge];
                }
            } clickCancel:^(NSString *inputStr) {
                //
            }];
            dialog.targetTextField.keyboardType = UIKeyboardTypeNumberPad;
            [dialog.targetTextField setPlaceholder:@"请输入要充值的金额"];
            [dialog showInView:_superController.view];
        } break;
        case SuperUserManageActionIndexBlackList: {
            CommonDialog* dialog = [CommonDialog createDialogWithTitle:nil message:@"确定要将该用户加入黑名单吗？" style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
                //
            } clickCancelBlock:^{
                //
            }];
            [dialog showInView:_superController.view];
        } break;
            
        default:
            break;
    }
    
}

@end
