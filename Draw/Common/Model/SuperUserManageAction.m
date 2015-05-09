//
//  SuperUserManageAction.m
//  Draw
//
//  Created by Kira on 13-2-18.
//
//

#import "SuperUserManageAction.h"
#import "CommonDialog.h"
#import "AccountService.h"
#import "CommonMessageCenter.h"
#import "UserService.h"
#import "GameBasic.pb.h"
#import "MKBlockActionSheet.h"
#import "StringUtil.h"
#import "ChatService.h"
#import "PPConfigManager.h"
#import "GroupService.h"

typedef enum
{
    SuperUserManageActionIndexCharge = 0,
    SuperUserManageActionIndexVIP,
    SuperUserManageActionIndexFeatureOpus,
    SuperUserManageActionIndexSetXiaoji,
    SuperUserManageActionIndexResetUserPassword,
    SuperUserManageActionIndexBlackUserId,
    SuperUserManageActionIndexBlackDevice,
    SuperUserManageActionIndexUnblackUserId,
    SuperUserManageActionIndexUnblackDevice,
    SuperUserManageActionIndexFixEmptyUserById,
    SuperUserManageActionIndexFixEmptyUserByXiaoji,
    SuperUserManageActionIndexRecoverOpus,
    SuperUserManageActionIndexExportOpusImage,
    SuperUserManageActionIndexChargeIngot,
    SuperUserManageActionIndexDismissGroup

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

- (id)initWithPBGameUser:(PBGameUser *)pbUser
{
    self = [super init];
    if (self) {
        _targetUserId = pbUser.userId;
        _targetUserNickName = pbUser.nickName;
        _targetUserCurrentBalance = pbUser.coinBalance;
        _targetUserCurrentIngot = pbUser.ingotBalance;
        self.pbUser = pbUser;
    }
    return self;
}

- (void)showInController:(UIViewController*)controller
{
    UIActionSheet* actionSheet = [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@(userId:%@,金币:%d 元宝:%d)", _targetUserNickName, _targetUserId, _targetUserCurrentBalance, _targetUserCurrentIngot] delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:@"金币充值" otherButtonTitles:@"VIP购买", @"用户作品推荐设置", @"设置小吉号码", @"重置用户密码", @"加入用户黑名单", @"加入设备黑名单", @"从用户黑名单解禁", @"从设备黑名单解禁", @"用户数据修复 by ID", @"用户数据修复 by 小吉", @"恢复用户作品", @"导出用户作品图片", @"元宝充值", @"解散家族" , nil] autorelease];
    
    [actionSheet showInView:controller.view];
    _superController = controller;
}

+ (BOOL)isInputValid:(NSString*)inputString
{
    NSScanner* scan = [NSScanner scannerWithString:inputString];
    int val;
    if (!([scan scanInt:&val] && [scan isAtEnd])) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:@"无效输入" delayTime:1];
        return NO;
    }
    return YES;
}

+ (BOOL)isInputValidXiaoji:(NSString*)inputString
{
    NSScanner* scan = [NSScanner scannerWithString:inputString];
    int val;
    if (!([scan scanInt:&val] && [scan isAtEnd])) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:@"无效输入" delayTime:1];
        return NO;
    }

    if ([inputString length] != 9){
        [[CommonMessageCenter defaultCenter] postMessageWithText:@"长度不对" delayTime:1];
    }
    
    return YES;
}

