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
#import "GameBasic.pb.h"
#import "SDWebImageManager.h"
#import "PPSNSConstants.h"
#import "BBSPermissionManager.h"

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
#define KEY_QQ_LOGINID                @"USER_KEY_QQ_LOGINID"
#define KEY_FACEBOOK_LOGINID            @"USER_KEY_FACEBOOK_LOGINID"
#define KEY_FACETIME_ID                 @"USER_KEY_FACETIME_ID"

//#define KEY_SINA_ACCESS_TOKEN           @"USER_KEY_SINA_ACCESS_TOKEN"
//#define KEY_SINA_ACCESS_TOKEN_SECRET    @"USER_KEY_SINA_ACCESS_TOKEN_SECRET"
//
//#define KEY_QQ_ACCESS_TOKEN           @"USER_KEY_QQ_ACCESS_TOKEN"
//#define KEY_QQ_ACCESS_TOKEN_SECRET    @"USER_KEY_QQ_ACCESS_TOKEN_SECRET"
//

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
//    _userDefaults = [NSUserDefaults standardUserDefaults];
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

- (NSString*)email
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* value = [userDefaults objectForKey:KEY_EMAIL];
    return value; 
}

- (NSString*)facetimeId
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* value = [userDefaults objectForKey:KEY_FACETIME_ID];
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
    NSArray* dataArray = [userDefaults objectForKey:KEY_SNS_USER_DATA];
    if (dataArray == nil)
        return nil;
    
    NSMutableArray* snsUserArray = [NSMutableArray arrayWithCapacity:[dataArray count]];
    for (NSData* data in dataArray){
        PBSNSUser* user = [PBSNSUser parseFromData:data];
        if (user != nil){
            [snsUserArray addObject:user];
        }
    }
    
    return snsUserArray;            
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
    
    if ([avatarURL length] > 0){
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

- (void)setEmail:(NSString *)email
{
    if (email == nil)
        return;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:email forKey:KEY_EMAIL];    
    [userDefaults synchronize];    
}

- (void)setFacetimeId:(NSString *)facetimeId
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:facetimeId forKey:KEY_FACETIME_ID];    
    [userDefaults synchronize];
}

- (void)setUserId:(NSString *)userId
{
    if (userId == nil)
        return;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userId forKey:KEY_USERID];    
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
    if ([avatarURL length] == 0)
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
    
    NSString* url = [self avatarURL];
    if ([url length] == 0){
        // use default avatar in application bundle
        self.avatarImage = [UIImage imageNamed:[self defaultAvatar]];
        return _avatarImage;
    }
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:[NSURL URLWithString:url]
                    delegate:self
                     options:0
                     success:^(UIImage *image, BOOL cached){
                         PPDebug(@"download user avatar image from %@, cached=%d", url, cached);
                         self.avatarImage = image;
                     }
                     failure:nil];
    
    return _avatarImage;
    
    /* old implementation
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
                [request setTemporaryFileDownloadPath:NSTemporaryDirectory()];
                [request setAllowResumeForFileDownloads:YES];
                [request startSynchronous];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.avatarImage = [self readAvatarImageLocally];
                });
            });
        }
    }
     */
    
    return _avatarImage;
}

- (void)setSNSUserData:(int)type 
                 snsId:(NSString*)snsId 
              nickName:(NSString*)nickName 
           accessToken:(NSString*)accessToken 
     accessTokenSecret:(NSString*)accessTokenSecret
{
    PPDebug(@"<setSNSUserData> save SNS user, id(%@), nick(%@), token(%@), secret(%@)", 
            snsId, nickName, accessToken, accessTokenSecret);
    
    NSArray* currentData = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_SNS_USER_DATA];
    NSMutableArray* newData = [[NSMutableArray alloc] init];
    if (currentData != nil){
        [newData addObjectsFromArray:currentData];
    }

    BOOL found = NO;
    int index = 0;
    PBSNSUser* userFound = nil;
    for (NSData* data in newData){
        userFound = [PBSNSUser parseFromData:data];
        if ([userFound type] == type){
            found = YES;            
            break;
        }        
        index ++;
    }

    // create an new user
    PBSNSUser_Builder* builder = [[PBSNSUser_Builder alloc] init];
    [builder setType:type];
    [builder setUserId:snsId];
    
    if (nickName == nil){
        [builder setNickName:[userFound nickName]];
    }
    else{
        [builder setNickName:nickName];   
    }
    
    if (accessTokenSecret != nil)
        [builder setAccessTokenSecret:accessTokenSecret];
    else
        [builder setAccessTokenSecret:[userFound accessTokenSecret]];
    
    if (accessToken != nil)
        [builder setAccessToken:accessToken];
    else
        [builder setAccessToken:[userFound accessToken]];
    
    PBSNSUser* user = [builder build];
    NSData* data = [user data];
    
    if (found){
        [newData replaceObjectAtIndex:index withObject:data];
    }
    else{
        [newData addObject:data];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:newData forKey:KEY_SNS_USER_DATA];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [builder release];
    [newData release];
}

