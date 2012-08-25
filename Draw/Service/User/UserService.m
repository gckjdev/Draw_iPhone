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
#import "AccountService.h"
#import "FriendService.h"
#import "FriendManager.h"
#import "LevelService.h"
#import "UserService.h"
#import "QQWeiboService.h"
#import "ConfigManager.h"

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
    NSString* avatar = [userInfo objectForKey:SNS_USER_IMAGE_URL];
    NSString* location = [userInfo objectForKey:SNS_LOCATION];
    NSString* sinaId = nil;
    NSString* qqId = nil;
    NSString* facebookId = nil;
    NSString* qqNickName = nil;
    NSString* sinaNickName = nil;
    NSString* qqToken = nil;
    NSString* qqTokenSecret = nil;
    
    switch (loginIdType) {
        case REGISTER_TYPE_SINA:
            sinaId = loginId;
            sinaNickName = nickName;
            break;
        
        case REGISTER_TYPE_QQ:
            qqId = loginId;
            qqNickName = nickName;
            qqToken = [userInfo objectForKey:SNS_OAUTH_TOKEN];
            qqTokenSecret = [userInfo objectForKey:SNS_OAUTH_TOKEN_SECRET];
            break;
            
        case REGISTER_TYPE_FACEBOOK:
            facebookId = loginId;
            break;
            
        default:
            break;
    }
    
    PPDebug(@"<updateUserWithSNSUserInfo> userId=%@, userInfo=%@", userId, [userInfo description]);
    
    [viewController showActivityWithText:NSLS(@"kUpdatingUser")];    
    dispatch_async(workingQueue, ^{            
        
        CommonNetworkOutput* output = 
        [GameNetworkRequest updateUser:SERVER_URL appId:appId userId:userId deviceId:nil deviceToken:nil nickName:nickName gender:gender password:nil avatar:avatar location:location sinaId:sinaId sinaNickName:sinaNickName sinaToken:nil sinaSecret:nil qqId:qqId qqNickName:qqNickName qqToken:qqToken qqTokenSecret:qqTokenSecret facebookId:facebookId email:nil];                
        
//        [GameNetworkRequest registerUserBySNS:SERVER_URL
//                                        snsId:loginId
//                                 registerType:loginIdType
//                                        appId:appId
//                                  deviceToken:deviceToken
//                                     nickName:[userInfo objectForKey:SNS_NICK_NAME]
//                                       avatar:[userInfo objectForKey:SNS_USER_IMAGE_URL]
//                                  accessToken:[userInfo objectForKey:SNS_OAUTH_TOKEN]
//                            accessTokenSecret:[userInfo objectForKey:SNS_OAUTH_TOKEN_SECRET]
//                                     province:[[userInfo objectForKey:SNS_PROVINCE] intValue]
//                                         city:[[userInfo objectForKey:SNS_CITY] intValue]
//                                     location:[userInfo objectForKey:SNS_LOCATION]
//                                       gender:[userInfo objectForKey:SNS_GENDER]
//                                     birthday:[userInfo objectForKey:SNS_BIRTHDAY]
//                                       domain:[userInfo objectForKey:SNS_DOMAIN]
//                                     deviceId:deviceId];                
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS){
                // save user data locally
                if (loginIdType == REGISTER_TYPE_SINA){
                    [[UserManager defaultManager] saveUserId:userId
                                                      sinaId:loginId
                                                    password:nil 
                                                    nickName:nickName
                                                   avatarURL:avatar
                                             sinaAccessToken:nil
                                       sinaAccessTokenSecret:nil
                                                      gender:gender];
                }
                else if (loginIdType == REGISTER_TYPE_QQ) {  
                    [[UserManager defaultManager] saveUserId:userId
                                                        qqId:loginId
                                                    password:nil 
                                                    nickName:nickName
                                                   avatarURL:avatar
                                               qqAccessToken:qqToken
                                         qqAccessTokenSecret:qqTokenSecret
                                                      gender:gender];                    
                }   
                else if (loginIdType == REGISTER_TYPE_FACEBOOK) {  
                    [[UserManager defaultManager] saveUserId:userId
                                                  facebookId:loginId
                                                    password:nil 
                                                    nickName:nickName
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

                [[QQWeiboService defaultService] saveToken:qqAccessToken secret:qqAccessSecret];
                
                [[FriendService defaultService] findFriendsByType:FOLLOW viewController:nil];
                [[FriendService defaultService] findFriendsByType:FAN viewController:nil];
                [[LevelService defaultService] setLevel:levelSring.intValue];
                [[LevelService defaultService] setExperience:expSring.intValue];
                
                if ([ConfigManager isProVersion]){
                    // update new appId of user
                    [self updateNewAppId:appId];
                }

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

- (void)getStatistic:(PPViewController<UserServiceDelegate>*)viewController
{
    NSString* userId = [[UserManager defaultManager] userId];
    if ([userId length] == 0)
        return;
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest getStatistics:TRAFFIC_SERVER_URL appId:[ConfigManager appId] userId:userId];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            long messageCount = 0;
            long feedCount = 0;
            long fanCount = 0;
            long roomCount = 0;            
            
            if (output.resultCode == ERROR_SUCCESS) {
                NSNumber *count = [output.jsonDataDict objectForKey:PARA_FEED_COUNT];
                feedCount = [count longValue];
                count = [output.jsonDataDict objectForKey:PARA_FAN_COUNT];
                fanCount = [count longValue];
                count = [output.jsonDataDict objectForKey:PARA_MESSAGE_COUNT];
                messageCount = [count longValue];            
                count = [output.jsonDataDict objectForKey:PARA_ROOM_COUNT];
                roomCount = [count longValue];            
            }
            if (viewController && [viewController respondsToSelector:@selector(didGetStatistic:feedCount:messageCount:fanCount:roomCount:)]) {
                [viewController didGetStatistic:output.resultCode feedCount:feedCount messageCount:messageCount fanCount:fanCount roomCount:roomCount];
            }
        });
    });

}

