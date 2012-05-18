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
#import "LocaleUtils.h"
#import "ShareImageManager.h"
#import "StringUtil.h"
#import "AccountManager.h"
#import "ItemManager.h"
#import "GameNetworkConstants.h"
#import "SNSConstants.h"
#import "GameBasic.pb.h"

#define KEY_USERID          @"USER_KEY_USERID"
#define KEY_NICKNAME        @"USER_KEY_NICKNAME"
#define KEY_AVATAR_URL      @"USER_KEY_AVATAR_URL"
#define KEY_DEVICE_TOKEN    @"USER_KEY_DEVICE_TOKEN"
#define KEY_EMAIL           @"USER_KEY_EMAIL"
#define KEY_PASSWORD        @"USER_KEY_PASSWORD"
#define KEY_LANGUAGE        @"USER_KEY_LANGUAGE"
#define KEY_GENDER          @"USER_KEY_GENDER"
#define KEY_SNS_USER_DATA   @"USER_KEY_SNS_USER_DATA"
#define KEY_LOCATION        @"USER_KEY_LOCATION"

#define KEY_SINA_LOGINID                @"USER_KEY_SINA_LOGINID"
#define KEY_SINA_ACCESS_TOKEN           @"USER_KEY_SINA_ACCESS_TOKEN"
#define KEY_SINA_ACCESS_TOKEN_SECRET    @"USER_KEY_SINA_ACCESS_TOKEN_SECRET"

#define KEY_QQ_LOGINID                @"USER_KEY_QQ_LOGINID"
#define KEY_QQ_ACCESS_TOKEN           @"USER_KEY_QQ_ACCESS_TOKEN"
#define KEY_QQ_ACCESS_TOKEN_SECRET    @"USER_KEY_QQ_ACCESS_TOKEN_SECRET"

#define KEY_FACEBOOK_LOGINID            @"USER_KEY_FACEBOOK_LOGINID"

#define KEY_ROOM_COUNT            @"KEY_ROOM_COUNT"

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

- (NSString*)location
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* value = [userDefaults objectForKey:KEY_LOCATION];
    return value;        
}

- (NSArray*)snsUserData
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray* value = [userDefaults objectForKey:KEY_SNS_USER_DATA];
    return value;            
}

- (BOOL)isMe:(NSString *)userId
{
    if ([userId isEqualToString:[self userId]]) {
        return YES;
    }
    return NO;
}

- (BOOL)isPasswordEmpty
{
    if ([self.password length] == 0) {
        return YES;
    }
    return NO;
}

- (BOOL)isPasswordCorrect:(NSString *)userInput
{
    NSString *md5Password = [userInput encodeMD5Base64:PASSWORD_KEY];
    return [md5Password isEqualToString:self.password];
}

- (BOOL)hasUser
{
    return ([[self userId] length] > 0);
}

- (NSString*)gender
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:KEY_GENDER];
}

- (NSString*)defaultAvatar
{
    if ([self isUserMale]){
        return [LocaleUtils isChina] ? @"man1.png" : @"man2.png";                
    }
    else{        
        return [LocaleUtils isChina] ? @"female1.png" : @"female2.png";
    }
}

- (BOOL)isUserMale
{
    NSString* gender = [self gender];
    if (gender == nil)
        return YES;
    else
        return [gender isEqualToString:@"m"];
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
    if (image == nil){
        image = [UIImage imageNamed:[self defaultAvatar]];
    }
    
    BOOL result = [image saveImageToFile:[FileUtil getFileFullPath:AVATAR_LOCAL_FILENAME]];
    if (!result)
        return;
    
    self.avatarImage = image;
}

- (void)setLocation:(NSString*)location
{
    if (location == nil)
        return;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:location forKey:KEY_LOCATION];    
    [userDefaults synchronize];        
}

- (void)setGender:(NSString*)gender
{
    if (gender == nil)
        return;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:gender forKey:KEY_GENDER];    
    [userDefaults synchronize];    
}

- (void)setNickName:(NSString *)nickName
{
    if (nickName == nil)
        return;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nickName forKey:KEY_NICKNAME];    
    [userDefaults synchronize];
    
}

- (void)setDeviceToken:(NSString*)deviceToken
{
    if (deviceToken == nil)
        return;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:deviceToken forKey:KEY_DEVICE_TOKEN];    
    [userDefaults synchronize];
    
}

- (void)setPassword:(NSString*)password
{
    if (password == nil)
        return;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:password forKey:KEY_PASSWORD];    
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
            self.avatarImage = [UIImage imageNamed:[self defaultAvatar]];
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

