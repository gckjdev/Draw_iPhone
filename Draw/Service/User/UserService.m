//
//  UserService.m
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserService.h"
#import "GameNetworkConstants.h"
#import "GameNetworkRequest.h"
#import "UserManager.h"
#import "PPViewController.h"
#import "PPNetworkRequest.h"
#import "UIDevice+IdentifierAddition.h"
#import "UIImageExt.h"
#import "SNSConstants.h"
#import "AccountManager.h"
#import "InputDialog.h"
#import "RegisterUserController.h"

@implementation UserService

static UserService* _defaultUserService;

+ (UserService*)defaultService
{
    if (_defaultUserService == nil)
        _defaultUserService = [[UserService alloc] init];
    
    return _defaultUserService;
}

- (void)registerUser:(NSString*)email 
            password:(NSString*)password 
      viewController:(PPViewController<UserServiceDelegate, InputDialogDelegate>*)viewController
{
    
    // TODO send device id later
    
    NSString* deviceToken = [[UserManager defaultManager] deviceToken];
    NSString* deviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    
    [viewController showActivityWithText:NSLS(@"kRegisteringUser")];    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = nil;        
        output = [GameNetworkRequest registerUserByEmail:SERVER_URL 
                                                       appId:APP_ID 
                                                       email:email 
                                                    password:password
                                                 deviceToken:deviceToken 
                                                deviceId:deviceId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS) {
                // save return User ID locally
                NSString* userId = [output.jsonDataDict objectForKey:PARA_USERID]; 
                NSString* nickName = [UserManager nickNameByEmail:email];
                
                // save data                
                [[UserManager defaultManager] saveUserId:userId 
                                                   email:email 
                                                password:password 
                                                nickName:nickName 
                                               avatarURL:nil];

                int balance = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE] intValue];
                [[AccountManager defaultManager] updateBalanceFromServer:balance];
                  
                if ([viewController respondsToSelector:@selector(didUserRegistered:)]){
                    [viewController didUserRegistered:output.resultCode];                    
                }
            }
            else if (output.resultCode == ERROR_NETWORK) {
                [viewController popupUnhappyMessage:NSLS(@"kSystemFailure") title:nil];
            }
            else if (output.resultCode == ERROR_USERID_NOT_FOUND) {
                // @"对不起，用户注册无法完成，请联系我们的技术支持以便解决问题"
                [viewController popupUnhappyMessage:NSLS(@"kUnknownRegisterFailure") title:nil];
            }
            else if (output.resultCode == ERROR_EMAIL_EXIST) {
                // @"对不起，该电子邮件已经被注册"
                //[viewController popupUnhappyMessage:NSLS(@"kEmailUsed") title:nil];
                InputDialog *dialog = [InputDialog dialogWith:NSLS(@"kPassword") delegate:viewController];
                [dialog.targetTextField setPlaceholder:NSLS(@"kEnterPassword")];
                [dialog showInView:viewController.view];
            }
            else if (output.resultCode == ERROR_EMAIL_NOT_VALID) {
                // @"对不起，该电子邮件格式不正确，请重新输入"
                [viewController popupUnhappyMessage:NSLS(@"kEmailNotValid") title:nil];
            }
            else {
                // @"对不起，注册失败，请稍候再试"
                [viewController popupUnhappyMessage:NSLS(@"kGeneralFailure") title:nil];
            }
        });
        
    });    
}

- (int)getRegisterType:(NSDictionary*)userInfo
{
    NSString* networkName = [userInfo objectForKey:SNS_NETWORK];
    if ([networkName isEqualToString:SNS_SINA_WEIBO]){
        return REGISTER_TYPE_SINA;
    }
    else if ([networkName isEqualToString:SNS_QQ_WEIBO]){
        return REGISTER_TYPE_QQ;
    }
    else if ([networkName isEqualToString:SNS_FACEBOOK]){
        return REGISTER_TYPE_FACEBOOK;
    }
    else if ([networkName isEqualToString:SNS_TWITTER]){
        return REGISTER_TYPE_TWITTER;
    }
    
    NSLog(@"<getRegisterType> cannot find SNS type for network name = %@", networkName);
    return -1;
}

