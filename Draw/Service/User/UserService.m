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
#import "GameMessage.pb.h"
#import "BlockUtils.h"
#import "GameBasic.pb.h"
#import "SNSUtils.h"
#import "UserGameItemManager.h"
#import "RegisterUserController.h"
#import "CommonDialog.h"
#import "DrawAppDelegate.h"
#import "PPGameNetworkRequest.h"
#import "UserNumberService.h"
#import "GetNewNumberViewController.h"

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
      viewController:(PPViewController<UserServiceDelegate, CommonDialogDelegate>*)viewController
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

                int coinBalance = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE] intValue];
                [[AccountManager defaultManager] updateBalance:coinBalance currency:PBGameCurrencyCoin];
                  
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
                CommonDialog *dialog = [CommonDialog createInputFieldDialogWith:NSLS(@"kUserLogin") delegate:viewController];
                [dialog.inputTextField setPlaceholder:NSLS(@"kEnterPassword")];
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
                [[UserManager defaultManager] storeUserData];
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
                [[UserManager defaultManager] storeUserData];
                
                int coinBalance = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE] intValue];
                [[AccountManager defaultManager] updateBalance:coinBalance currency:PBGameCurrencyCoin];
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
    //TODO:completeUserInfoController call this
    // save data locally firstly
    [[UserManager defaultManager] setNickName:nickName];
    [[UserManager defaultManager] setGender:gender];
    [[UserManager defaultManager] setPassword:pwd];
    [[UserManager defaultManager] saveAvatarLocally:avatarImage];
    [[UserManager defaultManager] setEmail:email];
    [[UserManager defaultManager] storeUserData];
    
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
                [[UserManager defaultManager] storeUserData];
                
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

- (void)saveSNSUserData:(PBGameUser*)pbUser
{    
    PBSNSUser* sinaUser = [SNSUtils snsUserWithType:TYPE_SINA inpbSnsUserArray:pbUser.snsUsersList];
    PBSNSUser* qqUser = [SNSUtils snsUserWithType:TYPE_QQ inpbSnsUserArray:pbUser.snsUsersList];
    PBSNSUser* fbUser = [SNSUtils snsUserWithType:TYPE_FACEBOOK inpbSnsUserArray:pbUser.snsUsersList];
    
    NSString* sinaAccessToken = sinaUser.accessToken;
    NSString* sinaId = sinaUser.userId;
    NSString* sinaRefreshToken = sinaUser.refreshToken;
    int       sinaExpireTime = sinaUser.expireTime;
    NSDate*   sinaExpireDate = nil;
    if (sinaExpireTime)
        sinaExpireDate = [NSDate dateWithTimeIntervalSince1970:sinaExpireTime];
    
    NSString* qqAccessToken = qqUser.accessToken;
    NSString* qqRefreshToken = qqUser.refreshToken;
    int       qqExpireTime = qqUser.expireTime;
    NSDate*   qqExpireDate = nil;
    if (qqExpireTime)
        qqExpireDate = [NSDate dateWithTimeIntervalSince1970:qqExpireTime];
    NSString* qqOpenId = qqUser.qqOpenId;
    NSString* qqId = qqUser.userId;
    
    NSString* facebookId = fbUser.userId;
    NSString* facebookToken = fbUser.accessToken;
    int       facebookExpireTime = fbUser.expireTime;
    NSDate*   facebookExpireDate = nil;
    if (facebookExpireTime)
        facebookExpireDate = [NSDate dateWithTimeIntervalSince1970:facebookExpireTime];

    
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
    
}

- (int)createLocalUserAccount:(NSData*)data appId:(NSString*)appId
{
    int resultCode = 0;
    if (data == nil){
        return ERROR_CLIENT_PARSE_DATA;
    }
    
    @try {
        DataQueryResponse* response = [DataQueryResponse parseFromData:data];
        PBGameUser* user = response.user;
        
        if (user != nil){
            [[UserManager defaultManager] storeUserData:user];
        }
        
        [[LevelService defaultService] setLevel:user.level];
        [[LevelService defaultService] setExperience:user.experience];
        
        if ([ConfigManager isProVersion]){
            // update new appId of user
            [self updateNewAppId:appId];
        }
        
        [self saveSNSUserData:user];
        
        // sync balance from server
        AccountManager* _accountManager = [AccountManager defaultManager];
        [_accountManager updateBalance:user.coinBalance currency:PBGameCurrencyCoin];
        [_accountManager updateBalance:user.ingotBalance currency:PBGameCurrencyIngot];
        
        // sync user item from server
        [[UserGameItemManager defaultManager] setUserItemList:user.itemsList];
    }
    @catch (NSException *exception) {
        resultCode = ERROR_CLIENT_PARSE_DATA;
    }
    @finally {
        
    }
    
    return resultCode;

}