- (void)saveUserId:(NSString*)userId
            sinaId:(NSString*)loginId
          password:(NSString*)password 
          nickName:(NSString*)nickName
         avatarURL:(NSString*)avatarURL
   sinaAccessToken:(NSString*)accessToken
sinaAccessTokenSecret:(NSString*)accessTokenSecret 
            gender:(NSString*)gender
{
    PPDebug(@"Save userId(%@), loginId(%@), nickName(%@), avatarURL(%@)", userId, loginId, nickName, avatarURL);    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self setUserId:userId];
    [self setNickName:nickName];
    [self setPassword:password];
    [self setAvatar:avatarURL];    
    if ([avatarURL length] > 0){
        [self avatarImage];
    }    
    [self setGender:gender];    
    [self setSinaId:loginId nickName:nickName];
    
    [userDefaults synchronize];    
}

- (void)saveUserId:(NSString*)userId
              qqId:(NSString*)loginId
          password:(NSString*)password 
          nickName:(NSString*)nickName
         avatarURL:(NSString*)avatarURL
     qqAccessToken:(NSString*)accessToken
qqAccessTokenSecret:(NSString*)accessTokenSecret 
            gender:(NSString *)gender
{
    PPDebug(@"Save userId(%@), loginId(%@), nickName(%@), avatarURL(%@) accessToken(%@) accessTokenSecret(%@)", userId, loginId, nickName, avatarURL, accessToken, accessTokenSecret);    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self setUserId:userId];
    [self setNickName:nickName];
    [self setPassword:password];
    [self setAvatar:avatarURL];    
    if ([avatarURL length] > 0){
        [self avatarImage];
    }    
    [self setGender:gender];    
    [self setQQId:loginId nickName:nickName accessToken:accessToken accessTokenSecret:accessTokenSecret];    
    [userDefaults synchronize];     
}


- (void)saveUserId:(NSString*)userId
        facebookId:(NSString*)loginId
          password:(NSString*)password 
          nickName:(NSString*)nickName
         avatarURL:(NSString*)avatarURL 
            gender:(NSString *)gender
{
    PPDebug(@"Save userId(%@), loginId(%@), nickName(%@), avatarURL(%@)", userId, loginId, nickName, avatarURL);    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self setUserId:userId];
    [self setNickName:nickName];
    [self setPassword:password];
    [self setAvatar:avatarURL];    
    if ([avatarURL length] > 0){
        [self avatarImage];
    }    
    [self setGender:gender];    
    [self setFacebookId:loginId nickName:nickName];
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
            gender:(NSString *)gender
{
    PPDebug(@"Save userId(%@), email(%@), nickName(%@)", userId, email, nickName);    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];

    //Email用户
    [self setUserId:userId];
    [self setNickName:nickName];
    [self setPassword:password];
    [self setAvatar:avatarURL];    
    if ([avatarURL length] > 0){
        [self avatarImage];
    }    
    [self setGender:gender];    
    [self setEmail:email];

    //facebook用户
    if (facebookId != nil){
        [self setFacebookId:facebookId nickName:nickName];
    }
    
    //qq绑定用户
    if (qqId != nil){
        [self setQQId:qqId nickName:nickName accessToken:qqAccessToken accessTokenSecret:qqAccessTokenSecret];
    }

    //新浪绑定用户
    if (sinaId != nil){
        [self setSinaId:sinaId nickName:nickName];
    }
    
    if ([avatarURL length] > 0){
        [userDefaults setObject:avatarURL forKey:KEY_AVATAR_URL];
        if (email == nil) {
            [self avatarImage];
        }
    }
    
    if (balance != nil) {
        [[AccountManager defaultManager] updateBalance:balance.intValue];
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
        /* rem by Benson
        if ([LocaleUtils isChina] || [LocaleUtils isOtherChina] ||
            [LocaleUtils isChinese] || [LocaleUtils isTraditionalChinese]){
            type = ChineseType;
        }else{
            type = EnglishType;
        }
        */
        
        // it's Chinese by default due to English Draw & Guess has no many users, so we just focus on Chinese
        type = ChineseType;
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
    NSString* token = [self qqToken];    
    if (obj != nil && [token length] > 0) {
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

#define OPUS_PREFIX @"opus_"

- (NSString *)opusKeyForOpusId:(NSString *)opusId
{
    return [NSString stringWithFormat:@"%@%@",OPUS_PREFIX,opusId];
}

- (void)guessCorrectOpus:(NSString *)opusId
{
    if([opusId length] == 0) return;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self opusKeyForOpusId:opusId];
    [defaults setBool:YES forKey:key];
    [defaults synchronize];
}

- (BOOL)hasGuessOpus:(NSString *)opusId
{
    if([opusId length] == 0) return NO;
    NSString *key = [self opusKeyForOpusId:opusId];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:key]) {
        return YES;
    }
    return NO;
}