- (void)setSNSUserData:(int)type snsId:(NSString*)snsId nickName:(NSString*)nickName
{
    NSArray* currentData = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_SNS_USER_DATA];
    NSMutableArray* newData = [[NSMutableArray alloc] init];
    if (currentData != nil){
        [newData addObjectsFromArray:currentData];
    }

    BOOL found = NO;
    int index = 0;
    for (PBSNSUser* user in newData){
        if ([user type] == type){
            found = YES;            
            break;
        }        
        index ++;
    }

    // create an new user
    PBSNSUser_Builder* builder = [[PBSNSUser_Builder alloc] init];
    [builder setType:type];
    [builder setUserId:snsId];
    [builder setNickName:nickName];     
    PBSNSUser* user = [builder build];
    [builder release];

    if (found){
        [newData replaceObjectAtIndex:index withObject:user];
    }
    else{
        [newData addObject:user];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:newData forKey:KEY_SNS_USER_DATA];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [newData release];
}

- (void)saveUserId:(NSString*)userId
            sinaId:(NSString*)loginId
          password:(NSString*)password 
          nickName:(NSString*)nickName
         avatarURL:(NSString*)avatarURL
   sinaAccessToken:(NSString*)accessToken
sinaAccessTokenSecret:(NSString*)accessTokenSecret
{
    PPDebug(@"Save userId(%@), loginId(%@), nickName(%@), avatarURL(%@)", userId, loginId, nickName, avatarURL);    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (userId != nil){
        [userDefaults setObject:userId forKey:KEY_USERID];
    }
    
    if ([nickName length] > 0){
        [userDefaults setObject:nickName forKey:KEY_NICKNAME];
    }
    
    if (loginId != nil){
        [userDefaults setObject:loginId forKey:KEY_SINA_LOGINID];
    }
    
    if ([password length] > 0){
        [userDefaults setObject:password forKey:KEY_PASSWORD];
    }
    
    if (accessToken != nil){
        [userDefaults setObject:accessToken forKey:KEY_SINA_ACCESS_TOKEN];
    }
    
    if (accessTokenSecret != nil){
        [userDefaults setObject:accessTokenSecret forKey:KEY_SINA_ACCESS_TOKEN_SECRET];
    }
    
    if ([avatarURL length] > 0){
        [userDefaults setObject:avatarURL forKey:KEY_AVATAR_URL];
        [self avatarImage];
    }
    
    [self setSNSUserData:TYPE_SINA snsId:loginId nickName:nickName];
    
    [userDefaults synchronize];    
}

- (void)saveUserId:(NSString*)userId
              qqId:(NSString*)loginId
          password:(NSString*)password 
          nickName:(NSString*)nickName
         avatarURL:(NSString*)avatarURL
     qqAccessToken:(NSString*)accessToken
qqAccessTokenSecret:(NSString*)accessTokenSecret
{
    PPDebug(@"Save userId(%@), loginId(%@), nickName(%@), avatarURL(%@)", userId, loginId, nickName, avatarURL);    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (userId != nil){
        [userDefaults setObject:userId forKey:KEY_USERID];
    }
    
    if ([nickName length] > 0){
        [userDefaults setObject:nickName forKey:KEY_NICKNAME];
    }
    
    if (loginId != nil){
        [userDefaults setObject:loginId forKey:KEY_QQ_LOGINID];
    }
    
    if ([password length] > 0){
        [userDefaults setObject:password forKey:KEY_PASSWORD];
    }
    
    if (accessToken != nil){
        [userDefaults setObject:accessToken forKey:KEY_QQ_ACCESS_TOKEN];
    }
    
    if (accessTokenSecret != nil){
        [userDefaults setObject:accessTokenSecret forKey:KEY_QQ_ACCESS_TOKEN_SECRET];
    }
    
    if ([avatarURL length] > 0){
        [userDefaults setObject:avatarURL forKey:KEY_AVATAR_URL];
        [self avatarImage];
    }
    
    [self setSNSUserData:TYPE_QQ snsId:loginId nickName:nickName];
    
    [userDefaults synchronize];     
}


- (void)saveUserId:(NSString*)userId
        facebookId:(NSString*)loginId
          password:(NSString*)password 
          nickName:(NSString*)nickName
         avatarURL:(NSString*)avatarURL
{
    PPDebug(@"Save userId(%@), loginId(%@), nickName(%@), avatarURL(%@)", userId, loginId, nickName, avatarURL);    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (userId != nil){
        [userDefaults setObject:userId forKey:KEY_USERID];
    }
    
    if ([nickName length] > 0){
        [userDefaults setObject:nickName forKey:KEY_NICKNAME];
    }
    
    if (loginId != nil){
        [userDefaults setObject:loginId forKey:KEY_FACEBOOK_LOGINID];
    }
    
    if ([password length] > 0){
        [userDefaults setObject:password forKey:KEY_PASSWORD];
    }
    
    if ([avatarURL length] > 0){
        [userDefaults setObject:avatarURL forKey:KEY_AVATAR_URL];
        [self avatarImage];
    }
    
    [self setSNSUserData:TYPE_FACEBOOK snsId:loginId nickName:nickName];
    
    [userDefaults synchronize];     
}

