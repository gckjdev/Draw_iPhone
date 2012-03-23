//
//  UserManager.m
//  Draw
//
//  Created by  on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserManager.h"
#import "PPDebug.h"

#define KEY_USERID          @"USER_KEY_USERID"
#define KEY_NICKNAME        @"USER_KEY_NICKNAME"
#define KEY_AVATAR_URL      @"USER_KEY_AVATAR_URL"
#define KEY_DEVICE_TOKEN    @"USER_KEY_DEVICE_TOKEN"
#define KEY_EMAIL           @"USER_KEY_EMAIL"
#define KEY_PASSWORD        @"USER_KEY_PASSWORD"



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

- (NSString*)deviceToken
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* value = [userDefaults objectForKey:KEY_DEVICE_TOKEN];
    return value;    
}

- (BOOL)hasUser
{
    return ([[self userId] length] > 0);
}

- (void)saveUserId:(NSString*)userId 
             email:(NSString*)email
          password:(NSString*)password
          nickName:(NSString*)nickName
         avatarURL:(NSString*)avatarURL
{
    PPDebug(@"Save userId(%@), email(%@), nickName(%@)", userId, email, nickName);    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userId forKey:KEY_USERID];
    [userDefaults setObject:nickName forKey:KEY_NICKNAME];
    [userDefaults setObject:email forKey:KEY_EMAIL];
    [userDefaults setObject:password forKey:KEY_PASSWORD];
    
    if (avatarURL != nil){
        [userDefaults setObject:avatarURL forKey:KEY_AVATAR_URL];
    }
    
    [userDefaults synchronize];
}

+ (NSString*)nickNameByEmail:(NSString*)email
{
    NSRange range = [email rangeOfString:@"@"];
    if (range.location == NSNotFound){
        return @"";
    }
    else{
        int index = range.location;
        return [email substringToIndex:index];
    }
}


@end