- (void)loginUserByEmail:(NSString*)email
                password:(NSString*)password
          viewController:(PPViewController<UserServiceDelegate, CommonDialogDelegate>*)viewController
{
    NSString* appId = [ConfigManager appId];
    NSString* gameId = [ConfigManager gameId];
    NSString* deviceToken = [[UserManager defaultManager] deviceToken];
    
    [viewController showActivityWithText:NSLS(@"kLoginUser")];
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output =
        [GameNetworkRequest newLoginUser:SERVER_URL
                                appId:appId
                               gameId:gameId
                                email:email
                             password:password
                          deviceToken:deviceToken];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS){
                
                output.resultCode = [self createLocalUserAccount:output.responseData appId:appId];
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
                CommonDialog *dialog = [CommonDialog createInputFieldDialogWith:NSLS(@"kUserLogin") delegate:viewController];
                [dialog.inputTextField setPlaceholder:NSLS(@"kEnterPassword")];
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
                           autoRegister:(BOOL)autoRegister
                            resultBlock:(AutoResgistrationResultBlock)resultBlock
{
    NSString* appId = [ConfigManager appId];
    NSString* gameId = [ConfigManager gameId];
    NSString* deviceToken = [[UserManager defaultManager] deviceToken];
    NSString* deviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    
    [homeController showActivityWithText:NSLS(@"kConnectingServer")];
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output =
        [GameNetworkRequest newLoginUser:SERVER_URL
                                   appId:appId
                                  gameId:gameId
                                deviceId:deviceId
                             deviceToken:deviceToken
                            autoRegister:autoRegister];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [homeController hideActivity];
            if (output.resultCode == ERROR_SUCCESS && output.responseData != nil){                
                [self createLocalUserAccount:output.responseData appId:appId];
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
            
            EXECUTE_BLOCK(resultBlock, NO, 0, [[UserManager defaultManager] pbUser]);
        });
    });

}

- (void)loginByDeviceWithViewController:(PPViewController*)homeController
{
    [self loginByDeviceWithViewController:homeController autoRegister:NO resultBlock:nil];
    
//    NSString* appId = [ConfigManager appId];
//    NSString* gameId = [ConfigManager gameId];
//    NSString* deviceToken = [[UserManager defaultManager] deviceToken];
//    NSString* deviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
//
//    [homeController showActivityWithText:NSLS(@"kConnectingServer")];
//    dispatch_async(workingQueue, ^{
//
//        CommonNetworkOutput* output =
//        [GameNetworkRequest newLoginUser:SERVER_URL
//                                appId:appId
//                               gameId:gameId
//                             deviceId:deviceId
//                          deviceToken:deviceToken];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            [homeController hideActivity];
//            if (output.resultCode == ERROR_SUCCESS && output.responseData != nil){
//                
//                [self createLocalUserAccount:output.responseData appId:appId];
//            }
//            else if (output.resultCode == ERROR_NETWORK) {
//                [homeController popupUnhappyMessage:NSLS(@"kSystemFailure") title:nil];
//            }
//            else if (output.resultCode == ERROR_DEVICE_NOT_BIND) {
//                // @"设备未绑定任何用户"
//            }
//            else {
//                // @"登录失败，稍后尝试"
//                [homeController popupUnhappyMessage:NSLS(@"kLoginFailure") title:nil];
//            }
//        });
//    });

}

/*
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
                
                [[AccountService defaultService] syncAccount];

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
*/
 
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
                long timeLineOpusCount = [[output.jsonDataDict objectForKey:PARA_TIME_LINE_OPUS_COUNT] longValue];
                long timeLineGuessCount = [[output.jsonDataDict objectForKey:PARA_TIME_LINE_GUESS_COUNT] longValue];
                
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
                [manager setTimelineOpusCount:timeLineOpusCount];
                [manager setTimelineGuessCount:timeLineGuessCount];
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

