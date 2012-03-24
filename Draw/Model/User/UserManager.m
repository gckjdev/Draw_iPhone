//
//  UserManager.m
//  Draw
//
//  Created by  on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserManager.h"
#import "PPDebug.h"
#import "UIImageUtil.h"
#import "ASIHTTPRequest.h"
#import "FileUtil.h"

#define KEY_USERID          @"USER_KEY_USERID"
#define KEY_NICKNAME        @"USER_KEY_NICKNAME"
#define KEY_AVATAR_URL      @"USER_KEY_AVATAR_URL"
#define KEY_DEVICE_TOKEN    @"USER_KEY_DEVICE_TOKEN"
#define KEY_EMAIL           @"USER_KEY_EMAIL"
#define KEY_PASSWORD        @"USER_KEY_PASSWORD"

#define AVATAR_LOCAL_FILENAME   @"user_avatar.png"

@implementation UserManager

@synthesize avatarImage = _avatarImage;
static UserManager* _defaultManager;

+ (UserManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[UserManager alloc] init];
    }
    
    return _defaultManager;
}

- (id)init
{
    self = [super init];
    [FileUtil createDir:[FileUtil getFileFullPath:TEMP_AVATAR_LOCAL_PATH]];
    [self avatarImage];
    return self;
}

- (void)dealloc
{
    [_avatarImage release];
    [super dealloc];
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

- (NSString*)password
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* value = [userDefaults objectForKey:KEY_PASSWORD];
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

- (void)saveAvatarLocally:(UIImage*)image
{
    if (image == nil)
        return;
    
    BOOL result = [image saveImageToFile:[FileUtil getFileFullPath:AVATAR_LOCAL_FILENAME]];
    if (!result)
        return;
    
    self.avatarImage = image;
}

- (void)setNickName:(NSString*)nickName
{
    if (nickName == nil)
        return;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nickName forKey:KEY_NICKNAME];    
    [userDefaults synchronize];

}

- (void)setAvatar:(NSString*)avatarURL
{
    if (avatarURL == nil)
        return;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:avatarURL forKey:KEY_AVATAR_URL];    
    [userDefaults synchronize];
    
}

- (UIImage*)readAvatarImageLocally
{
    UIImage* localImage = [[[UIImage alloc] initWithContentsOfFile:AVATAR_LOCAL_FILENAME] autorelease];
    return localImage;
}

- (UIImage*)avatarImage
{
    if (_avatarImage == nil){
        // local file
        UIImage* localImage = [self readAvatarImageLocally];        
        if (localImage != nil){
            self.avatarImage = localImage;
            return _avatarImage;
        }                            

        NSString* url = [self avatarURL];
        if ([url length] == 0){
            // use default avatar in application bundle
            self.avatarImage = [UIImage imageNamed:DEFAULT_AVATAR_BUNDLE];
        }
        else{
            // read from server and save it locally
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
                [request setDownloadDestinationPath:[FileUtil getFileFullPath:AVATAR_LOCAL_FILENAME]];
                [request setTemporaryFileDownloadPath:[FileUtil getFileFullPath:TEMP_AVATAR_LOCAL_PATH]];
                [request setAllowResumeForFileDownloads:YES];
                [request startSynchronous];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.avatarImage = [self readAvatarImageLocally];
                });
            });
        }
    }
    
    return _avatarImage;
}

@end
