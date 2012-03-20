//
//  UserManager.m
//  Draw
//
//  Created by  on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserManager.h"
#import "PPDebug.h"

#define KEY_USERID          @"KEY_USERID"
#define KEY_NICKNAME        @"KEY_NICKNAME"
#define KEY_AVATAR_URL      @"KEY_AVATAR_URL"

@implementation UserManager

static UserManager* _defaultManager;

+ (UserManager*)defaultManager
{
    if (_defaultManager == nil)
        _defaultManager = [[UserManager alloc] init];
    
    return _defaultManager;
}

- (NSString*)userId
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:KEY_USERID];
}

- (NSString*)nickName
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:KEY_NICKNAME];
}

- (NSString*)avatarURL
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* value = [userDefaults objectForKey:KEY_AVATAR_URL];
    return value;
}

- (BOOL)hasUser
{
    return ([[self userId] length] > 0);
}

- (void)saveUserId:(NSString*)userId 
          nickName:(NSString*)nickName
         avatarURL:(NSString*)avatarURL
{
    PPDebug(@"Save userId(%@), nickName(%@)", userId, nickName);    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userId forKey:KEY_USERID];
    [userDefaults setObject:nickName forKey:KEY_NICKNAME];
    [userDefaults setObject:avatarURL forKey:KEY_AVATAR_URL];
    [userDefaults synchronize];
}


@end
