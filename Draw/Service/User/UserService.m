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
#import "UIDevice+IdentifierAddition.h"
#import "UIImageExt.h"
#import "PPSNSConstants.h"
#import "AccountManager.h"
#import "InputDialog.h"
#import "RegisterUserController.h"
#import "AccountService.h"
#import "FriendService.h"
#import "FriendManager.h"
#import "LevelService.h"
#import "UserService.h"
#import "ConfigManager.h"
#import "TopPlayer.h"
#import "PPSNSIntegerationService.h"
#import "PPSNSCommonService.h"
#import "PPSNSStorageService.h"
#import "PPNetworkRequest.h"
#import "MyFriend.h"
#import "StatisticManager.h"

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
    
    NSString* deviceToken = [[UserManager defaultManager] deviceToken];
    NSString* deviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    
    [viewController showActivityWithText:NSLS(@"kRegisteringUser")];    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = nil;        
        output = [GameNetworkRequest registerUserByEmail:SERVER_URL
                                                   appId:[ConfigManager appId]
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
                [[AccountManager defaultManager] updateBalance:balance];
                  
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
                [viewController popupUnhappyMessage:NSLS(@"kEmailUsed") title:nil];
                InputDialog *dialog = [InputDialog dialogWith:NSLS(@"kUserLogin") delegate:viewController];
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

- (void)updateUserWithSNSUserInfo:(NSString*)userId
                         userInfo:(NSDictionary*)userInfo 
                   viewController:(PPViewController<UserServiceDelegate>*)viewController
{
    PPDebug(@"<updateUserWithSNSUserInfo> userId=%@, userInfo=%@", userId, [userInfo description]);
    
    NSString* appId = [ConfigManager appId];
    NSString* loginId = [userInfo objectForKey:SNS_USER_ID];
    int loginIdType = [self getRegisterType:userInfo];
    
    NSString* nickName = [userInfo objectForKey:SNS_NICK_NAME];
    NSString* gender = [userInfo objectForKey:SNS_GENDER];
    NSString* location = [userInfo objectForKey:SNS_LOCATION];
    NSString* sinaId = nil;
    NSString* qqId = nil;
    NSString* facebookId = nil;
    NSString* qqNickName = nil;
    NSString* sinaNickName = nil;
    NSString* qqToken = nil;
    NSString* qqTokenSecret = nil;
    NSString* sinaToken = nil;
    NSString* sinaRefreshToken = nil;
    NSDate*   sinaExpireDate = nil;
    NSString* qqRefreshToken = nil;
    NSDate*   qqExpireDate = nil;
    NSString* qqOpenId = nil;
    NSString* facebookAccessToken = nil;
    NSDate*   facebookExpireDate = nil;

    NSString* newNickName = nil;
    if ([[[UserManager defaultManager] nickName] length] == 0){
        newNickName = nickName;
    }
    
    NSString* avatar = nil;
    if ([[[UserManager defaultManager] avatarURL] length] == 0){
        avatar = [userInfo objectForKey:SNS_USER_IMAGE_URL];
        PPDebug(@"<updateUserWithSNSUserInfo> set avatar to %@", avatar);
    }
    else{
        PPDebug(@"<updateUserWithSNSUserInfo> avatar exists, no change");
    }
    
    
    switch (loginIdType) {
        case REGISTER_TYPE_SINA:
            sinaId = loginId;
            sinaNickName = nickName;
            sinaToken = [userInfo objectForKey:SNS_OAUTH_TOKEN];
            sinaExpireDate = [userInfo objectForKey:SNS_EXPIRATION_DATE];
            sinaRefreshToken = [userInfo objectForKey:SNS_REFRESH_TOKEN];
            break;
        
        case REGISTER_TYPE_QQ:
            qqId = loginId;
            qqNickName = nickName;
            qqToken = [userInfo objectForKey:SNS_OAUTH_TOKEN];
            qqTokenSecret = [userInfo objectForKey:SNS_OAUTH_TOKEN_SECRET];
            qqExpireDate = [userInfo objectForKey:SNS_EXPIRATION_DATE];
            qqRefreshToken = [userInfo objectForKey:SNS_REFRESH_TOKEN];
            qqOpenId = [userInfo objectForKey:SNS_QQ_OPEN_ID];
            break;
            
        case REGISTER_TYPE_FACEBOOK:
            facebookId = loginId;
            facebookAccessToken = [userInfo objectForKey:SNS_OAUTH_TOKEN];
            facebookExpireDate = [userInfo objectForKey:SNS_EXPIRATION_DATE];
            break;
            
        default:
            break;
    }
    
    PPDebug(@"<updateUserWithSNSUserInfo> userId=%@, userInfo=%@", userId, [userInfo description]);
    
    [viewController showActivityWithText:NSLS(@"kUpdatingUser")];
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = 
        [GameNetworkRequest updateUser:SERVER_URL
                                 appId:appId
                                userId:userId
                              deviceId:nil
                           deviceToken:nil
                              nickName:newNickName
                                gender:gender
                              password:nil
                                avatar:avatar
                              location:location
                                sinaId:sinaId
                          sinaNickName:sinaNickName
                             sinaToken:sinaToken
                             sinaSecret:nil
                      sinaRefreshToken:sinaRefreshToken
                        sinaExpireDate:sinaExpireDate
                                  qqId:qqId
                            qqNickName:qqNickName
                               qqToken:qqToken         
                         qqTokenSecret:qqTokenSecret
                        qqRefreshToken:qqRefreshToken
                          qqExpireDate:qqExpireDate
                              qqOpenId:qqOpenId         
                            facebookId:facebookId
                   facebookAccessToken:facebookAccessToken
                    facebookExpireDate:facebookExpireDate
                                 email:nil];
  
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS){
                // save user data locally
                if (loginIdType == REGISTER_TYPE_SINA){
                    [[UserManager defaultManager] saveUserId:userId
                                                      sinaId:loginId
                                                    password:nil 
                                                    nickName:newNickName
                                                   avatarURL:avatar
                                             sinaAccessToken:nil
                                       sinaAccessTokenSecret:nil
                                                      gender:gender];
                }
                else if (loginIdType == REGISTER_TYPE_QQ) {  
                    [[UserManager defaultManager] saveUserId:userId
                                                        qqId:loginId
                                                    password:nil 
                                                    nickName:newNickName
                                                   avatarURL:avatar
                                               qqAccessToken:qqToken
                                         qqAccessTokenSecret:qqTokenSecret
                                                      gender:gender];                    
                }   
                else if (loginIdType == REGISTER_TYPE_FACEBOOK) {  
                    [[UserManager defaultManager] saveUserId:userId
                                                  facebookId:loginId
                                                    password:nil 
                                                    nickName:newNickName
                                                   avatarURL:avatar
                                                      gender:gender];                    
                }   
                
                // set location
                [[UserManager defaultManager] setLocation:location];                                
            }
            else if (output.resultCode == ERROR_NETWORK) {
                [viewController popupUnhappyMessage:NSLS(@"kSystemFailure") title:nil];
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


- (void)registerUserWithSNSUserInfo:(NSDictionary*)userInfo 
                     viewController:(PPViewController<UserServiceDelegate>*)viewController
{
    NSString* appId = [ConfigManager appId];
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
                                 refreshToken:[userInfo objectForKey:SNS_REFRESH_TOKEN]
                                   expireDate:[userInfo objectForKey:SNS_EXPIRATION_DATE]
                                     qqOpenId:[userInfo objectForKey:SNS_QQ_OPEN_ID]
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
                NSString* gender = [userInfo objectForKey:SNS_GENDER];
                
                if (loginIdType == REGISTER_TYPE_SINA){
                    [[UserManager defaultManager] saveUserId:userId
                                                      sinaId:loginId
                                                    password:nil 
                                                    nickName:[userInfo objectForKey:SNS_NICK_NAME] 
                                                   avatarURL:[userInfo objectForKey:SNS_USER_IMAGE_URL]
                                             sinaAccessToken:[userInfo objectForKey:SNS_OAUTH_TOKEN]
                                       sinaAccessTokenSecret:[userInfo objectForKey:SNS_OAUTH_TOKEN_SECRET] 
                                                      gender:gender];
                }
                else if (loginIdType == REGISTER_TYPE_QQ) {  
                    [[UserManager defaultManager] saveUserId:userId
                                                      qqId:loginId
                                                    password:nil 
                                                    nickName:[userInfo objectForKey:SNS_NICK_NAME] 
                                                   avatarURL:[userInfo objectForKey:SNS_USER_IMAGE_URL]
                                             qqAccessToken:[userInfo objectForKey:SNS_OAUTH_TOKEN]
                                         qqAccessTokenSecret:[userInfo objectForKey:SNS_OAUTH_TOKEN_SECRET] 
                                                      gender:gender];                    
                }   
                else if (loginIdType == REGISTER_TYPE_FACEBOOK) {  
                    [[UserManager defaultManager] saveUserId:userId
                                                  facebookId:loginId
                                                    password:nil 
                                                    nickName:[userInfo objectForKey:SNS_NICK_NAME] 
                                                   avatarURL:[userInfo objectForKey:SNS_USER_IMAGE_URL] 
                                                      gender:gender];                    
                }   
                
                // set location
                [[UserManager defaultManager] setLocation:[userInfo objectForKey:SNS_LOCATION]];                
                
                int balance = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE] intValue];
                [[AccountManager defaultManager] updateBalance:balance];
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
                   email:(NSString*)email
          viewController:(PPViewController<UserServiceDelegate>*)viewController
{
    // save data locally firstly
    [[UserManager defaultManager] setNickName:nickName];
    [[UserManager defaultManager] setGender:gender];
    [[UserManager defaultManager] setPassword:pwd];
    [[UserManager defaultManager] saveAvatarLocally:avatarImage];
    [[UserManager defaultManager] setEmail:email];
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* deviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    NSString* deviceToken = [[UserManager defaultManager] deviceToken];
    NSString* password = [[UserManager defaultManager] password];
    
    [viewController showActivityWithText:NSLS(@"kUpdatingUser")];
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest updateUser:SERVER_URL 
                                                               appId:[ConfigManager appId] 
                                                              userId:userId 
                                                            deviceId:deviceId 
                                                         deviceToken:deviceToken 
                                                            nickName:nickName 
                                                              gender:gender
                                                               email:email
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
                     email:nil
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
                                                               appId:[ConfigManager appId] 
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
                                                                 appId:[ConfigManager appId] 
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

- (void)commitWords:(NSString*)words 
     viewController:(PPViewController<UserServiceDelegate>*)viewController
{
    NSString* userId = [[UserManager defaultManager] userId];
    
    [viewController showActivityWithText:NSLS(@"kSendingFeedback")];
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest commitWords:SERVER_URL 
                                                                appId:[ConfigManager appId] 
                                                               userId:userId
                                                                words:words];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS){
                [viewController popupHappyMessage:NSLS(@"kAddWordsSucc") title:@""];
            }
            else{
                [viewController popupUnhappyMessage:NSLS(@"kAddWordsFail") title:@""];
            }
        });
    });
}

