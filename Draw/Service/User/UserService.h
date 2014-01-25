//
//  UserService.h
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"
#import <ShareSDK/ShareSDK.h>

typedef enum {
    BLACK_USER_TYPE_USERID = 0,
    BLACK_USER_TYPE_DEVICEID,
}BlackUserType;

typedef enum{
    TOP_PLAYER_BY_LEVEL = 1,
    TOP_PLAYER_BY_SCORE = 2,
}TopUserType;

typedef enum {
    BLACK_ACTION_TYPE_BLACK = 0,
    BLACK_ACTION_TYPE_UNBLACK,
}BlackActionType;

@class PPViewController;
@class MyFriend;
@class PBGameUser;
@class GetNewNumberViewController;
@class ShakeNumberController;

typedef void(^AutoResgistrationResultBlock)(BOOL isAlreadyRegistered, int resultCode, PBGameUser* user);
typedef void(^GetUserInfoResultBlock)(int resultCode, PBGameUser* user, int relation);
typedef void(^GetUserListResultBlock)(int resultCode, NSArray *userList);

typedef void(^UpdateUserResultBlock)(int resultCode);
typedef void(^UploadImageResultBlock)(int resultCode, NSString* imageRemoteURL);

@protocol UserServiceDelegate <NSObject>

@optional
- (void)didUserRegistered:(int)resultCode;
- (void)didUserUpdated:(int)resultCode;
- (void)didSendFeedback:(int)resultCode;
- (void)didUserLogined:(int)resultCode;


- (void)didSyncStatisticWithResultCode:(int)resultCode;



- (void)didGetUserInfo:(MyFriend *)user resultCode:(NSInteger)resultCode;


- (void)didGetTopPlayerList:(NSArray *)playerList
                 resultCode:(NSInteger)resultCode;

@end

@interface UserService : CommonService
{
    BOOL    _isCallingGetStatistic;
}

@property (nonatomic, retain) GetNewNumberViewController* getNewNumberController;
@property (nonatomic, retain) ShakeNumberController* shakeNumberController;

+ (UserService*)defaultService;

- (void)registerUser:(NSString*)email 
            password:(NSString*)password 
      viewController:(PPViewController<UserServiceDelegate>*)viewController;

- (void)registerUserWithSNSUserInfo:(NSDictionary*)userInfo 
                     viewController:(PPViewController<UserServiceDelegate>*)viewController;

- (void)uploadUserAvatar:(UIImage*)image
             resultBlock:(UploadImageResultBlock)resultBlock;

- (void)uploadUserBackground:(UIImage*)image
                 resultBlock:(UploadImageResultBlock)resultBlock;

- (void)updateUser:(PBGameUser*)pbUser
       resultBlock:(UpdateUserResultBlock)resultBlock;

- (void)updateUserAvatar:(UIImage*)avatarImage
                nickName:(NSString*)nickName 
                  gender:(NSString*)gender
          viewController:(PPViewController<UserServiceDelegate>*)viewController;

- (void)updateUserAvatar:(UIImage*)avatarImage 
                nickName:(NSString*)nickName 
                  gender:(NSString*)gender
                password:(NSString*)password
                   email:(NSString*)email
          viewController:(PPViewController<UserServiceDelegate>*)viewController;

- (void)feedback:(NSString*)feedback 
             WithContact:(NSString*)contact  
  viewController:(PPViewController<UserServiceDelegate>*)viewController;

- (void)reportBugs:(NSString*)bugDescription 
       withContact:(NSString*)contact  
    viewController:(PPViewController<UserServiceDelegate>*)viewController;

- (void)loginUserByEmail:(NSString*)email 
                password:(NSString*)password 
          viewController:(PPViewController<UserServiceDelegate>*)viewController;

- (void)loginByDeviceWithViewController:(PPViewController*)viewController;
- (void)commitWords:(NSString*)words 
     viewController:(PPViewController<UserServiceDelegate>*)viewController;
//- (void)checkDevice;
//- (void)updateAllUserInfo;
- (void)updateUserWithSNSUserInfo:(NSString*)userId
                         userInfo:(NSDictionary*)userInfo 
                   viewController:(PPViewController<UserServiceDelegate>*)viewController;