- (void)saveUserId:(NSString*)userId 
             email:(NSString*)email
          password:(NSString*)password
          nickName:(NSString*)nickName 
              qqId:(NSString*)qqId 
     qqAccessToken:(NSString*)qqAccessToken 
qqAccessTokenSecret:(NSString*)qqAccessTokenSecret 
            sinaId:(NSString*)sinaId 
   sinaAccessToken:(NSString*)sinaAccessToken 
sinaAccessTokenSecret:(NSString*)sinaAccessTokenSecret 
        facebookId:(NSString*)facebookId
         avatarURL:(NSString*)avatarURL 
           balance:(NSNumber*)balance 
             items:(NSArray *)items
{
    PPDebug(@"Save userId(%@), email(%@), nickName(%@)", userId, email, nickName);    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    //email用户
    if (userId != nil) {
        [userDefaults setObject:userId forKey:KEY_USERID];
    }
    if (nickName != nil) {
        [userDefaults setObject:nickName forKey:KEY_NICKNAME];
    }
    if (email != nil) {
        [userDefaults setObject:email forKey:KEY_EMAIL];
    }
    if (password != nil) {
        [userDefaults setObject:password forKey:KEY_PASSWORD];
    }
    //facebook用户
    if (facebookId != nil){
        [userDefaults setObject:facebookId forKey:KEY_FACEBOOK_LOGINID];
    }
    //qq绑定用户
    if (qqId != nil){
        [userDefaults setObject:qqId forKey:KEY_QQ_LOGINID];
    }
    if (qqAccessToken != nil){
        [userDefaults setObject:qqAccessToken forKey:KEY_QQ_ACCESS_TOKEN];
    }
    
    if (qqAccessTokenSecret != nil){
        [userDefaults setObject:qqAccessTokenSecret forKey:KEY_QQ_ACCESS_TOKEN_SECRET];
    }
    //渣浪绑定用户
    if (sinaId != nil){
        [userDefaults setObject:sinaId forKey:KEY_SINA_LOGINID];
    }
    if (sinaAccessToken != nil){
        [userDefaults setObject:sinaAccessToken forKey:KEY_SINA_ACCESS_TOKEN];
    }
    
    if (sinaAccessTokenSecret != nil){
        [userDefaults setObject:sinaAccessTokenSecret forKey:KEY_SINA_ACCESS_TOKEN_SECRET];
    }
    
    if (avatarURL != nil){
        [userDefaults setObject:avatarURL forKey:KEY_AVATAR_URL];
        if (email == nil) {
            [self avatarImage];
        }
    }
    if (balance != nil) {
        [[AccountManager defaultManager] updateBalanceFromServer:balance.intValue];
    }
    if (items != nil) {
        for (NSDictionary* itemTypeBalance in items){
            int itemType = [[itemTypeBalance objectForKey:PARA_ITEM_TYPE] intValue];
            int itemAmount = [[itemTypeBalance objectForKey:PARA_ITEM_AMOUNT] intValue];                    
            
            // update DB
            [[ItemManager defaultManager] addNewItem:itemType amount:itemAmount];
            PPDebug(@"<syncAccountAndItem> add client item type[%d], amount[%d]", itemType, itemAmount);
        }
    }
    
    if (sinaId != nil){
        [self setSNSUserData:TYPE_SINA snsId:sinaId nickName:nil];        
    }

    if (qqId != nil){
        [self setSNSUserData:TYPE_QQ snsId:qqId nickName:nil];                
    }
    
    if (facebookId != nil){
        [self setSNSUserData:TYPE_FACEBOOK snsId:facebookId nickName:nil];                        
    }
    
    [userDefaults synchronize];
}

- (void)setLanguageType:(LanguageType)type
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:type forKey:KEY_LANGUAGE];
    [userDefaults synchronize];
}

- (LanguageType)getLanguageType
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    LanguageType type = [userDefaults integerForKey:KEY_LANGUAGE];
    if (type == 0) {
        if ([LocaleUtils isChina]){
            type = ChineseType;
        }else{
            type = EnglishType;
        }
        [self setLanguageType:type];
    }
    return type;
}

- (BOOL)hasBindSinaWeibo
{
    NSObject *obj = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_SINA_LOGINID];
    if (obj != nil) {
        return YES;
    }
    return NO;

}
- (BOOL)hasBindQQWeibo
{
    NSObject *obj = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_QQ_LOGINID];
    if (obj != nil) {
        return YES;
    }
    return NO;

}
- (BOOL)hasBindFacebook
{
    NSObject *obj = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_FACEBOOK_LOGINID];
    if (obj != nil) {
        return YES;
    }
    return NO;
}

- (NSInteger)roomCount
{
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_ROOM_COUNT];
    if (count < 0) {
        return 0;
    }
    return count;

}
- (void)increaseRoomCount
{
    NSInteger count = [self roomCount];
    [[NSUserDefaults standardUserDefaults] setInteger:++count forKey:KEY_ROOM_COUNT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