- (void)loginUserByEmail:(NSString*)email 
                password:(NSString*)password 
          viewController:(PPViewController<UserServiceDelegate, InputDialogDelegate>*)viewController
{
    NSString* appId = [ConfigManager appId];
    NSString* gameId = [ConfigManager gameId];
    NSString* deviceToken = [[UserManager defaultManager] deviceToken];
    
    [viewController showActivityWithText:NSLS(@"kLoginUser")];    
    dispatch_async(workingQueue, ^{            
        
        CommonNetworkOutput* output = 
        [GameNetworkRequest loginUser:SERVER_URL 
                                appId:appId 
                               gameId:gameId
                                email:email 
                             password:password 
                          deviceToken:deviceToken];                
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS){
                // save return User ID locally
                NSString* userId = [output.jsonDataDict objectForKey:PARA_USERID];
                NSString* email = [output.jsonDataDict objectForKey:PARA_EMAIL];
                NSString* nickName = [output.jsonDataDict objectForKey:PARA_NICKNAME];
                NSString* password = [output.jsonDataDict objectForKey:PARA_PASSWORD];
                NSString* avatar = [output.jsonDataDict objectForKey:PARA_AVATAR];  
                NSString* location = [output.jsonDataDict objectForKey:PARA_LOCATION];  
                
                // save data                
                [[UserManager defaultManager] saveUserId:userId 
                                                   email:email 
                                                password:password 
                                                nickName:nickName 
                                               avatarURL:avatar];
                
                [[UserManager defaultManager] setLocation:location];
                
                int balance = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE] intValue];
                [[AccountManager defaultManager] updateBalance:balance];
                
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
                InputDialog *dialog = [InputDialog dialogWith:NSLS(@"kUserLogin") delegate:viewController];
                [dialog.targetTextField setPlaceholder:NSLS(@"kEnterPassword")];
                [dialog showInView:viewController.view];
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

- (void)updateNewAppId:(NSString*)newAppId
{
    PPDebug(@"<updateNewAppId> to %@", newAppId);
    dispatch_async(workingQueue, ^{ 
        [GameNetworkRequest updateUser:SERVER_URL userId:[[UserManager defaultManager] userId] appId:newAppId newAppId:newAppId];
    });
}

- (void)loginByDeviceWithViewController:(PPViewController*)homeController
{
    NSString* appId = [ConfigManager appId];
    NSString* gameId = [ConfigManager gameId];
    NSString* deviceToken = [[UserManager defaultManager] deviceToken];
    NSString* deviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    
    [homeController showActivityWithText:NSLS(@"kConnectingServer")];    
    dispatch_async(workingQueue, ^{            
        
        CommonNetworkOutput* output = 
        [GameNetworkRequest loginUser:SERVER_URL 
                                appId:appId 
                               gameId:gameId
                             deviceId:deviceId
                          deviceToken:deviceToken];                
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [homeController hideActivity];
            if (output.resultCode == ERROR_SUCCESS){
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
                NSString* location = [output.jsonDataDict objectForKey:PARA_LOCATION];
                NSString* gender = [output.jsonDataDict objectForKey:PARA_GENDER];
                NSString* levelSring = [output.jsonDataDict objectForKey:PARA_LEVEL];
                NSString* expSring = [output.jsonDataDict objectForKey:PARA_EXP];
                
                NSString* sinaRefreshToken = [output.jsonDataDict objectForKey:PARA_SINA_REFRESH_TOKEN];
                int       sinaExpireTime = [[output.jsonDataDict objectForKey:PARA_SINA_EXPIRE_DATE] intValue];
                NSDate*   sinaExpireDate = nil;
                if (sinaExpireTime)
                    sinaExpireDate = [NSDate dateWithTimeIntervalSince1970:sinaExpireTime];
                
                NSString* qqRefreshToken = [output.jsonDataDict objectForKey:PARA_QQ_REFRESH_TOKEN];
                int       qqExpireTime = [[output.jsonDataDict objectForKey:PARA_QQ_EXPIRE_DATE] intValue];
                NSDate*   qqExpireDate = nil;
                if (qqExpireTime)
                    qqExpireDate = [NSDate dateWithTimeIntervalSince1970:qqExpireTime];
                NSString* qqOpenId = [output.jsonDataDict objectForKey:PARA_QQ_OPEN_ID];

                NSString* facebookToken = [output.jsonDataDict objectForKey:PARA_FACEBOOK_ACCESS_TOKEN];
                int       facebookExpireTime = [[output.jsonDataDict objectForKey:PARA_FACEBOOK_EXPIRE_DATE] intValue];
                NSDate*   facebookExpireDate = nil;
                if (facebookExpireTime)
                    facebookExpireDate = [NSDate dateWithTimeIntervalSince1970:facebookExpireTime];
                
                
                if (nickName == nil || [nickName length] == 0) {
                    nickName = [output.jsonDataDict objectForKey:PARA_SINA_NICKNAME];
                    if (nickName == nil || [nickName length] == 0) {
                        nickName = [output.jsonDataDict objectForKey:PARA_QQ_NICKNAME];
                    }
                } 
                NSNumber* balance = [output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE];
                NSArray* itemTypeBalanceArray = [output.jsonDataDict objectForKey:PARA_ITEMS];
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
                                               avatarURL:avatar 
                                                 balance:balance 
                                                   items:itemTypeBalanceArray 
                                                  gender:gender];
            
                [[UserManager defaultManager] setLocation:location];

                PPSNSCommonService* sinaSNSService = [[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_SINA];
                [sinaSNSService saveAccessToken:sinaAccessToken
                                   refreshToken:sinaRefreshToken
                                     expireDate:sinaExpireDate
                                         userId:sinaId
                                       qqOpenId:nil];

                PPSNSCommonService* qqSNSService = [[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ];
                [qqSNSService saveAccessToken:qqAccessToken
                                   refreshToken:qqRefreshToken
                                     expireDate:qqExpireDate
                                         userId:qqId
                                       qqOpenId:qqOpenId];

                PPSNSCommonService* facebookSNSService = [[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_FACEBOOK];
                [facebookSNSService saveAccessToken:facebookToken
                                   refreshToken:nil
                                     expireDate:facebookExpireDate
                                         userId:facebookId
                                       qqOpenId:nil];
                
                
                // TODO:SNS
//                [[QQWeiboService defaultService] saveToken:qqAccessToken secret:qqAccessSecret];
                
                
                [[LevelService defaultService] setLevel:levelSring.integerValue];
                [[LevelService defaultService] setExperience:expSring.intValue];
                
                if ([ConfigManager isProVersion]){
                    // update new appId of user
                    [self updateNewAppId:appId];
                }
                
                [[AccountService defaultService] syncAccount:nil];

            }
            else if (output.resultCode == ERROR_NETWORK) {
                [homeController popupUnhappyMessage:NSLS(@"kSystemFailure") title:nil];
            }
            else if (output.resultCode == ERROR_DEVICE_NOT_BIND) {
                // @"设备未绑定任何用户"
                // rem by Benson
                // [RegisterUserController showAt:homeController];
            }
            else {
                // @"登录失败，稍后尝试"
                [homeController popupUnhappyMessage:NSLS(@"kLoginFailure") title:nil];
            }
        }); 
    });
    
}

/*
- (void)updateAllUserInfo
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* deviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    NSString* deviceToken = [[UserManager defaultManager] deviceToken];
    NSString* nickName = [[UserManager defaultManager] nickName];
    NSString* gender = [[UserManager defaultManager] gender];
    NSString* location = [[UserManager defaultManager] location];
    NSString* sinaId = [[UserManager defaultManager] sinaId];
    NSString* sinaNickName = [[UserManager defaultManager] sinaNickName];
    NSString* sinaToken = [[UserManager defaultManager] sinaToken];
    NSString* sinaTokenSecret = [[UserManager defaultManager] sinaTokenSecret];
    NSString* qqId = [[UserManager defaultManager] qqId];
    NSString* qqNickName = [[UserManager defaultManager] qqNickName];
    NSString* qqToken = [[UserManager defaultManager] qqToken];
    NSString* qqTokenSecret = [[UserManager defaultManager] qqTokenSecret];
    NSString* facebookId = [[UserManager defaultManager] facebookId];
    NSString* email = [[UserManager defaultManager] email];
    NSString* psd = [[UserManager defaultManager] password];
    NSString* avatarUrl = [[UserManager defaultManager] avatarURL];

    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest updateUser:SERVER_URL 
                                                               appId:[ConfigManager appId] 
                                                              userId:userId 
                                                            deviceId:deviceId 
                                                         deviceToken:deviceToken 
                                                            nickName:nickName 
                                                              gender:gender
                                                            password:psd 
                                                              avatar:avatarUrl 
                                                            location:location 
                                                              sinaId:sinaId 
                                                        sinaNickName:sinaNickName 
                                                           sinaToken:sinaToken 
                                                          sinaSecret:sinaTokenSecret 
                                                                qqId:qqId 
                                                          qqNickName:qqNickName 
                                                             qqToken:qqToken 
                                                       qqTokenSecret:qqTokenSecret 
                                                          facebookId:facebookId 
                                                               email:email];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (output.resultCode == ERROR_SUCCESS){
                
                // update avatar
                NSString* retURL = [[output jsonDataDict] objectForKey:PARA_AVATAR];
                [[UserManager defaultManager] setAvatar:retURL];
            }
            else{
                
            }
            
        });
    });
}
*/

- (void)getStatistic:(PPViewController<UserServiceDelegate>*)viewController
{
    if (_isCallingGetStatistic){
        PPDebug(@"<getStatistic> but it's calling");
        return;
    }
    
    NSString* userId = [[UserManager defaultManager] userId];
    if ([userId length] == 0)
        return;
    
    _isCallingGetStatistic = YES;
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest getStatistics:TRAFFIC_SERVER_URL appId:[ConfigManager appId] userId:userId];        
        
        dispatch_async(dispatch_get_main_queue(), ^{
                        
            if (output.resultCode == ERROR_SUCCESS) {
                long messageCount = [[output.jsonDataDict objectForKey:PARA_MESSAGE_COUNT] longValue];
                long feedCount = [[output.jsonDataDict objectForKey:PARA_FEED_COUNT] longValue];
                long fanCount = [[output.jsonDataDict objectForKey:PARA_FAN_COUNT] longValue];
                long roomCount = [[output.jsonDataDict objectForKey:PARA_ROOM_COUNT] longValue];
                long commentCount = [[output.jsonDataDict objectForKey:PARA_COMMENT_COUNT] longValue];
                long drawToMeCount = [[output.jsonDataDict objectForKey:PARA_DRAWTOME_COUNT] longValue];
                long bbsActionCount = [[output.jsonDataDict objectForKey:PARA_BBS_ACTION_COUNT] longValue];
                
                PPDebug(@"<didGetStatistic>:feedCount = %ld, messageCount = %ld, fanCount = %ld", feedCount,messageCount,fanCount);
                
                //store the counts.
                StatisticManager *manager = [StatisticManager defaultManager];
                [manager setFeedCount:feedCount];
                [manager setMessageCount:messageCount];
                [manager setFanCount:fanCount];
                [manager setRoomCount:roomCount];
                [manager setCommentCount:commentCount];
                [manager setDrawToMeCount:drawToMeCount];
                [manager setBbsActionCount:bbsActionCount];
            }
            if (viewController && [viewController respondsToSelector:@selector(didSyncStatisticWithResultCode:)]) {
                [viewController didSyncStatisticWithResultCode:output.resultCode];
            }
            
            _isCallingGetStatistic = NO;
        });
    });

}


