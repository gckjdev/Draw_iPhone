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
#import "UserService.h"

typedef enum
{
    SuperUserManageActionIndexCharge = 0,
    SuperUserManageActionIndexBlackUserId,
    SuperUserManageActionIndexBlackDevice,
    SuperUserManageActionIndexUnblackUserId,
    SuperUserManageActionIndexUnblackDevice,
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
    UIActionSheet* actionSheet = [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@(userId:%@,金币:%d)", _targetUserNickName, _targetUserId, _targetUserCurrentBalance] delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:@"充值" otherButtonTitles:@"加入用户黑名单", @"加入设备黑名单", @"从用户黑名单解禁", @"从设备黑名单解禁", nil] autorelease];
    
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
        case SuperUserManageActionIndexBlackUserId: {
            CommonDialog* dialog = [CommonDialog createDialogWithTitle:nil message:@"确定要将该用户加入黑名单吗？" style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
                [[UserService defaultService] superBlackUser:_targetUserId type:BLACK_USER_TYPE_USERID successBlock:^{
                    [[CommonMessageCenter defaultCenter] postMessageWithText:@"加入黑名单成功" delayTime:1];
                }];
            } clickCancelBlock:^{
                //
            }];
            [dialog showInView:_superController.view];
        } break;
        case SuperUserManageActionIndexBlackDevice: {
            CommonDialog* dialog = [CommonDialog createDialogWithTitle:nil message:@"确定要将该用户的设备加入黑名单吗？" style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
                [[UserService defaultService] superBlackUser:_targetUserId type:BLACK_USER_TYPE_DEVICEID successBlock:^{
                    [[CommonMessageCenter defaultCenter] postMessageWithText:@"加入黑名单成功" delayTime:1];
                }];
            } clickCancelBlock:^{
                //
            }];
            [dialog showInView:_superController.view];
        } break;
        case SuperUserManageActionIndexUnblackUserId: {
            CommonDialog* dialog = [CommonDialog createDialogWithTitle:nil message:@"确定解除该用户黑名单吗？" style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
                [[UserService defaultService] superUnblackUser:_targetUserId type:BLACK_USER_TYPE_USERID successBlock:^{
                    [[CommonMessageCenter defaultCenter] postMessageWithText:@"解除黑名单成功" delayTime:1];
                }];
            } clickCancelBlock:^{
                //
            }];
            [dialog showInView:_superController.view];
        } break;
        case SuperUserManageActionIndexUnblackDevice: {
            CommonDialog* dialog = [CommonDialog createDialogWithTitle:nil message:@"确定要解除该用户的设备黑名单吗？" style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
                [[UserService defaultService] superUnblackUser:_targetUserId type:BLACK_USER_TYPE_DEVICEID successBlock:^{
                    [[CommonMessageCenter defaultCenter] postMessageWithText:@"解除黑名单成功" delayTime:1];
                }];
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