- (void)getUserInfo:(NSString*)targetUserId resultBlock:(GetUserInfoResultBlock)block
{
    dispatch_async(workingQueue, ^{
        NSString *userId = [[UserManager defaultManager] userId];
        CommonNetworkOutput* output = [GameNetworkRequest       getUserInfo:SERVER_URL
                                                                     userId:userId
                                                                      appId:[ConfigManager appId]
                                                                     gameId:[ConfigManager gameId]
                                                                   ByUserId:targetUserId];
        dispatch_async(dispatch_get_main_queue(), ^{
            PPDebug(@"<getUserInfo> targetUserId=%@, resultCode=%d", targetUserId, output.resultCode);
            if (output.resultCode == ERROR_SUCCESS) {
                @try {
                    if (output.responseData != nil){
                        DataQueryResponse* response = [DataQueryResponse parseFromData:output.responseData];
                        PBGameUser* user = response.user;
                        EXECUTE_BLOCK(block, 0, user, response.userRelation);
                    }
                    else{
                        EXECUTE_BLOCK(block, ERROR_CLIENT_PARSE_DATA, nil, 0);
                    }
                }
                @catch (NSException *exception) {
                    EXECUTE_BLOCK(block, ERROR_CLIENT_PARSE_DATA, nil, 0);
                }
                @finally {
                }
            }
            else{
                EXECUTE_BLOCK(block, output.resultCode, nil, 0);
            }
        });
    });

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

- (void)getTopPlayerWithType:(int)type
                      offset:(NSInteger)offset
                       limit:(NSInteger)limit
                    delegate:(id<UserServiceDelegate>)delegate
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
                                       type:type
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


- (void)getTopPlayerByScore:(NSInteger)offset limit:(NSInteger)limit delegate:(id<UserServiceDelegate>)delegate
{
    [self getTopPlayerWithType:TOP_PLAYER_BY_SCORE
                        offset:offset
                         limit:limit
                      delegate:delegate];
}

- (void)getTopPlayer:(NSInteger)offset limit:(NSInteger)limit delegate:(id<UserServiceDelegate>)delegate
{
    [self getTopPlayerWithType:TOP_PLAYER_BY_LEVEL
                        offset:offset
                         limit:limit
                      delegate:delegate];
    
//    dispatch_async(workingQueue, ^{
//        NSString *appId = [ConfigManager appId];
//        NSString *gameId = [ConfigManager gameId];
//        NSString *userId = [[UserManager defaultManager] userId];
//        
//        CommonNetworkOutput* output = [GameNetworkRequest
//                                       getTopPalyerList:SERVER_URL
//                                       appId:appId
//                                       gameId:gameId 
//                                       userId:userId 
//                                       offset:offset 
//                                       limit:limit];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSMutableArray *topPlayerList = nil;
//            if (output.resultCode == ERROR_SUCCESS) {
//                topPlayerList = [NSMutableArray array];
//                for (NSDictionary *dict in output.jsonDataArray) {
//                    if ([dict isKindOfClass:[NSDictionary class]]) {
//                        TopPlayer *topPlayer = [[TopPlayer alloc] initWithDict:dict];                        
//                        [topPlayerList addObject:topPlayer];
//                    }
//                }
//            }            
//            if (delegate && [delegate respondsToSelector:@selector(didGetTopPlayerList:resultCode:)]) {
//                [delegate didGetTopPlayerList:topPlayerList 
//                                   resultCode:output.resultCode];
//            }
//        });
//    });
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
                EXECUTE_BLOCK(successBlock);
            }
        });
    });
}

- (void)recoverUserOpus:(NSString*)targetUserId
           successBlock:(void (^)(void))successBlock
{
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponseJSON:METHOD_RECOVERY_OPUS parameters:@{PARA_TARGETUSERID:targetUserId} isReturnArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                EXECUTE_BLOCK(successBlock);
            }
        });
    });
}