#define USER_ID_SEPRATOR @"$"

- (NSArray *)getUserListSimpleInfo:(NSArray *)userIdList
{
    if ([userIdList count] <= 0) {
        return nil;
    }
    
    NSString *fromUserId = [[UserManager defaultManager] userId];
    
    NSString *userIds = [userIdList objectAtIndex:0];
    for (int index=0; index<[userIdList count]; index++) {
        [[userIds stringByAppendingString:USER_ID_SEPRATOR] stringByAppendingString:[userIdList objectAtIndex:index]];
    }
    
    CommonNetworkOutput* output = [GameNetworkRequest getUserListSimpleInfo:SERVER_URL
                                                                     userId:fromUserId
                                                                      appId:[ConfigManager appId]
                                                                     gameId:[ConfigManager gameId]
                                                                  ByUserIds:userIds];

    
    NSMutableArray *userList = [NSMutableArray array];
    
    if (output.resultCode == ERROR_SUCCESS) {
        
        for(int index=0; index<[output.jsonDataArray count]; index++)
        {
            MyFriend *user = [MyFriend friendWithDict:[output.jsonDataArray objectAtIndex:index]];
            user.friendUserId = [userIdList objectAtIndex:index];
            [userList addObject:user];
        }
    }
    
    return userList;
}

