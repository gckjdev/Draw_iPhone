//
//  UserManager.h
//  Draw
//
//  Created by  on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define DEFAULT_AVATAR          @"http://file11.joyes.com/other/2010/01/25/ad7440f6997c48de85fed5a0527e05c0.jpg"
#define TEMP_AVATAR_LOCAL_PATH  @"temp"
#define DEFAULT_AVATAR_BUNDLE   @"default_avatar.jpg"

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


@end
