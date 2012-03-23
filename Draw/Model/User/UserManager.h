//
//  UserManager.h
//  Draw
//
//  Created by  on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define DEFAULT_AVATAR      @"http://file11.joyes.com/other/2010/01/25/ad7440f6997c48de85fed5a0527e05c0.jpg"

@interface UserManager : NSObject

+ (UserManager*)defaultManager;

- (NSString*)userId;
- (NSString*)nickName;
- (NSString*)avatarURL;
- (NSString*)deviceToken;

- (BOOL)hasUser;

- (void)saveUserId:(NSString*)userId 
             email:(NSString*)email
          password:(NSString*)password
          nickName:(NSString*)nickName
         avatarURL:(NSString*)avatarURL;

+ (NSString*)nickNameByEmail:(NSString*)email;

@end