- (MyFriend*)getUserSimpleInfo:(NSString *)userId
{
    NSString *fromUserId = [[UserManager defaultManager] userId];
    CommonNetworkOutput* output = [GameNetworkRequest getUserSimpleInfo:SERVER_URL
                                                                 userId:fromUserId
                                                                  appId:[ConfigManager appId]
                                                                 gameId:[ConfigManager gameId]
                                                               ByUserId:userId];
    MyFriend *user = nil;
    if (output.resultCode == ERROR_SUCCESS) {
        user = [MyFriend friendWithDict:output.jsonDataDict];
        user.friendUserId = userId;
    }
    
    return user;
}


- (void)getUserSimpleInfoByUserId:(NSString *)targetUserId
                         delegate:(id<UserServiceDelegate>)delegate{
    dispatch_async(workingQueue, ^{
        NSString *userId = [[UserManager defaultManager] userId];
        CommonNetworkOutput* output = [GameNetworkRequest getUserSimpleInfo:SERVER_URL
                                                                     userId:userId
                                                                      appId:[ConfigManager appId] 
                                                                     gameId:[ConfigManager gameId]
                                                                   ByUserId:targetUserId];
        MyFriend *user = nil;
        if (output.resultCode == ERROR_SUCCESS) {
            user = [MyFriend friendWithDict:output.jsonDataDict];
            user.friendUserId = targetUserId;
        }
        dispatch_async(dispatch_get_main_queue(), ^{

            if (delegate && [delegate respondsToSelector:@selector(didGetUserInfo:resultCode:)])
            {
                [delegate didGetUserInfo:user resultCode:output.resultCode];
            }
        });
    });

}
- (void)getTopPlayer:(NSInteger)offset limit:(NSInteger)limit delegate:(id<UserServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        NSString *appId = [ConfigManager appId];
        NSString *gameId = [ConfigManager gameId];
        NSString *userId = [[UserManager defaultManager] userId];
        
        CommonNetworkOutput* output = [GameNetworkRequest
                                       getTopPalyerList:SERVER_URL
                                       appId:appId
                                       gameId:gameId 
                                       userId:userId 
                                       offset:offset 
                                       limit:limit];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *topPlayerList = nil;
            if (output.resultCode == ERROR_SUCCESS) {
                topPlayerList = [NSMutableArray array];
                for (NSDictionary *dict in output.jsonDataArray) {
                    if ([dict isKindOfClass:[NSDictionary class]]) {
                        TopPlayer *topPlayer = [[TopPlayer alloc] initWithDict:dict];                        
                        [topPlayerList addObject:topPlayer];
                    }
                }
            }            
            if (delegate && [delegate respondsToSelector:@selector(didGetTopPlayerList:resultCode:)]) {
                [delegate didGetTopPlayerList:topPlayerList 
                                   resultCode:output.resultCode];
            }
        });
    });
}