- (void)registerUserWithSNSUserInfo:(NSDictionary*)userInfo 
                     viewController:(PPViewController<UserServiceDelegate>*)viewController
{
    NSString* appId = APP_ID;
    NSString* deviceToken = [[UserManager defaultManager] deviceToken];
    NSString* deviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    NSString* loginId = [userInfo objectForKey:SNS_USER_ID];
    int loginIdType = [self getRegisterType:userInfo];
    
    [viewController showActivityWithText:NSLS(@"kRegisteringUser")];    
    dispatch_async(workingQueue, ^{            
        
        CommonNetworkOutput* output = 
        [GameNetworkRequest registerUserBySNS:SERVER_URL
                                        snsId:loginId
                                 registerType:loginIdType
                                        appId:appId
                                  deviceToken:deviceToken
                                     nickName:[userInfo objectForKey:SNS_NICK_NAME]
                                       avatar:[userInfo objectForKey:SNS_USER_IMAGE_URL]
                                  accessToken:[userInfo objectForKey:SNS_OAUTH_TOKEN]
                            accessTokenSecret:[userInfo objectForKey:SNS_OAUTH_TOKEN_SECRET]
                                     province:[[userInfo objectForKey:SNS_PROVINCE] intValue]
                                         city:[[userInfo objectForKey:SNS_CITY] intValue]
                                     location:[userInfo objectForKey:SNS_LOCATION]
                                       gender:[userInfo objectForKey:SNS_GENDER]
                                     birthday:[userInfo objectForKey:SNS_BIRTHDAY]
                                       domain:[userInfo objectForKey:SNS_DOMAIN]
                                     deviceId:deviceId];                
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS){
                // save user data locally
                NSString* userId = [output.jsonDataDict objectForKey:PARA_USERID];
                
                if (loginIdType == REGISTER_TYPE_SINA){
                    [[UserManager defaultManager] saveUserId:userId
                                                      sinaId:loginId
                                                    password:nil 
                                                    nickName:[userInfo objectForKey:SNS_NICK_NAME] 
                                                   avatarURL:[userInfo objectForKey:SNS_USER_IMAGE_URL]
                                             sinaAccessToken:[userInfo objectForKey:SNS_OAUTH_TOKEN]
                                       sinaAccessTokenSecret:[userInfo objectForKey:SNS_OAUTH_TOKEN_SECRET]];
                }
                else if (loginIdType == REGISTER_TYPE_QQ) {  
                    [[UserManager defaultManager] saveUserId:userId
                                                      qqId:loginId
                                                    password:nil 
                                                    nickName:[userInfo objectForKey:SNS_NICK_NAME] 
                                                   avatarURL:[userInfo objectForKey:SNS_USER_IMAGE_URL]
                                             qqAccessToken:[userInfo objectForKey:SNS_OAUTH_TOKEN]
                                       qqAccessTokenSecret:[userInfo objectForKey:SNS_OAUTH_TOKEN_SECRET]];                    
                }   
                else if (loginIdType == REGISTER_TYPE_FACEBOOK) {  
                    [[UserManager defaultManager] saveUserId:userId
                                                  facebookId:loginId
                                                    password:nil 
                                                    nickName:[userInfo objectForKey:SNS_NICK_NAME] 
                                                   avatarURL:[userInfo objectForKey:SNS_USER_IMAGE_URL]];                    
                }   
                
                int balance = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE] intValue];
                [[AccountManager defaultManager] updateBalanceFromServer:balance];
            }
            else if (output.resultCode == ERROR_NETWORK) {
                [viewController popupUnhappyMessage:NSLS(@"kSystemFailure") title:nil];
            }
            else if (output.resultCode == ERROR_USERID_NOT_FOUND) {
                // @"对不起，用户注册无法完成，请联系我们的技术支持以便解决问题"
                [viewController popupUnhappyMessage:NSLS(@"kUnknownRegisterFailure") title:nil];
            }
            else if (output.resultCode == ERROR_EMAIL_EXIST) {
                // @"对不起，该电子邮件已经被注册"
                [viewController popupUnhappyMessage:NSLS(@"kEmailUsed") title:nil];
            }
            else if (output.resultCode == ERROR_EMAIL_NOT_VALID) {
                // @"对不起，该电子邮件格式不正确，请重新输入"
                [viewController popupUnhappyMessage:NSLS(@"kEmailNotValid") title:nil];
            }
            else {
                // @"对不起，注册失败，请稍候再试"
                [viewController popupUnhappyMessage:NSLS(@"kGeneralFailure") title:nil];
            }
            
            if ([viewController respondsToSelector:@selector(didUserRegistered:)]){
                [viewController didUserRegistered:output.resultCode];                    
            }
        }); 
    });
    
}

