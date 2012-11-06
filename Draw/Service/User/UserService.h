//
//  UserService.h
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"

@class PPViewController;
@class MyFriend;
@protocol UserServiceDelegate <NSObject>

@optional
- (void)didUserRegistered:(int)resultCode;
- (void)didUserUpdated:(int)resultCode;
- (void)didSendFeedback:(int)resultCode;
- (void)didUserLogined:(int)resultCode;

- (void)didGetStatistic:(int)resultCode 
              feedCount:(long)feedCount 
              messageCount:(long)messageCount 
               fanCount:(long)fanCount 
              roomCount:(long)roomCount
           commentCount:(long)commentCount
          drawToMeCount:(long)drawToMeCount;

- (void)didGetUserNickName:(NSString*)nickName
                UserAvatar:(NSString*)avatar
                UserGender:(NSString*)gender
              UserLocation:(NSString*)location 
                 UserLevel:(NSString*)level 
                  SinaNick:(NSString*)sinaNick 
                    QQNick:(NSString*)qqNick 
                      qqId:(NSString*)qqId
                FacebookId:(NSString*)facebookId
                     coins:(NSString*)coins
                  relation:(int)relation;

- (void)didGetUserInfo:(MyFriend *)user resultCode:(NSInteger)resultCode;


- (void)didGetTopPlayerList:(NSArray *)playerList
                 resultCode:(NSInteger)resultCode;

@end

@interface UserService : CommonService

+ (UserService*)defaultService;

- (void)registerUser:(NSString*)email 
            password:(NSString*)password 
      viewController:(PPViewController<UserServiceDelegate>*)viewController;

- (void)registerUserWithSNSUserInfo:(NSDictionary*)userInfo 
                     viewController:(PPViewController<UserServiceDelegate>*)viewController;

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
- (void)updateAllUserInfo;
- (void)updateUserWithSNSUserInfo:(NSString*)userId
                         userInfo:(NSDictionary*)userInfo 
                   viewController:(PPViewController<UserServiceDelegate>*)viewController;

- (void)getStatistic:(PPViewController<UserServiceDelegate>*)viewController;
- (void)getUserSimpleInfoByUserId:(NSString*)targetUserId 
                         delegate:(id<UserServiceDelegate>)delegate;

- (void)getTopPlayer:(NSInteger)offset limit:(NSInteger)limit delegate:(id<UserServiceDelegate>)delegate;

@end