- (void)superBlackUser:(NSString *)targetUserId
                  type:(BlackUserType)type
          successBlock:(void (^)(void))successBlock
{
    dispatch_async(workingQueue, ^{
        NSString *appId = [ConfigManager appId];
//        NSString *gameId = [ConfigManager gameId];
        NSString *userId = [[UserManager defaultManager] userId];
        
        CommonNetworkOutput* output = [GameNetworkRequest blackUser:SERVER_URL
                                                              appId:appId
                                                       targetUserId:targetUserId
                                                             userId:userId
                                                     targetDeviceId:nil
                                                               type:type
                                                         actionType:BLACK_ACTION_TYPE_BLACK];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                successBlock();
            }
        });
    });
}
- (void)superUnblackUser:(NSString *)targetUserId
                    type:(BlackUserType)type
            successBlock:(void (^)(void))successBlock
{
    dispatch_async(workingQueue, ^{
        NSString *appId = [ConfigManager appId];
        //        NSString *gameId = [ConfigManager gameId];
        NSString *userId = [[UserManager defaultManager] userId];
        
        CommonNetworkOutput* output = [GameNetworkRequest blackUser:SERVER_URL
                                                              appId:appId
                                                       targetUserId:targetUserId
                                                             userId:userId
                                                     targetDeviceId:nil
                                                               type:type
                                                         actionType:BLACK_ACTION_TYPE_UNBLACK];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                successBlock();
            }
        });
    });
}



@end