- (void)updateUserAvatar:(UIImage*)avatarImage 
                nickName:(NSString*)nickName 
                  gender:(NSString*)gender
                password:(NSString*)pwd
          viewController:(PPViewController<UserServiceDelegate>*)viewController
{
    // save data locally firstly
    [[UserManager defaultManager] setNickName:nickName];
    [[UserManager defaultManager] setGender:gender];
    [[UserManager defaultManager] setPassword:pwd];
    [[UserManager defaultManager] saveAvatarLocally:avatarImage];
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* deviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    NSString* deviceToken = [[UserManager defaultManager] deviceToken];
    NSString* password = [[UserManager defaultManager] password];
    
    [viewController showActivityWithText:NSLS(@"kUpdatingUser")];
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest updateUser:SERVER_URL 
                                                               appId:APP_ID 
                                                              userId:userId 
                                                            deviceId:deviceId 
                                                         deviceToken:deviceToken 
                                                            nickName:nickName 
                                                            password:password 
                                                              avatar:[avatarImage data]];
                
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS){
                [viewController popupHappyMessage:NSLS(@"kUpdateUserSucc") title:@""];
                
                // update avatar
                NSString* retURL = [[output jsonDataDict] objectForKey:PARA_AVATAR];
                [[UserManager defaultManager] setAvatar:retURL];
            }
            else{
                [viewController popupUnhappyMessage:NSLS(@"kUpdateUserFail") title:@""];
            }
            
            if ([viewController respondsToSelector:@selector(didUserUpdated:)]){
                [viewController didUserUpdated:output.resultCode];
            }
        });
    });
    
}



- (void)updateUserAvatar:(UIImage*)avatarImage 
                nickName:(NSString*)nickName 
                  gender:(NSString*)gender
          viewController:(PPViewController<UserServiceDelegate>*)viewController
{
    [self updateUserAvatar:avatarImage 
                  nickName:nickName 
                    gender:gender 
                  password:nil 
            viewController:viewController];
}


#define FEED_BACK_TYPE_ADVICE 1
#define FEED_BACK_TYPE_BUGS 0

- (void)feedback:(NSString*)feedback 
     WithContact:(NSString*)contact  
  viewController:(PPViewController<UserServiceDelegate>*)viewController
{    
    NSString* userId = [[UserManager defaultManager] userId];
    
    [viewController showActivityWithText:NSLS(@"kSendingFeedback")];
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest feedbackUser:SERVER_URL 
                                                               appId:APP_ID 
                                                              userId:userId 
                                                              feedback:feedback 
                                                               contact:contact
                                                                  type:FEED_BACK_TYPE_ADVICE];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS){
                [viewController popupHappyMessage:NSLS(@"kFeedbackSucc") title:@""];
            }
            else{
                [viewController popupUnhappyMessage:NSLS(@"kFeedbackFail") title:@""];
            }
            
            if ([viewController respondsToSelector:@selector(didSendFeedback::)]){
                [viewController didSendFeedback:output.resultCode];
            }
        });
    });
}

- (void)reportBugs:(NSString*)bugDescription 
       withContact:(NSString*)contact  
    viewController:(PPViewController<UserServiceDelegate>*)viewController
{
    NSString* userId = [[UserManager defaultManager] userId];
    
    [viewController showActivityWithText:NSLS(@"kSendingFeedback")];
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest feedbackUser:SERVER_URL 
                                                                 appId:APP_ID 
                                                                userId:userId 
                                                              feedback:bugDescription 
                                                               contact:contact
                                                                  type:FEED_BACK_TYPE_BUGS];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS){
                [viewController popupHappyMessage:NSLS(@"kFeedbackSucc") title:@""];
            }
            else{
                [viewController popupUnhappyMessage:NSLS(@"kFeedbackFail") title:@""];
            }
            
            if ([viewController respondsToSelector:@selector(didSendFeedback::)]){
                [viewController didSendFeedback:output.resultCode];
            }
        });
    });
}