- (void)uploadUserAvatar:(UIImage*)image
             resultBlock:(UploadImageResultBlock)resultBlock
{
    // save data locally firstly
    [[UserManager defaultManager] saveAvatarLocally:image];
    [[UserManager defaultManager] storeUserData];
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSData* data = [image data];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest uploadUserImage:SERVER_URL
                                                                    appId:[ConfigManager appId]
                                                                   userId:userId
                                                                imageData:data
                                                                imageType:PARA_AVATAR];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
                // update avatar
                NSString* retURL = [[output jsonDataDict] objectForKey:PARA_URL];
                [[UserManager defaultManager] setAvatar:retURL];
                [[UserManager defaultManager] storeUserData];
                EXECUTE_BLOCK(resultBlock, output.resultCode, retURL);
            }
            else{
                EXECUTE_BLOCK(resultBlock, output.resultCode, nil);
            }
            
        });
    });
    
}

- (void)uploadUserBackground:(UIImage*)image
                 resultBlock:(UploadImageResultBlock)resultBlock
{
    // save data locally firstly
    NSString* userId = [[UserManager defaultManager] userId];
    NSData* data = [image data];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest uploadUserImage:SERVER_URL
                                                                    appId:[ConfigManager appId]
                                                                   userId:userId
                                                                imageData:data
                                                                imageType:PARA_BACKGROUND];
        
        dispatch_async(dispatch_get_main_queue(), ^{            
            if (output.resultCode == ERROR_SUCCESS){
                // update background
                NSString* retURL = [[output jsonDataDict] objectForKey:PARA_URL];
                [[UserManager defaultManager] setBackground:retURL];
                [[UserManager defaultManager] storeUserData];
                EXECUTE_BLOCK(resultBlock, output.resultCode, retURL);
            }
            else{
                EXECUTE_BLOCK(resultBlock, output.resultCode, nil);
            }
        });
    });
}

- (void)updateUser:(PBGameUser*)pbUser
       resultBlock:(UpdateUserResultBlock)resultBlock
{
    NSString* appId = [ConfigManager appId];
    NSString* userId = [[UserManager defaultManager] userId];
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:pbUser];
    
    // set extra info like device model, etc
    NSString* deviceToken = [[UserManager defaultManager] deviceToken];
    NSString* deviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    [builder setDeviceId:deviceId];
    [builder setDeviceToken:deviceToken];
    
    [builder setCountryCode:[LocaleUtils getCountryCode]];
    [builder setLanguage:[LocaleUtils getLanguageCode]];
    [builder setDeviceModel:[UIDevice currentDevice].model];
    [builder setDeviceType:STRING_DEVICE_TYPE_IOS];
    [builder setDeviceOs:[DeviceDetection deviceOS]];
    [builder setIsJailBroken:[MobClick isJailbroken]];
    
    PBGameUser* newUser = [builder build];
    NSData* data = [newUser data];

    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest updateUser:SERVER_URL
                                                              appId:appId
                                                             userId:userId
                                                                data:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            PPDebug(@"<updateUser> result=%d", output.resultCode);
            if (output.resultCode == ERROR_SUCCESS){
                // update user info
                [[UserManager defaultManager] storeUserData:newUser];
            }
            EXECUTE_BLOCK(resultBlock, output.resultCode);
        });
    });
}

// return NO if don't need show login view
// return YES if need
- (BOOL)checkAndAskXiaojiNumber:(UIView*)view
{
    if ([[UserManager defaultManager] hasXiaojiNumber] == YES)
        return NO;
    
    // display xiaoji number controller
    if (self.getNewNumberController == nil){
        GetNewNumberViewController *vc = [[GetNewNumberViewController alloc] init];
        self.getNewNumberController = vc;
        [vc release];
    }
    [self.getNewNumberController.view removeFromSuperview];
    [view addSubview:self.getNewNumberController.view];
    return YES;
}

