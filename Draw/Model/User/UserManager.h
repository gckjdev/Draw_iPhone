//
//  UserManager.h
//  Draw
//
//  Created by  on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LocaleUtils.h"

#define DEFAULT_AVATAR          @"http://tp4.sinaimg.cn/2198792115/180/0/1"
#define TEMP_AVATAR_LOCAL_PATH  @"avatar"

@class PBGameUser;

typedef enum {
    UnknowType = 0,
    ChineseType = 1,
    EnglishType = 2
}LanguageType;

#define MALE @"m"
#define FEMALE @"f"

#define PASSWORD_KEY        @"PASSWORD_KEY_DRAW_DSAQC"

@protocol AvatarImageDelegate <NSObject>

- (void)didAvatarImageLoad:(UIImage*)image;

@end

@interface UserManager : NSObject{
//    NSUserDefaults* _userDefaults;    
}

+ (UserManager*)defaultManager;

@property (nonatomic, retain) UIImage *avatarImage;
@property (nonatomic, retain) PBGameUser *pbUser;

- (NSString*)userId;
- (NSString*)nickName;
- (NSString*)avatarURL;
- (NSString*)deviceToken;
- (NSString*)password;
- (NSString*)deviceToken;
- (NSString*)gender;
- (NSString*)location;
- (NSArray*)snsUserData;
//- (NSString*)sinaId;
//- (NSString*)sinaNickName;
//- (NSString*)sinaToken;
//- (NSString*)sinaTokenSecret;
//- (NSString*)qqId;
//- (NSString*)qqNickName;
//- (NSString*)qqToken;
//- (NSString*)qqTokenSecret;
//- (NSString*)facebookId;
- (NSString*)email;
- (NSString*)facetimeId;
- (NSString*)birthday;
- (NSInteger)zodiac;
- (NSInteger)followCount;
- (NSInteger)fanCount;
- (NSString*)signature;

- (BOOL)isMe:(NSString *)userId;
- (BOOL)isPasswordEmpty;
- (BOOL)isPasswordCorrect:(NSString *)userInput;
- (void)saveAvatarLocally:(UIImage*)image;
- (void)setNickName:(NSString*)nickName;
- (void)setAvatar:(NSString*)avatarURL;
- (void)setGender:(NSString*)gender;
- (void)setPassword:(NSString*)password;
- (void)setDeviceToken:(NSString*)deviceToken;
- (void)setLocation:(NSString*)location;
- (void)setEmail:(NSString *)email;
- (void)setFacetimeId:(NSString*)facetimeId;
- (void)setBirthday:(NSString*)birthdayString;
- (void)setZodiac:(NSInteger)zodiac;
- (void)setFollowCount:(NSInteger)followCount;
- (void)setFanCount:(NSInteger)fanCount;
- (void)setSignature:(NSString*)signature;


- (BOOL)hasUser;
- (BOOL)isUserMale;
- (NSString*)defaultAvatar;

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
sinaAccessTokenSecret:(NSString*)accessTokenSecret 
            gender:(NSString*)gender;

- (void)saveUserId:(NSString*)userId
            qqId:(NSString*)loginId
          password:(NSString*)password 
          nickName:(NSString*)nickName
         avatarURL:(NSString*)avatarURL
   qqAccessToken:(NSString*)accessToken
qqAccessTokenSecret:(NSString*)accessTokenSecret 
            gender:(NSString*)gender;

- (void)saveUserId:(NSString*)userId
        facebookId:(NSString*)loginId
          password:(NSString*)password 
          nickName:(NSString*)nickName
         avatarURL:(NSString*)avatarURL 
            gender:(NSString*)gender;

- (void)storeUserData;
- (void)storeUserData:(PBGameUser*)user;

//- (void)saveUserId:(NSString*)userId 
//             email:(NSString*)email
//          password:(NSString*)password
//          nickName:(NSString*)nickName 
//              qqId:(NSString*)qqId 
//     qqAccessToken:(NSString*)accessToken 
//qqAccessTokenSecret:(NSString*)accessTokenSecret 
//            sinaId:(NSString*)loginId 
//   sinaAccessToken:(NSString*)accessToken 
//sinaAccessTokenSecret:(NSString*)accessTokenSecret 
//        facebookId:(NSString*)loginId
//         avatarURL:(NSString*)avatarURL 
//           balance:(NSNumber*)balance 
//             items:(NSArray*)items 
//            gender:(NSString*)gender;

- (void)setLanguageType:(LanguageType)type;
- (LanguageType)getLanguageType;


- (BOOL)hasBindSinaWeibo;
- (BOOL)hasBindQQWeibo;
- (BOOL)hasBindFacebook;

- (NSInteger)roomCount;
- (void)increaseRoomCount;

- (void)guessCorrectOpus:(NSString *)opusId;
- (BOOL)hasGuessOpus:(NSString *)opusId;

- (void)setQQId:(NSString*)qqId nickName:(NSString*)nickName accessToken:(NSString*)accessToken accessTokenSecret:(NSString*)accessTokenSecret;
- (void)setSinaId:(NSString*)sinaId nickName:(NSString*)nickName;
- (void)setFacebookId:(NSString*)facebookId nickName:(NSString*)nickName;

- (PBGameUser*)toPBGameUser;
- (PBGameUser*)toPBGameUserWithKeyValues:(NSArray*)keyValueArray;

- (BOOL)hasFollowWeibo;
- (void)followWeibo;

- (NSString*)defaultUserRoomName;
- (BOOL)isSuperUser;

- (void)storeUserData:(PBGameUser*)user;
@end