- (void)loginUserByEmail:(NSString*)email 
                password:(NSString*)password 
          viewController:(PPViewController<UserServiceDelegate>*)viewController
{
    NSString* appId = APP_ID;
    NSString* deviceToken = [[UserManager defaultManager] deviceToken];
    
    [viewController showActivityWithText:NSLS(@"kLoginUser")];    
    dispatch_async(workingQueue, ^{            
        
        CommonNetworkOutput* output = 
        [GameNetworkRequest loginUser:SERVER_URL 
                                appId:appId 
                                email:email 
                             password:password 
                          deviceToken:deviceToken];                
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS){
                // save return User ID locally
                NSString* userId = [output.jsonDataDict objectForKey:PARA_USERID]; 
                NSString* nickName = [UserManager nickNameByEmail:email];
                
                // save data                
                [[UserManager defaultManager] saveUserId:userId 
                                                   email:email 
                                                password:password 
                                                nickName:nickName 
                                               avatarURL:nil];
                
                int balance = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE] intValue];
                [[AccountManager defaultManager] updateBalanceFromServer:balance];
                
                if ([viewController respondsToSelector:@selector(didUserLogined:)]){
                    [viewController didUserLogined:output.resultCode];                    
                }
            }
            else if (output.resultCode == ERROR_NETWORK) {
                [viewController popupUnhappyMessage:NSLS(@"kSystemFailure") title:nil];
            }
            else if (output.resultCode == ERROR_USER_EMAIL_NOT_FOUND) {
                // @"该邮箱地址尚未注册"
                [viewController popupUnhappyMessage:NSLS(@"kEmailNotFound") title:nil];
            }
            else if (output.resultCode == ERROR_PASSWORD_NOT_MATCH) {
                // @"密码错误 "
                [viewController popupUnhappyMessage:NSLS(@"kPsdNotMatch") title:nil];
            }
            else if (output.resultCode == ERROR_EMAIL_NOT_VALID) {
                // @"对不起，该电子邮件格式不正确，请重新输入"
                [viewController popupUnhappyMessage:NSLS(@"kEmailNotValid") title:nil];
            }
            else {
                // @"登录失败，稍后尝试"
                [viewController popupUnhappyMessage:NSLS(@"kLoginFailure") title:nil];
            }
            
            if ([viewController respondsToSelector:@selector(didUserRegistered:)]){
                [viewController didUserRegistered:output.resultCode];                    
            }
        }); 
    });
    
}