+ (void)askBlackUser:(NSString*)targetUserId viewController:(UIViewController*)viewController
{
    CommonDialog* inputDialog = [CommonDialog createInputFieldDialogWith:@"请输入要封禁的天数"];
    [inputDialog setClickOkBlock:^(UITextField *tf) {
        if ([SuperUserManageAction isInputValid:tf.text]) {
            int days = tf.text.intValue;
            
            if ([[UserManager defaultManager] isSuperUser] == NO && (days <=0 || days > [PPConfigManager boardManagerBlackUserDays])){
                NSString* msg = [NSString stringWithFormat:@"封禁天数超过当前权限，最多可以封禁%d天", [PPConfigManager boardManagerBlackUserDays]];
                POSTMSG(msg);
                return;
            }
            
            CommonDialog* dialog = [CommonDialog createDialogWithTitle:nil message:@"确定要将该用户加入黑名单吗？" style:CommonDialogStyleDoubleButton];
            [dialog setClickOkBlock:^(UILabel *label){
                [[UserService defaultService] superBlackUser:targetUserId
                                                        type:BLACK_USER_TYPE_USERID
                                                        days:days
                                                successBlock:^{
                                                    [[CommonMessageCenter defaultCenter] postMessageWithText:@"加入黑名单成功" delayTime:1];
                                                }];
            }];
            
            [dialog showInView:viewController.view];
        }
    }];
    
    [inputDialog.inputTextField setPlaceholder:@"请输入要禁言的天数"];
    [inputDialog.inputTextField setText:@"3"];
    [inputDialog showInView:viewController.view];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue()
                   , ^{
                       
                       switch (buttonIndex) {
                           case SuperUserManageActionIndexCharge: {
                               
                               CommonDialog* dialog = [CommonDialog createInputFieldDialogWith:@"请输入要充值的金币数"];
                               [dialog setClickOkBlock:^(UITextField *tf) {
                                   if ([SuperUserManageAction isInputValid:tf.text]) {
                                       [[AccountService defaultService] chargeCoin:tf.text.intValue toUser:_targetUserId source:SuperUserCharge];
                                   }
                               }];
                               
                               [dialog.inputTextField setPlaceholder:@"请输入要充值的金币数"];
                               [dialog showInView:_superController.view];
                           } break;
                               
                           case SuperUserManageActionIndexSetXiaoji: {
                               
                               CommonDialog* dialog = [CommonDialog createInputFieldDialogWith:@"请输入要设置的小吉号码"];
                               [dialog setClickOkBlock:^(UITextField *tf) {
                                   if ([SuperUserManageAction isInputValidXiaoji:tf.text]) {
                                       [[UserNumberService defaultService] setUserXiaoji:_targetUserId
                                                                                  xiaoji:tf.text
                                                                                   block:^(int resultCode, NSString *number) {
                                                                                       if (resultCode == 0){
                                                                                           POSTMSG(@"设置小吉号码成功");
                                                                                       }
                                                                                       else{
                                                                                           POSTMSG(@"设置失败");
                                                                                       }
                                                                                   }];
                                   }
                               }];
                               
                               [dialog.inputTextField setPlaceholder:@"请输入要设置的小吉号码"];
                               [dialog showInView:_superController.view];
                           } break;
                               
                           case SuperUserManageActionIndexVIP:{
                               
                               int buyMonthVIP = 0;
                               int buyYearVIP = 1;
                               
                               MKBlockActionSheet* sheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"选项")
                                                                                            delegate:nil
                                                                                   cancelButtonTitle:NSLS(@"取消")
                                                                              destructiveButtonTitle:NSLS(@"购买包月VIP")
                                                                                   otherButtonTitles:NSLS(@"购买包年VIP"), nil];
                               
                               [sheet setActionBlock:^(NSInteger buttonIndex){
                                   int type = -1;
                                   if (buttonIndex == buyMonthVIP) {
                                       type = VIP_BUY_TYPE_MONTH;
                                   }else if (buttonIndex == buyYearVIP){
                                       type = VIP_BUY_TYPE_YEAR;
                                   }
                                   else{
                                   }
                                   
                                   if (type != -1){
                                       [[UserService defaultService] purchaseVipService:type
                                                                                 userId:_targetUserId
                                                                         viewController:nil
                                                                            resultBlock:^(int resultCode) {
                                                                                if (resultCode == 0){
                                                                                    POSTMSG(@"购买成功");
                                                                                }
                                                                                else{
                                                                                    NSString* msg = [NSString stringWithFormat:@"购买失败,错误码为%d", resultCode];
                                                                                    POSTMSG(msg);
                                                                                }
                                                                            }];
                                   }
                                   
                                   [sheet setActionBlock:NULL];
                               }];
                               
                               [sheet showInView:_superController.view];
                               [sheet release];
                               
                           }
                               break;
                               
                           case SuperUserManageActionIndexChargeIngot: {
                               
                               CommonDialog* dialog = [CommonDialog createInputFieldDialogWith:@"请输入要充值的元宝数"];
                               [dialog setClickOkBlock:^(UITextField *tf) {
                                   if ([SuperUserManageAction isInputValid:tf.text]) {
                                       [[AccountService defaultService] chargeIngot:tf.text.intValue toUser:_targetUserId source:SuperUserCharge];
                                   }
                               }];
                               
                               dialog.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
                               [dialog.inputTextField setPlaceholder:@"请输入要充值的元宝数"];
                               [dialog showInView:_superController.view];
                           } break;
                               
                           case SuperUserManageActionIndexDismissGroup:{
                               
                               NSString* groupId = self.pbUser.groupInfo.groupId;
                               if ([groupId length] == 0){
                                   POSTMSG(@"用户不属于任何家族");
                               }
                               else{
                                   NSString* msg = [NSString stringWithFormat:@"确定要解散该用户的家族[%@]吗？",
                                                    self.pbUser.groupInfo.groupName];
                                   CommonDialog* dialog = [CommonDialog createDialogWithTitle:nil message:msg style:CommonDialogStyleDoubleButton];
                                   [dialog setClickOkBlock:^(UILabel *label){
                                       [[GroupService defaultService] dismissGroup:groupId
                                                                            userId:_targetUserId
                                                                          callback:^(NSError *error) {
                                                                              if (error == nil){
                                                                                  POSTMSG(@"家族成功解散");
                                                                              }
                                                                          }];
                                   }];
                                   
                                   [dialog showInView:_superController.view];
                               }
                               break;
                           }
                               
                           case SuperUserManageActionIndexFeatureOpus:{
                               
                               int indexOfFeatureOpusDraw = 0;
                               int indexOfCancelFeatureOpusDraw = 1;
                               
                               MKBlockActionSheet* sheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"选项")
                                                                                            delegate:nil
                                                                                   cancelButtonTitle:NSLS(@"取消")
                                                                              destructiveButtonTitle:NSLS(@"可推荐画画作品")
                                                                                   otherButtonTitles:NSLS(@"取消推荐画画作品"), nil];
                               
                               [sheet setActionBlock:^(NSInteger buttonIndex){
                                   if (buttonIndex == indexOfFeatureOpusDraw) {
                                       // TODO
                                       [[UserService defaultService] setUserFeatureOpus:_targetUserId featureOpus:1 successBlock:^{
                                       }];
                                       
                                   }else if (buttonIndex == indexOfCancelFeatureOpusDraw){
                                       [[UserService defaultService] setUserFeatureOpus:_targetUserId featureOpus:0 successBlock:^{
                                       }];
                                   }
                                   else{
                                   }
                                   
                                   [sheet setActionBlock:NULL];
                               }];
                               
                               [sheet showInView:_superController.view];
                               
                           }
                               break;
                               
                           case SuperUserManageActionIndexResetUserPassword: {
                               CommonDialog* dialog = [CommonDialog createInputFieldDialogWith:@"请输入要重置的密码(默认111111)"];
                               dialog.inputTextField.text = @"111111";
                               [dialog setClickOkBlock:^(id sender){
                                   
                                   if ([dialog.inputTextField.text length] == 0){
                                       return;
                                   }
                                   
                                   NSString* password = dialog.inputTextField.text;
                                   NSString* encryptPassword = [dialog.inputTextField.text encodeMD5Base64:PASSWORD_KEY];
                                   
                                   [[UserService defaultService] setUserPassword:_targetUserId
                                                                         pasword:encryptPassword
                                                                     resultBlock:^(int resultCode) {
                                                                         if (resultCode == 0){
                                                                             POSTMSG(@"重置密码成功");
                                                                             NSString* msg = [NSString stringWithFormat:@"你好，你的密码已经重置为%@", password];
                                                                             [[ChatService defaultService] sendTextMessage:msg friendUserId:_targetUserId isGroup:NO];
                                                                         }
                                                                         else{
                                                                             POSTMSG(@"重置密码失败");
                                                                         }
                                                                     }];
                               }];
                               
                               [dialog showInView:_superController.view];
                               
                           }
                               break;
                               
                           case SuperUserManageActionIndexBlackUserId: {
                               
                               [SuperUserManageAction askBlackUser:_targetUserId viewController:_superController];
                               
                           } break;
                           case SuperUserManageActionIndexBlackDevice: {
                               
                               CommonDialog* inputDialog = [CommonDialog createInputFieldDialogWith:@"请输入要封禁的天数"];
                               [inputDialog setClickOkBlock:^(UITextField *tf) {
                                   if ([SuperUserManageAction isInputValid:tf.text]) {
                                       int days = tf.text.intValue;
                                       
                                       CommonDialog* dialog = [CommonDialog createDialogWithTitle:nil message:@"确定要将该用户的设备加入黑名单吗？" style:CommonDialogStyleDoubleButton];
                                       [dialog setClickOkBlock:^(UILabel *label){
                                           [[UserService defaultService] superBlackUser:_targetUserId
                                                                                   type:BLACK_USER_TYPE_DEVICEID
                                                                                   days:days
                                                                           successBlock:^{
                                                                               [[CommonMessageCenter defaultCenter] postMessageWithText:@"加入黑名单成功" delayTime:1];
                                                                           }];
                                       }];
                                       
                                       [dialog showInView:_superController.view];                    
                                   }
                               }];
                               
                               [inputDialog.inputTextField setPlaceholder:@"请输入要禁言的天数"];
                               [inputDialog.inputTextField setText:@"7"];
                               [inputDialog showInView:_superController.view];
                               
                           } break;
                           case SuperUserManageActionIndexUnblackUserId: {
                               
                               CommonDialog* dialog = [CommonDialog createDialogWithTitle:nil message:@"确定解除该用户黑名单吗？" style:CommonDialogStyleDoubleButton];
                               [dialog setClickOkBlock:^(UILabel *label){
                                   [[UserService defaultService] superUnblackUser:_targetUserId type:BLACK_USER_TYPE_USERID successBlock:^{
                                       [[CommonMessageCenter defaultCenter] postMessageWithText:@"解除黑名单成功" delayTime:1];
                                   }];
                               }];
                               
                               [dialog showInView:_superController.view];
                           } break;
                           case SuperUserManageActionIndexUnblackDevice: {
                               
                               CommonDialog* dialog = [CommonDialog createDialogWithTitle:nil message:@"确定要解除该用户的设备黑名单吗？" style:CommonDialogStyleDoubleButton];
                               [dialog setClickOkBlock:^(UILabel *label){
                                   [[UserService defaultService] superUnblackUser:_targetUserId type:BLACK_USER_TYPE_DEVICEID successBlock:^{
                                       [[CommonMessageCenter defaultCenter] postMessageWithText:@"解除黑名单成功" delayTime:1];
                                   }];
                               }];
                               
                               [dialog showInView:_superController.view];
                           } break;
                               
                           case SuperUserManageActionIndexFixEmptyUserById: {
                               [[UserService defaultService] fixEmptyUserByUserId:_targetUserId successBlock:^{
                                   [[CommonMessageCenter defaultCenter] postMessageWithText:@"成功恢复用户" delayTime:1.5];
                               }];
                               
                           }
                               break;
                               
                           case SuperUserManageActionIndexFixEmptyUserByXiaoji: {
                               
                               CommonDialog* inputDialog = [CommonDialog createInputFieldDialogWith:@"请输入要封禁的天数"];
                               [inputDialog setClickOkBlock:^(UITextField *tf) {
                                   NSString* xiaoji = tf.text;
                                   [[UserService defaultService] fixEmptyUserByXiaoji:xiaoji successBlock:^{
                                       [[CommonMessageCenter defaultCenter] postMessageWithText:@"成功恢复用户" delayTime:1.5];
                                   }];
                               }];
                               
                               [inputDialog.inputTextField setPlaceholder:@"请输入要回复用户的小吉号码"];
                               [inputDialog showInView:_superController.view];
                               
                               
                           }
                               break;
                               
                           case SuperUserManageActionIndexRecoverOpus: {
                               [[UserService defaultService] recoverUserOpus:_targetUserId successBlock:^{
                                   [[CommonMessageCenter defaultCenter] postMessageWithText:@"成功恢复用户作品" delayTime:1.5];
                               }];
                           } break;
                               
                           case SuperUserManageActionIndexExportOpusImage: {
                               [[UserService defaultService] exportUserOpusImage:_targetUserId successBlock:^{
                                   [[CommonMessageCenter defaultCenter] postMessageWithText:@"请求已成功提交" delayTime:1.5];
                               }];
                           } break;
                               
                               
                           default:
                               break;
                       }
                       
                       
                   });
    
    
}

@end