#pragma mark - sns data getter & setter

- (PBSNSUser*)snsUserByType:(int)type
{
    NSArray* pbUserArray = [self snsUserData];
    for (PBSNSUser* user in pbUserArray) {
        @try {
            if (user.type == type) {
                return user;
            }
        }
        @catch (NSException *exception) {
            PPDebug(@"<snsUserByType> catch exception=%@", [exception description]);
            return nil;
        }

    }
    return nil;    
}

- (void)setFacebookId:(NSString*)facebookId nickName:(NSString*)nickName
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:facebookId forKey:KEY_FACEBOOK_LOGINID];
    [self setSNSUserData:TYPE_FACEBOOK snsId:facebookId nickName:nickName accessToken:nil accessTokenSecret:nil];
}

- (void)setSinaId:(NSString*)sinaId nickName:(NSString*)nickName
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];    
    [userDefaults setObject:sinaId forKey:KEY_SINA_LOGINID];
    [self setSNSUserData:TYPE_SINA snsId:sinaId nickName:nickName accessToken:nil accessTokenSecret:nil];    
}

- (void)setQQId:(NSString*)qqId nickName:(NSString*)nickName accessToken:(NSString*)accessToken accessTokenSecret:(NSString*)accessTokenSecret
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];    
    [userDefaults setObject:qqId forKey:KEY_QQ_LOGINID];
    [self setSNSUserData:TYPE_QQ snsId:qqId nickName:nickName accessToken:accessToken accessTokenSecret:accessTokenSecret];        
}

- (NSString*)sinaId
{
    PBSNSUser* user = [self snsUserByType:TYPE_SINA];
    return [user userId];
}

- (NSString*)sinaNickName
{
    PBSNSUser* user = [self snsUserByType:TYPE_SINA];
    return [user nickName];
}

- (NSString*)sinaToken
{
    return nil;
}

- (NSString*)sinaTokenSecret
{
    return nil;
}

- (NSString*)qqId
{
    PBSNSUser* user = [self snsUserByType:TYPE_QQ];
    return [user userId];
}

- (NSString*)qqNickName
{
    PBSNSUser* user = [self snsUserByType:TYPE_QQ];
    return [user nickName];
}

- (NSString*)qqToken
{
    PBSNSUser* user = [self snsUserByType:TYPE_QQ];
    return [user accessToken];
}

- (NSString*)qqTokenSecret
{
    PBSNSUser* user = [self snsUserByType:TYPE_QQ];
    return [user accessTokenSecret];
}

- (NSString*)facebookId
{
    PBSNSUser* user = [self snsUserByType:TYPE_FACEBOOK];
    return [user userId];
}

- (PBGameUser*)toPBGameUser
{
    if ([self hasUser] == NO)
        return nil;
    
    // return a PBGame User structure here
    PBGameUser_Builder* builder = [[[PBGameUser_Builder alloc] init] autorelease];
    [builder setUserId:[self userId]];
    [builder setNickName:[self nickName]];    
    [builder setAvatar:[self avatarURL]];

    [builder setLocation:[self location]];
    [builder setGender:[self.gender isEqualToString:@"m"]];
    [builder setFacetimeId:[self facetimeId]];
    
    return [builder build];
}

- (PBGameUser*)toPBGameUserWithKeyValues:(NSArray*)keyValueArray
{
    if ([self hasUser] == NO)
        return nil;
    
    // return a PBGame User structure here
    PBGameUser_Builder* builder = [[[PBGameUser_Builder alloc] init] autorelease];
    [builder setUserId:[self userId]];
    [builder setNickName:[self nickName]];    
    [builder setAvatar:[self avatarURL]];
    
    [builder setLocation:[self location]];
    [builder setGender:[self.gender isEqualToString:@"m"]];
    [builder setFacetimeId:[self facetimeId]];
    for (PBKeyValue* kValue in keyValueArray) {
        [builder addAttributes:kValue];
    }
    
    return [builder build];
}

- (NSString*)defaultUserRoomName
{
    return [NSString stringWithFormat:NSLS(@"kWhoseRoom"),self.nickName];
}

#define FOLLOW_WEIBO @"FOLLOW_WEIBO"
- (BOOL)hasFollowWeibo
{
   return [[NSUserDefaults standardUserDefaults] boolForKey:FOLLOW_WEIBO];
}
- (void)followWeibo
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FOLLOW_WEIBO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isSuperUser
{
    return [[BBSPermissionManager defaultManager] canCharge] && [[BBSPermissionManager defaultManager] canForbidUserIntoBlackUserList];
}

@end