- (void)loginByDeviceWithViewController:(PPViewController*)homeController
{
    NSString* appId = APP_ID;
    NSString* deviceToken = [[UserManager defaultManager] deviceToken];
    NSString* deviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    
    [homeController showActivityWithText:NSLS(@"kLoginUser")];    
    dispatch_async(workingQueue, ^{            
        
        CommonNetworkOutput* output = 
        [GameNetworkRequest loginUser:SERVER_URL 
                                appId:appId 
                             deviceId:deviceId
                          deviceToken:deviceToken];                
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [homeController hideActivity];
            if (output.resultCode == ERROR_SUCCESS){
                int balance = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE] intValue];
                NSString* userId = [output.jsonDataDict objectForKey:PARA_USERID];
                NSString* email = [output.jsonDataDict objectForKey:PARA_EMAIL];
                NSString* nickName = [output.jsonDataDict objectForKey:PARA_NICKNAME];
                NSString* password = [output.jsonDataDict objectForKey:PARA_PASSWORD];
                NSString* avatar = [output.jsonDataDict objectForKey:PARA_AVATAR];
                NSString* qqAccessToken = [output.jsonDataDict objectForKey:PARA_QQ_ACCESS_TOKEN];
                NSString* qqAccessSecret = [output.jsonDataDict objectForKey:PARA_QQ_ACCESS_TOKEN_SECRET];
                NSString* qqId = [output.jsonDataDict objectForKey:PARA_QQ_ID];
                NSString* sinaAccessToken = [output.jsonDataDict objectForKey:PARA_SINA_ACCESS_TOKEN];
                NSString* sinaAccessSecret = [output.jsonDataDict objectForKey:PARA_SINA_ACCESS_TOKEN_SECRET];
                NSString* sinaId = [output.jsonDataDict objectForKey:PARA_SINA_ID];
                NSString* facebookId = [output.jsonDataDict objectForKey:PARA_FACEBOOKID]; 
                if (nickName == nil || [nickName length] == 0) {
                    nickName = [output.jsonDataDict objectForKey:PARA_SINA_NICKNAME];
                    if (nickName == nil || [nickName length] == 0) {
                        nickName = [output.jsonDataDict objectForKey:PARA_QQ_NICKNAME];
                    }
                } 
                [[UserManager defaultManager] saveUserId:userId 
                                                   email:email 
                                                password:password 
                                                nickName:nickName 
                                                    qqId:qqId 
                                           qqAccessToken:qqAccessToken 
                                     qqAccessTokenSecret:qqAccessSecret 
                                                  sinaId:sinaId 
                                         sinaAccessToken:sinaAccessToken
                                   sinaAccessTokenSecret:sinaAccessSecret 
                                              facebookId:facebookId 
                                               avatarURL:avatar];
                
                [[AccountManager defaultManager] updateBalanceFromServer:balance];
                
            }
            else if (output.resultCode == ERROR_NETWORK) {
                [homeController popupUnhappyMessage:NSLS(@"kSystemFailure") title:nil];
            }
            else if (output.resultCode == ERROR_DEVICE_NOT_BIND) {
                // @"设备未绑定任何用户"
                [RegisterUserController showAt:homeController];
            }
            else {
                // @"登录失败，稍后尝试"
                [homeController popupUnhappyMessage:NSLS(@"kLoginFailure") title:nil];
            }
        }); 
    });
    
}
//- (void)checkDevice
//{    
//    NSLog(@"current user Id is %@", user.userId);    
//    NSString* userId = [[UserManager defaultManager] userId];
//    if (userId == nil){
//        // not login yet, read server data later
//    }
//    else{
//        // already has local data, just sync balance & item data
//    }
//    
//    if (userCurrentStatus != USER_EXIST_LOCAL_STATUS_LOGIN){
//        dispatch_async(workingQueue, ^{
//            CommonNetworkOutput* output = [GroupBuyNetworkRequest deviceLogin:SERVER_URL appId:GlobalGetPlaceAppId() needReturnUser:YES deviceToken:deviceToken];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (output.resultCode == ERROR_SUCCESS) {
//                    // save return User ID locally
//                    NSString* userId = [output.jsonDataDict objectForKey:PARA_USERID]; 
//                    NSString* avatar = [output.jsonDataDict objectForKey:PARA_AVATAR]; 
//                    NSString* email = [output.jsonDataDict objectForKey:PARA_EMAIL];
//                    NSString* nickName = [output.jsonDataDict objectForKey:PARA_NICKNAME];
//                    NSString* qqAccessToken = [output.jsonDataDict objectForKey:PARA_QQ_ACCESS_TOKEN];
//                    NSString* qqAccessTokenSecret = [output.jsonDataDict objectForKey:PARA_QQ_ACCESS_TOKEN_SECRET];
//                    NSString* sinaAccessToken = [output.jsonDataDict objectForKey:PARA_SINA_ACCESS_TOKEN];
//                    NSString* sinaAccessTokenSecret = [output.jsonDataDict objectForKey:PARA_SINA_ACCESS_TOKEN_SECRET];
//                    NSString* password = [output.jsonDataDict objectForKey:PARA_PASSWORD];
//                    NSString* sinaLoginId = [output.jsonDataDict objectForKey:PARA_SINA_ID];
//                    NSString* qqLoginId = [output.jsonDataDict objectForKey:PARA_QQ_ID];
//                    
//                    [UserManager createUserWithUserId:userId 
//                                                email:email 
//                                             password:password 
//                                             nickName:nickName 
//                                               avatar:avatar 
//                                          sinaLoginId:sinaLoginId 
//                                      sinaAccessToken:sinaAccessToken 
//                                sinaAccessTokenSecret:sinaAccessTokenSecret                      
//                                            qqLoginId:qqLoginId                     
//                                        qqAccessToken:qqAccessToken 
//                                  qqAccessTokenSecret:qqAccessTokenSecret];
//                    
//                    [self updateUserCache];
//                }
//                else if (output.resultCode == ERROR_DEVICE_NOT_BIND){
//                    // send registration request
//                    [self registerUserByDevice];
//                }
//                else{
//                    // TODO, need to handle different error code
//                }
//            });
//            
//        });
//    }
//    else{
//        dispatch_async(workingQueue, ^{
//            [GroupBuyNetworkRequest deviceLogin:SERVER_URL appId:GlobalGetPlaceAppId() needReturnUser:NO deviceToken:deviceToken];        
//        });
//    }
//    
//    
//    if (delegate && [delegate respondsToSelector:@selector(checkDeviceResult:)]){
//        [delegate checkDeviceResult:userCurrentStatus];        
//    }    
//}

@end
