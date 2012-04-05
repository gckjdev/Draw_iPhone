//
//  UserManager.h
//  Draw
//
//  Created by  on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LocaleUtils.h"

#define DEFAULT_AVATAR          @"http://tp4.sinaimg.cn/2198792115/180/0/1"
#define TEMP_AVATAR_LOCAL_PATH  @"temp"
#define DEFAULT_AVATAR_BUNDLE   ([LocaleUtils isChina] ? @"man1.png" : @"man2.png")

typedef enum {
    ChineseType = 1,
    EnglishType = 2
}LanguageType;


@protocol AvatarImageDelegate <NSObject>

- (void)didAvatarImageLoad:(UIImage*)image;

@end

@interface UserManager : NSObject

+ (UserManager*)defaultManager;

@property (nonatomic, retain) UIImage *avatarImage;

- (NSString*)userId;
- (NSString*)nickName;
- (NSString*)avatarURL;
- (NSString*)deviceToken;
- (NSString*)password;

- (void)saveAvatarLocally:(UIImage*)image;
- (void)setNickName:(NSString*)nickName;
- (void)setAvatar:(NSString*)avatarURL;
- (void)setGender:(NSString*)gender;

- (BOOL)hasUser;

- (void)saveUserId:(NSString*)userId 
             email:(NSString*)email
          password:(NSString*)password
          nickName:(NSString*)nickName
         avatarURL:(NSString*)avatarURL;

+ (NSString*)nickNameByEmail:(NSString*)email;

- (void)saveUserId:(NSString*)userId
              sinaId:(NSString*)loginId
            password:(NSString*)password 
            nickName:(NSString*)nickName
           avatarURL:(NSString*)avatarURL
     sinaAccessToken:(NSString*)accessToken
    sinaAccessTokenSecret:(NSString*)accessTokenSecret;

- (void)saveUserId:(NSString*)userId
            qqId:(NSString*)loginId
          password:(NSString*)password 
          nickName:(NSString*)nickName
         avatarURL:(NSString*)avatarURL
   qqAccessToken:(NSString*)accessToken
qqAccessTokenSecret:(NSString*)accessTokenSecret;

- (void)setLanguageType:(LanguageType)type;
- (LanguageType)getLanguageType;


@end
