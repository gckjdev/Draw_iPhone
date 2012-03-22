//
//  UserManager.h
//  Draw
//
//  Created by  on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//



@interface UserManager : NSObject

+ (UserManager*)defaultManager;

- (NSString*)userId;
- (NSString*)nickName;
- (NSString*)avatarURL;
- (NSString*)deviceToken;

- (void)saveUserId:(NSString*)userId 
          nickName:(NSString*)nickName
         avatarURL:(NSString*)avatarURL;

- (BOOL)hasUser;

@end