- (void)getUserSimpleInfoByUserId:(NSString *)targetUserId
                         delegate:(id<UserServiceDelegate>)delegate{
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest getUserSimpleInfo:SERVER_URL
                                                                      appId:[ConfigManager appId] 
                                                                     gameId:[ConfigManager gameId]
                                                                   ByUserId:targetUserId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* userNickName = nil;
            NSString* userAvatar = nil;
            NSString* userGender = nil;
            NSString* userLocation = nil;
            NSString* userLevel = nil;
            NSString* sinaNick = nil;
            NSString* qqNick = nil;
            NSString* facebookId = nil;
            NSString* qqId = nil;

            if (output.resultCode == ERROR_SUCCESS) {
                userNickName = [output.jsonDataDict objectForKey:PARA_NICKNAME];
                userAvatar = [output.jsonDataDict objectForKey:PARA_AVATAR];
                userGender = [output.jsonDataDict objectForKey:PARA_GENDER];
                userLocation = [output.jsonDataDict objectForKey:PARA_LOCATION];
                userLevel = [output.jsonDataDict objectForKey:PARA_LEVEL];
                sinaNick = [output.jsonDataDict objectForKey:PARA_SINA_NICKNAME];
                qqNick = [output.jsonDataDict objectForKey:PARA_QQ_NICKNAME];
                facebookId = [output.jsonDataDict objectForKey:PARA_FACEBOOKID];
                qqId = [output.jsonDataDict objectForKey:PARA_QQ_ID];

            }            
            if (delegate && [delegate respondsToSelector:@selector(didGetUserNickName:UserAvatar:UserGender:UserLocation:UserLevel:SinaNick:QQNick:qqId:FacebookId:)]) {
                [delegate didGetUserNickName:userNickName
                                  UserAvatar:userAvatar
                                  UserGender:userGender
                                UserLocation:userLocation
                                   UserLevel:userLevel 
                                    SinaNick:sinaNick 
                                      QQNick:qqNick 
                                        qqId:qqId
                                  FacebookId:facebookId];
            }
        });
    });

}

@end
