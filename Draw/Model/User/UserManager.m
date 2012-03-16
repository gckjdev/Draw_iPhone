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

- (BOOL)hasUser
{
    return ([[self userId] length] > 0);
}

- (void)saveUserId:(NSString*)userId 
          nickName:(NSString*)nickName
{
    PPDebug(@"Save userId(%@), nickName(%@)", userId, nickName);    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userId forKey:KEY_USERID];
    [userDefaults setObject:nickName forKey:KEY_NICKNAME];
    
}


@end