- (BOOL)checkAndAskLogin:(UIView*)view
{
    if ([[UserManager defaultManager] hasUser] == NO){
        
        if ([GameApp isAutoRegister] == YES){
            [self autoRegisteration:nil];
            return NO;
        }
        
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kAskLoginTitle") message:NSLS(@"kAskLoginMessage") style:CommonDialogStyleDoubleButton];
        
        [dialog setClickOkBlock:^(UILabel *label){
            // goto RegisterUserController
            RegisterUserController *ruc = [[RegisterUserController alloc] init];
            UIViewController* rootController = ((DrawAppDelegate*)([UIApplication sharedApplication].delegate)).window.rootViewController;
            if ([rootController respondsToSelector:@selector(pushViewController:animated:)]){
            // this warning is OK
            // leave this warning to check when home controller is changed
                [rootController pushViewController:ruc animated:YES];
            }
            else{
                [rootController.navigationController pushViewController:ruc animated:YES];
            }
            [ruc release];

        }];

        
        [dialog showInView:view];
        return YES;
    }
    else{
        return NO;
    }
}


- (BOOL)autoRegisteration:(AutoResgistrationResultBlock)resultBlock
{
    // already has user
    if ([[UserManager defaultManager] hasUser]){
        EXECUTE_BLOCK(resultBlock, YES, 0, [[UserManager defaultManager] pbUser]);
        return YES;
    }
    
    [self loginByDeviceWithViewController:nil autoRegister:YES resultBlock:resultBlock];
    return NO;
}

- (void)setUserFeatureOpus:(NSString*)targetUserId
               featureOpus:(int)featureOpus
              successBlock:(void (^)(void))successBlock
{
    
    NSDictionary* para = @{ PARA_TARGETUSERID : targetUserId,
                            PARA_FEATURE_OPUS : @(featureOpus)};
    
    dispatch_async(workingQueue, ^{
        GameNetworkOutput* output = [PPGameNetworkRequest apiServerGetAndResponseJSON:METHOD_MANAGE_USER_INFO parameters:para isReturnArray:NO];
        dispatch_async(dispatch_get_main_queue(), ^{        
            if (output.resultCode == 0){
                if (successBlock){
                    successBlock();
                }
            }
        });
    });
    
    
}

#define VERIFY_TYPE_EMAIL       1

- (void)sendPassword:(NSString*)email
         resultBlock:(void(^)(int resultCode))resultBlock
{

    if ([email length] == 0){
        EXECUTE_BLOCK(resultBlock, ERROR_EMAIL_NOT_VALID);
        return;
    }
    
    NSDictionary* para = @{ PARA_TYPE : @(VERIFY_TYPE_EMAIL),
                            PARA_EMAIL : email};
    
    dispatch_async(workingQueue, ^{
        GameNetworkOutput* output = [PPGameNetworkRequest apiServerGetAndResponseJSON:METHOD_SEND_PASSWORD
                                                                           parameters:para
                                                                        isReturnArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, output.resultCode);
        });
    });
    
    
}

- (void)sendVerificationRequest:(void(^)(int resultCode))resultBlock
{
    NSString* email = [[UserManager defaultManager] email];
    if ([email length] == 0){
        EXECUTE_BLOCK(resultBlock, ERROR_EMAIL_NOT_VALID);
        return;
    }
    
    NSDictionary* para = @{ PARA_TYPE : @(VERIFY_TYPE_EMAIL),
                            PARA_EMAIL : email};
    
    dispatch_async(workingQueue, ^{
        GameNetworkOutput* output = [PPGameNetworkRequest apiServerGetAndResponseJSON:METHOD_SEND_VERFICATION
                                                                           parameters:para
                                                                        isReturnArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, output.resultCode);
        });
    });
}

- (void)verifyAccount:(NSString*)code
          resultBlock:(void(^)(int resultCode))resultBlock
{
    NSString* email = [[UserManager defaultManager] email];
    if ([email length] == 0){
        EXECUTE_BLOCK(resultBlock, ERROR_EMAIL_NOT_VALID);
        return;
    }

    if ([code length] == 0){
        EXECUTE_BLOCK(resultBlock, ERROR_PARAMETER_VERIFYCODE_EMPTY);
        return;
    }
    
    NSDictionary* para = @{ PARA_TYPE : @(VERIFY_TYPE_EMAIL),
                            PARA_EMAIL : email,
                            PARA_VERIFYCODE : code};
    
    dispatch_async(workingQueue, ^{
        GameNetworkOutput* output = [PPGameNetworkRequest apiServerGetAndResponseJSON:METHOD_VERIFY_ACCOUNT
                                                                           parameters:para
                                                                        isReturnArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(resultBlock, output.resultCode);
        });
    });
}

@end