- (void)updateUserWithSNSUserInfo:(NSString*)userId
                        shareType:(ShareType)shareType
                         userInfo:(id<ISSUserInfo>)userInfo
                       accessInfo:(id<ISSOAuth2Credential>)accessInfo
                   viewController:(PPViewController<UserServiceDelegate>*)viewController;

- (void)updateUserWithSNSUserInfo:(ShareType)shareType
                 credentialString:(NSString*)credentialString;

- (void)loginSNSUser:(id<ISSUserInfo>)userInfo
           shareType:(ShareType)shareType
          accessInfo:(id<ISSOAuth2Credential>)accessInfo
         resultBlock:(void(^)(int))resultBlock;


- (void)getStatistic:(PPViewController<UserServiceDelegate>*)viewController;

// this methods is kept for old implementation, new implementation will use getUserInfo
- (void)getUserSimpleInfoByUserId:(NSString*)targetUserId
                         delegate:(id<UserServiceDelegate>)delegate;
// a network block method to query user basic info
- (MyFriend*)getUserSimpleInfo:(NSString *)userId;
- (NSArray *)getUserListSimpleInfo:(NSArray *)userIdList;

// new method, use protocol buffer object for return
- (void)getUserInfo:(NSString*)userId resultBlock:(GetUserInfoResultBlock)block;

- (void)getTopPlayerWithType:(int)type
                      offset:(NSInteger)offset
                       limit:(NSInteger)limit
                 resultBlock:(GetUserListResultBlock)block;


- (void)getTopPlayer:(NSInteger)offset limit:(NSInteger)limit delegate:(id<UserServiceDelegate>)delegate;

- (void)getTopPlayerByScore:(NSInteger)offset limit:(NSInteger)limit delegate:(id<UserServiceDelegate>)delegate;

- (void)superBlackUser:(NSString*)targetUserId
                  type:(BlackUserType)type
          successBlock:(void (^)(void))successBlock;
- (void)superUnblackUser:(NSString*)targetUserId
                    type:(BlackUserType)type
            successBlock:(void (^)(void))successBlock;


- (BOOL)checkAndAskLogin:(UIView*)view;
- (void)dismissGetNumberView;
- (void)dismissShakeNumberView;
- (void)showXiaojiNumberView:(UIView*)view;

- (BOOL)autoRegisteration:(AutoResgistrationResultBlock)resultBlock;

- (void)loginByDeviceWithViewController:(PPViewController*)homeController
                           autoRegister:(BOOL)autoRegister
                            resultBlock:(AutoResgistrationResultBlock)resultBlock;
- (void)recoverUserOpus:(NSString*)targetUserId
           successBlock:(void (^)(void))successBlock;

- (void)exportUserOpusImage:(NSString*)targetUserId
               successBlock:(void (^)(void))successBlock;

- (void)setUserFeatureOpus:(NSString*)targetUserId
               featureOpus:(int)featureOpus
              successBlock:(void (^)(void))successBlock;

- (void)setUserPassword:(NSString*)targetUserId
                pasword:(NSString*)password
            resultBlock:(void(^)(int resultCode))resultBlock;

- (void)sendPassword:(NSString*)email
         resultBlock:(void(^)(int resultCode))resultBlock;

- (void)sendVerificationRequest:(NSString*)email resultBlock:(void(^)(int resultCode))resultBlock;

- (void)verifyAccount:(NSString*)code
          resultBlock:(void(^)(int resultCode))resultBlock;


- (void)logout:(PPViewController*)viewController;
- (void)forceLogout;
- (void)executeLogout:(BOOL)keepDraft viewController:(PPViewController*)viewController;

- (BOOL)isRegistered;
- (BOOL)gotoRegistration:(UIView*)view;

- (void)createLocalUserAccount:(PBGameUser*)user;

- (void)purchaseVipService:(int)type
            viewController:(PPViewController*)viewController
               resultBlock:(void(^)(int resultCode))resultBlock;

@end
