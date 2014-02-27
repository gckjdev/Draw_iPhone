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
#import "GameNetworkConstants.h"
#import "GameBasic.pb.h"
#import "SDWebImageManager.h"
#import "PPSNSConstants.h"
#import "BBSPermissionManager.h"
#import "StorageManager.h"
#import "UIImage+Scale.h"
#import "PPConfigManager.h"


#define KEY_ALL_USER_PB_DATA            @"KEY_ALL_USER_PB_DATA"
#define KEY_USERID                      @"USER_KEY_USERID"
#define KEY_NICKNAME                    @"USER_KEY_NICKNAME"
#define KEY_AVATAR_URL                  @"USER_KEY_AVATAR_URL"
#define KEY_DEVICE_TOKEN                @"USER_KEY_DEVICE_TOKEN"
#define KEY_EMAIL                       @"USER_KEY_EMAIL"
#define KEY_PASSWORD                    @"USER_KEY_PASSWORD"
#define KEY_LANGUAGE                    @"USER_KEY_LANGUAGE"
#define KEY_GENDER                      @"USER_KEY_GENDER"
#define KEY_SNS_USER_DATA               @"USER_KEY_SNS_USER_DATA"
#define KEY_LOCATION                    @"USER_KEY_LOCATION"

#define KEY_SINA_LOGINID                @"USER_KEY_SINA_LOGINID"
#define KEY_QQ_LOGINID                  @"USER_KEY_QQ_LOGINID"
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
    [FileUtil createDir:[FileUtil getFileFullPath:TEMP_AVATAR_LOCAL_PATH]];
    [self loadUserData];
    [self avatarImage];
    return self;
}

- (void)dealloc
{
    PPRelease(_pbUser);
    [_avatarImage release];
    [super dealloc];
}

#define KEY_HOT_CONTROLLER_DEFAULT_TYPE @"KEY_HOT_CONTROLLER_DEFAULT_TYPE"

- (HotIndexType)hotControllerIndex{
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    int defaultType = [ud integerForKey:KEY_HOT_CONTROLLER_DEFAULT_TYPE];
    if (defaultType == HotUnknownIndex){
        
        if (self.pbUser.level > 1 || isDrawApp() == NO){
            return HotTopIndex;
        }
        else{
            return [PPConfigManager defaultHotControllerIndex];
        }
    }
    else{
        return defaultType;
    }
}

- (void)setHotControllerIndex:(HotIndexType)index
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:index forKey:KEY_HOT_CONTROLLER_DEFAULT_TYPE];
    [ud synchronize];
}

- (void)loadUserDataFromOldStorage
{
    if ([[self userIdFromOldStorage] length] == 0)
        return;        
    
    // return a PBGame User structure here
    PBGameUser_Builder* builder = [[[PBGameUser_Builder alloc] init] autorelease];
    [builder setUserId:[self userIdFromOldStorage]];
    [builder setNickName:[self nickNameFromOldStorage]];
    
    NSString* avatar = [self avatarURLFromOldStorage];
    if (avatar != nil)
        [builder setAvatar:avatar];
    
    NSString* location = [self locationFromOldStorage];
    if (location != nil)
        [builder setLocation:location];
    
    BOOL gender = [[self genderFromOldStorage] isEqualToString:@"m"];
    [builder setGender:gender];
    
    NSString* email = [self emailFromOldStorage];
    if (email != nil)
        [builder setEmail:email];
    
    NSString* password = [self passwordFromOldStorage];
    if (password != nil)
        [builder setPassword:password];
    
    NSArray* snsArray = [self snsUserDataFromOldStorage];
    if (snsArray != nil)
        [builder addAllSnsUsers:snsArray];

    // set guess word language type
    [builder setGuessWordLanguage:[self getLanguageTypeFromOldStorage]];
    
    // set device token
    [builder setDeviceToken:[self deviceTokenFromOldStorage]];
    
    self.pbUser = [builder build];
    return;    
}

- (void)loadUserData
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSData* data = [userDefaults objectForKey:KEY_ALL_USER_PB_DATA];
    if (data == nil || [data length] == 0){
        // load pb user from old data
        [self loadUserDataFromOldStorage];
        return;
    }

    self.pbUser = [PBGameUser parseFromData:data];
    if (self.pbUser == nil){
        PPDebug(@"<loadUserData> cannot load user data");
    }
    else{
        PPDebug(@"<loadUserData> success, userId=%@, nickName=%@", [_pbUser userId], [_pbUser nickName]);
    }
    
    // set device token if needed
    if ([[self.pbUser deviceToken] length] == 0){
        [self setDeviceToken:[self deviceTokenFromOldStorage]];
    }
}

- (void)storeUserData
{
    [self storeUserData:self.pbUser];
}

- (void)storeUserData:(PBGameUser*)user
{
    if (user == nil)
        return;
    
    self.pbUser = user;
    
    NSData* data = [self.pbUser data];
    if (data == nil)
        return;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:KEY_ALL_USER_PB_DATA];
    [userDefaults synchronize];
    PPDebug(@"<storeUserData> store user data success!");
    
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFCATION_USER_DATA_CHANGE object:nil];
}

- (void)cleanUserData
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:KEY_ALL_USER_PB_DATA];
    [userDefaults synchronize];
    PPDebug(@"<cleanUserData> clean user data success!");
    
    self.pbUser = nil;

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFCATION_USER_DATA_CHANGE object:nil];
}

- (NSString*)userId
{
//#ifdef DEBUG
//    return @"525cbe4e03642a00eab64d4e";
//#endif
    
    return [_pbUser userId];
}

- (NSString*)userIdFromOldStorage
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:KEY_USERID];
}

- (NSString*)nickName
{
    return [_pbUser nickName];

}

- (NSString*)nickNameFromOldStorage
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:KEY_NICKNAME];
}

- (NSString*)avatarURL
{
    return [_pbUser avatar];

}

- (NSString*)avatarURLFromOldStorage
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* value = [userDefaults objectForKey:KEY_AVATAR_URL];
    return value;
}

- (NSString*)deviceToken
{
    return [_pbUser deviceToken];
}

- (NSString*)deviceTokenFromOldStorage
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* value = [userDefaults objectForKey:KEY_DEVICE_TOKEN];
    return value;
}

- (NSString*)password
{
    return [_pbUser password];

}

- (NSString*)passwordFromOldStorage
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* value = [userDefaults objectForKey:KEY_PASSWORD];
    return value;
}

- (NSString*)email
{
    return [_pbUser email];

}

- (NSString*)emailFromOldStorage
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* value = [userDefaults objectForKey:KEY_EMAIL];
    return value;
}

- (NSString*)facetimeId
{
    return [_pbUser facetimeId];
}

- (NSString*)birthday
{
    return [_pbUser birthday];
}

- (NSInteger)zodiac
{
    return [_pbUser zodiac];
}

- (NSInteger)followCount
{
    return [_pbUser followCount];
}

- (NSInteger)fanCount
{
    return [_pbUser fanCount];
}

- (NSString*)bloodGroup
{
    return [_pbUser bloodGroup];
}

- (int)level
{
    return [_pbUser level];
}

- (long)experience
{
    return [_pbUser experience];
}

- (NSString*)signature
{
    return [_pbUser signature];
}

- (NSString*)facetimeIdFromOldStorage
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* value = [userDefaults objectForKey:KEY_FACETIME_ID];
    return value;
}

- (NSString*)location
{
    return [_pbUser location];

}

- (NSString*)locationFromOldStorage
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* value = [userDefaults objectForKey:KEY_LOCATION];
    return value;
}

- (NSArray*)snsUserData
{
    return [_pbUser snsUsersList];

}

- (NSArray*)snsUserDataFromOldStorage
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
    return [_pbUser gender] ? @"m" : @"f";
}

- (BOOL)boolGender
{
    return [_pbUser gender];    
}

- (NSString*)genderFromOldStorage
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:KEY_GENDER];
}

- (NSString*)defaultAvatar
{
    return [self isUserMale] ?  @"man.png" : @"female.png";
}

- (UIImage*)defaultAvatarImage
{
    return [UIImage imageNamed:[self defaultAvatar]];
}

- (BOOL)isUserMale
{
    NSString* gender = [self gender];
    if (gender == nil)
        return YES;
    else
        return [gender isEqualToString:@"m"];
}

- (BOOL)isMale:(NSString*)gender
{
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
    PPDebug(@"Save userId(%@), email(%@), nickName(%@), avatar(%@)", userId, email, nickName, avatarURL);
    
    [self setUserId:userId];
    [self setNickName:nickName];
    [self setEmail:email];
    [self setPassword:password];
    [self setAvatar:avatarURL];
    
    [self storeUserData];
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
    if (self.pbUser == nil)
        return;
    
    if (location == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setLocation:location];
    self.pbUser = [builder build];
}

- (void)setGender:(NSString*)gender
{
    if (self.pbUser == nil)
        return;
    
    if (gender == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setGender:[self isMale:gender]];
    self.pbUser = [builder build];
}

- (void)setNickName:(NSString *)nickName
{
    if (self.pbUser == nil)
        return;
    
    if (nickName == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setNickName:nickName];
    self.pbUser = [builder build];
}

- (void)setExperience:(long)exp
{
    if (self.pbUser == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setExperience:exp];
    self.pbUser = [builder build];
    [self storeUserData];
}

- (void)setLevel:(int)level
{
    if (self.pbUser == nil)
        return;

    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setLevel:level];
    self.pbUser = [builder build];
    [self storeUserData];
}

- (void)setSingLimitTime:(int)value{
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setSingRecordLimit:value];
    self.pbUser = [builder build];
    [self storeUserData];
}


- (void)setEmail:(NSString *)email
{
    if (self.pbUser == nil)
        return;
    
    if (email == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setEmail:email];
    self.pbUser = [builder build];
}

- (void)setFacetimeId:(NSString *)facetimeId
{
    if (self.pbUser == nil)
        return;
    
    if (facetimeId == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setFacetimeId:facetimeId];
    self.pbUser = [builder build];
}

- (void)setBirthday:(NSString *)birthdayString
{
    if (self.pbUser == nil)
        return;
    
    if (birthdayString == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setBirthday:birthdayString];
    self.pbUser = [builder build];

}

- (void)setZodiac:(NSInteger)zodiac
{
    if (self.pbUser == nil)
        return;    
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setZodiac:zodiac];
    self.pbUser = [builder build];
}

- (void)setFollowCount:(NSInteger)followCount
{
    if (self.pbUser == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setFollowCount:followCount];
    self.pbUser = [builder build];
}

- (void)setFanCount:(NSInteger)fanCount
{
    if (self.pbUser == nil)
        return;

    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setFanCount:fanCount];
    self.pbUser = [builder build];
}

- (void)setFeatureOpus:(NSInteger)flag
{
    if (self.pbUser == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setFeatureOpus:flag];
    self.pbUser = [builder build];
}

- (void)setBloodGroup:(NSString*)bloodGroup
{
    if (self.pbUser == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setBloodGroup:bloodGroup];
    self.pbUser = [builder build];
}

- (void)setSignature:(NSString *)signature
{
    if (self.pbUser == nil)
        return;

    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setSignature:signature];
    self.pbUser = [builder build];
}

- (void)setUserId:(NSString *)userId
{    
    if (userId == nil)
        return;
    
    PBGameUser_Builder* builder = nil;
    
    if (self.pbUser != nil){
        builder = [PBGameUser builderWithPrototype:self.pbUser];
        [builder setUserId:userId];
    }
    else{
        builder = [PBGameUser builder];
        [builder setUserId:userId];
        [builder setNickName:@""];
    }
    
    self.pbUser = [builder build];
}


- (void)setDeviceToken:(NSString*)deviceToken
{
    if (deviceToken == nil)
        return;

    if (self.pbUser == nil){
        PPDebug(@"<setDeviceToken> but user not found, store into user defaults");
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:deviceToken forKey:KEY_DEVICE_TOKEN];
        [userDefaults synchronize];
        return;
    }
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setDeviceToken:deviceToken];
    self.pbUser = [builder build];
    [self storeUserData];    
}

- (void)setPassword:(NSString*)password
{
    if (self.pbUser == nil)
        return;
    
    if (password == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setPassword:password];
    self.pbUser = [builder build];
}

- (void)setAvatar:(NSString*)avatarURL
{
    if (self.pbUser == nil)
        return;
    
    if ([avatarURL length] == 0)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setAvatar:avatarURL];
    self.pbUser = [builder build];
        
}

- (void)setBackground:(NSString*)url
{
    if (self.pbUser == nil)
        return;
    
    if ([url length] == 0)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setBackgroundUrl:url];
    self.pbUser = [builder build];
    
}

- (void)setDeviceModel:(NSString*)deviceModel
{
    if (self.pbUser == nil)
        return;
    
    if (deviceModel == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setDeviceModel:deviceModel];
    self.pbUser = [builder build];

}

- (void)setDeviceType:(int)deviceType
{
    if (self.pbUser == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setDeviceType:[NSString stringWithFormat:@"%d", deviceType]];
    self.pbUser = [builder build];
    
}

- (void)setDeviceId:(NSString*)deviceId
{
    if (self.pbUser == nil)
        return;
    
    if (deviceId == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setDeviceId:deviceId];
    self.pbUser = [builder build];
    
}

- (void)setDeviceOS:(NSString*)deviceOS
{
    if (self.pbUser == nil)
        return;
    
    if (deviceOS == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setDeviceOs:deviceOS];
    self.pbUser = [builder build];    
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
    
    [manager downloadWithURL:[NSURL URLWithString:url] options:SDWebImageRetryFailed progress:NULL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
        
        if (finished && error == nil) {
            PPDebug(@"download user avatar image from %@, cached=%d", url, cacheType);
            self.avatarImage = image;
        }
    }];
    
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
    
    NSArray* currentData = [[[self.pbUser snsUsersList] copy] autorelease]; //[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SNS_USER_DATA];
    NSMutableArray* newData = [[NSMutableArray alloc] init];
    if (currentData != nil){
        [newData addObjectsFromArray:currentData];
    }
    
    int index = 0;
    BOOL found = NO;
    PBSNSUser* userFound = nil;
    for (PBSNSUser* snsUser in newData){
        if (snsUser.type == type){
            found = YES;
            userFound = snsUser;
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
    if (found){
        [newData replaceObjectAtIndex:index withObject:user];
    }
    else{
        [newData addObject:user];
    }
    
    if (self.pbUser != nil){
        // update sns user list
        PBGameUser_Builder* userBuilder = [PBGameUser builderWithPrototype:self.pbUser];
        [userBuilder clearSnsUsersList];
        [userBuilder addAllSnsUsers:newData];
        self.pbUser = [userBuilder build];
        [self storeUserData];
    }
    
    [builder release];
    [newData release];
}

- (void)saveSNSCredential:(int)type credential:(NSString*)credential
{
    if (credential == nil){
        return;
    }
    
    PPDebug(@"<saveSNSCredential> save SNS user, type(%d), credential(%@)", type, credential);
    
    NSArray* currentData = [[[self.pbUser snsCredentialsList] copy] autorelease]; //[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SNS_USER_DATA];
    NSMutableArray* newData = [[NSMutableArray alloc] init];
    if (currentData != nil){
        [newData addObjectsFromArray:currentData];
    }
    
    int index = 0;
    BOOL found = NO;
    PBSNSUserCredential* userFound = nil;
    for (PBSNSUserCredential* snsUser in newData){
        if (snsUser.type == type){
            found = YES;
            userFound = snsUser;
            break;
        }
        index ++;
    }
    
    // create an new user
    PBSNSUserCredential_Builder* builder = [[PBSNSUserCredential_Builder alloc] init];
    [builder setType:type];
    [builder setCredential:credential];
    
    PBSNSUserCredential* user = [builder build];
    if (found){
        [newData replaceObjectAtIndex:index withObject:user];
    }
    else{
        [newData addObject:user];
    }
    
    if (self.pbUser != nil){
        // update sns user list
        PBGameUser_Builder* userBuilder = [PBGameUser builderWithPrototype:self.pbUser];
        [userBuilder clearSnsCredentialsList];
        [userBuilder addAllSnsCredentials:newData];
        self.pbUser = [userBuilder build];
        [self storeUserData];
    }
    
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
    
    [self setUserId:userId];
    [self setNickName:nickName];
    [self setPassword:password];
    [self setAvatar:avatarURL];    
    if ([avatarURL length] > 0){
        [self avatarImage];
    }    
    [self setGender:gender];    
    [self setSinaId:loginId nickName:nickName];
    
    [self storeUserData];
    
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
//    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self setUserId:userId];
    [self setNickName:nickName];
    [self setPassword:password];
    [self setAvatar:avatarURL];    
    if ([avatarURL length] > 0){
        [self avatarImage];
    }    
    [self setGender:gender];    
    [self setQQId:loginId nickName:nickName accessToken:accessToken accessTokenSecret:accessTokenSecret];
    
    [self storeUserData];
}


- (void)saveUserId:(NSString*)userId
        facebookId:(NSString*)loginId
          password:(NSString*)password 
          nickName:(NSString*)nickName
         avatarURL:(NSString*)avatarURL 
            gender:(NSString *)gender
{
    PPDebug(@"Save userId(%@), loginId(%@), nickName(%@), avatarURL(%@)", userId, loginId, nickName, avatarURL);    
    
    [self setUserId:userId];
    [self setNickName:nickName];
    [self setPassword:password];
    [self setAvatar:avatarURL];    
    if ([avatarURL length] > 0){
        [self avatarImage];
    }    
    [self setGender:gender];    
    [self setFacebookId:loginId nickName:nickName];
    
    [self storeUserData];
}


- (void)setLanguageType:(LanguageType)type
{
    if (self.pbUser == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setGuessWordLanguage:type];
    self.pbUser = [builder build];
    
    [self storeUserData];

}

- (LanguageType)getLanguageType
{
    if (self.pbUser == nil || self.pbUser.guessWordLanguage == UnknowType){
        return ChineseType;
    }
    
    return self.pbUser.guessWordLanguage;    
}

- (LanguageType)getLanguageTypeFromOldStorage
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    LanguageType type = [userDefaults integerForKey:KEY_LANGUAGE];
    if (type == 0) {
        if ([LocaleUtils isChina] || [LocaleUtils isOtherChina] ||
            [LocaleUtils isChinese] || [LocaleUtils isTraditionalChinese]){
            type = ChineseType;
        }else{
            type = EnglishType;
        }
        [self setLanguageType:type];
    }
    return type;
}

- (BOOL)hasBindSNS:(int)snsType
{
    if (self.pbUser.snsUsersList == nil)
        return NO;
    
    for (PBSNSUser* snsUser in self.pbUser.snsUsersList){
        if (snsUser.type == snsType){
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)hasBindSinaWeibo
{
    return [self hasBindSNS:TYPE_SINA];

}
- (BOOL)hasBindQQWeibo
{
    return [self hasBindSNS:TYPE_QQ];
}
- (BOOL)hasBindFacebook
{
    return [self hasBindSNS:TYPE_FACEBOOK];
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
    [self setSNSUserData:TYPE_FACEBOOK snsId:facebookId nickName:nickName accessToken:nil accessTokenSecret:nil];
}

- (void)setSinaId:(NSString*)sinaId nickName:(NSString*)nickName
{
    [self setSNSUserData:TYPE_SINA snsId:sinaId nickName:nickName accessToken:nil accessTokenSecret:nil];
}

- (void)setQQId:(NSString*)qqId nickName:(NSString*)nickName accessToken:(NSString*)accessToken accessTokenSecret:(NSString*)accessTokenSecret
{
    [self setSNSUserData:TYPE_QQ snsId:qqId nickName:nickName accessToken:accessToken accessTokenSecret:accessTokenSecret];
}

- (NSString*)sinaId
{
    PBSNSUser* user = [self snsUserByType:TYPE_SINA];
    return [user userId];
}

- (NSString*)sinaIdFromOldStorage
{
    PBSNSUser* user = [self snsUserByType:TYPE_SINA];
    return [user userId];
}

- (NSString*)sinaNickName
{
    PBSNSUser* user = [self snsUserByType:TYPE_SINA];
    return [user nickName];
}

- (NSString*)sinaNickNameFromOldStorage
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

- (NSString*)qqIdFromOldStorage
{
    PBSNSUser* user = [self snsUserByType:TYPE_QQ];
    return [user userId];
}

- (NSString*)qqNickName
{
    PBSNSUser* user = [self snsUserByType:TYPE_QQ];
    return [user nickName];
}

- (NSString*)qqNickNameFromOldStorage
{
    PBSNSUser* user = [self snsUserByType:TYPE_QQ];
    return [user nickName];
}

- (NSString*)qqToken
{
    PBSNSUser* user = [self snsUserByType:TYPE_QQ];
    return [user accessToken];
}

- (NSString*)qqTokenFromOldStorage
{
    PBSNSUser* user = [self snsUserByType:TYPE_QQ];
    return [user accessToken];
}

- (NSString*)qqTokenSecret
{
    PBSNSUser* user = [self snsUserByType:TYPE_QQ];
    return [user accessTokenSecret];
}

- (NSString*)qqTokenSecretFromOldStorage
{
    PBSNSUser* user = [self snsUserByType:TYPE_QQ];
    return [user accessTokenSecret];
}

- (NSString*)facebookId
{
    PBSNSUser* user = [self snsUserByType:TYPE_FACEBOOK];
    return [user userId];
}

- (NSString*)facebookIdFromOldStorage
{
    PBSNSUser* user = [self snsUserByType:TYPE_FACEBOOK];
    return [user userId];
}

- (void)setXiaojiNumber:(NSString*)number
{    
    if (self.pbUser == nil)
        return;
    
    if (number == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setXiaojiNumber:number];
    self.pbUser = [builder build];
}

- (NSString*)xiaojiNumber
{
    return [self.pbUser xiaojiNumber];
}

- (BOOL)hasXiaojiNumber
{
//    return YES;
    return ([[self.pbUser xiaojiNumber] length] > 0);
}

- (void)setCanShakeXiaojiNumber:(BOOL)value
{
    if (self.pbUser == nil)
        return;            
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setCanShakeNumber:value];
    self.pbUser = [builder build];
}

- (void)setMaxShakeXiaojiNumberTimes:(int)value
{
    if (self.pbUser == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setShakeNumberTimes:value];
    self.pbUser = [builder build];
}



- (BOOL)canShakeXiaojiNumber
{
    
#ifdef DEBUG
    return YES;
#endif
    
    if ([self hasXiaojiNumber]){
        return NO;
    }
    
    if (_pbUser.canShakeNumber == NO){
        return NO;
    }
    
    if ([self shakeTimesLeft] > 0){
        return YES;
    }
    else{
        return NO;
    }
}

- (NSString*)shakeTimesKey
{
    NSString* key = [NSString stringWithFormat:@"SHAKE_TIMES_%@", self.userId];
    return key;    
}

- (NSString*)shakeNumberKey
{
    NSString* key = [NSString stringWithFormat:@"SHAKE_NUMBER_%@", self.userId];
    return key;
}

- (void)incShakeTimes
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    int currentShakeTimes = [[ud objectForKey:[self shakeTimesKey]] intValue];
    currentShakeTimes ++;
    [ud setInteger:currentShakeTimes forKey:[self shakeTimesKey]];
    [ud synchronize];
    
    PPDebug(@"<incShakeTimes> times=%d", currentShakeTimes);
}

- (int)currentShakeTimes
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    int currentShakeTimes = [[ud objectForKey:[self shakeTimesKey]] intValue];
    return currentShakeTimes;
}

- (int)shakeTimesLeft
{
#ifdef DEBUG
    return 99;
#endif
    
    int current = [self currentShakeTimes];
    if (_pbUser.shakeNumberTimes - current <= 0){
        return 0;
    }
    else{
        return _pbUser.shakeNumberTimes - current;
    }
}

- (PBGameUser*)toPBGameUser
{
    return self.pbUser;
}

- (PBGameUser*)toPBGameUserWithKeyValues:(NSArray*)keyValueArray
{
    if ([self hasUser] == NO)
        return nil;
    
    // return a PBGame User structure here
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
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
//#if DEBUG
//    return YES;
//#endif
    return [[BBSPermissionManager defaultManager] canCharge] && [[BBSPermissionManager defaultManager] canForbidUserIntoBlackUserList];
}

#define BBS_BG_IMAGE_KEY    @"bbs_bg.png"
#define BBS_BG_DIR          @"BBS_BG"

- (BOOL)setBbsBackground:(UIImage*)image
{
    if (image) {
        StorageManager* manager = [[[StorageManager alloc] initWithStoreType:StorageTypePersistent directoryName:BBS_BG_DIR] autorelease];
        return [manager saveImage:image forKey:BBS_BG_IMAGE_KEY];
    }
    
    return NO;
}

- (BOOL)resetBbsBackground
{
    StorageManager* manager = [[[StorageManager alloc] initWithStoreType:StorageTypePersistent directoryName:BBS_BG_DIR] autorelease];
    
    return [manager removeDataForKey:BBS_BG_IMAGE_KEY];
}
- (UIImage*)bbsBackground
{
    StorageManager* manager = [[[StorageManager alloc] initWithStoreType:StorageTypePersistent directoryName:BBS_BG_DIR] autorelease];
    return [manager imageForKey:BBS_BG_IMAGE_KEY];
}

#define DRAW_BG_IMAGE_KEY    @"draw_bg.png"
#define PAGE_BG_DIR          @"PAGE_BG"

- (BOOL)setPageBg:(UIImage *)bg forKey:(NSString *)key
{
    UIImage *image = bg;
    if (image && key) {
        CGSize size = image.size;
        size.width *= image.scale;
        size.height *= image.scale;
        CGFloat r = size.width / size.height;
        BOOL  needScale = NO;
        if (size.width > CGRectGetWidth([[UIScreen mainScreen] bounds])) {
            size.width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
            size.height = size.width / r;
            needScale = YES;
        }
        if(size.height > CGRectGetHeight([[UIScreen mainScreen] bounds])){
            size.height = CGRectGetHeight([[UIScreen mainScreen] bounds]);
            size.width = size.height * r;
            needScale = YES;
        }
        if (needScale) {
            image = [image scaleToSize:size];
        }
        StorageManager* manager = [[[StorageManager alloc] initWithStoreType:StorageTypePersistent directoryName:PAGE_BG_DIR] autorelease];
        return [manager saveImage:image forKey:key];
    }
    return NO;
}
- (BOOL)resetPageBgforKey:(NSString *)key
{
    StorageManager* manager = [[[StorageManager alloc] initWithStoreType:StorageTypePersistent directoryName:PAGE_BG_DIR] autorelease];
    
    return [manager removeDataForKey:key];
}
- (UIImage*)pageBgForKey:(NSString *)key
{
    StorageManager* manager = [[[StorageManager alloc] initWithStoreType:StorageTypePersistent directoryName:PAGE_BG_DIR] autorelease];
    return [manager imageForKey:key];
}


- (BOOL)setDrawBackground:(UIImage*)image
{
    [self setPageBg:image forKey:DRAW_BG_IMAGE_KEY];
    return YES;
}
- (BOOL)resetDrawBackground
{
    return [self resetPageBgforKey:DRAW_BG_IMAGE_KEY];
}
- (UIImage*)drawBackground
{
    return [self pageBgForKey:DRAW_BG_IMAGE_KEY];
}




- (int)deviceType
{
    return DEVICE_TYPE_IOS;
}

- (NSString*)deviceModel
{
    return [[UIDevice currentDevice] model];
}

- (BOOL)canFeatureDrawOpus
{
    return ([self.pbUser featureOpus] & CAN_REATURE_DRAW_OPUS);
}

- (NSString*)flowerUsedKey:(NSString*)contestId
{
    NSString* key = [NSString stringWithFormat:@"FLOWER_USED_CONTEST_%@_%@", self.userId, contestId];
    return key;
}

- (void)setUserContestFlowers:(NSString*)contestId flowers:(int)flowers
{
    NSString* key = [self flowerUsedKey:contestId];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:flowers forKey:key];
    PPDebug(@"<setUserContestFlowers> %@=%d", key, flowers);
}

- (int)flowersUsed:(NSString*)contestId
{
    NSString* key = [self flowerUsedKey:contestId];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* value = [userDefaults objectForKey:key];
    PPDebug(@"<flowersUsed> %@=%d", key, [value intValue]);
    return [value integerValue];
}

- (BOOL)isOldUserWithoutXiaoji
{
//#ifdef DEBUG
//    return YES;
//#endif
    
    if (_pbUser && [_pbUser.userId length] > 0 && [_pbUser.xiaojiNumber length] == 0 && [_pbUser canShakeNumber]){
        return YES;
    }
    else{
        return NO;
    }
}

- (int)getUserBadgeCountWithoutHomeBg
{
    if (_pbUser == nil){
        return 0;
    }
    
    if ([_pbUser.xiaojiNumber length] == 0 && [self isOldUserWithoutXiaoji] == NO){
        return 0;
    }
    
    int count = 0;
    
    //    if ([_pbUser.xiaojiNumber length] == 0 && [_pbUser canShakeNumber]){
    //        count ++;
    //    }
    
    if ([_pbUser.password length] == 0){
        count ++;
    }
    
    if ([_pbUser.email length] == 0){ // || [_pbUser emailVerifyStatus] == StatusNotVerified){
        count ++;
    }
    
    if ([self isVipExpire]){
        count ++;
    }
    
    return count;
}

- (int)getUserBadgeCount
{
    int count = [self getUserBadgeCountWithoutHomeBg];
    
    if ([self hasTrySetHomeBg] == NO){
        count ++;
    }
        
    return count;
}

- (int)emailVerifyStatus
{
    return _pbUser.emailVerifyStatus;
}

- (void)setEmailVerifyStatus:(int)status
{
    if (self.pbUser == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setEmailVerifyStatus:status];
    self.pbUser = [builder build];    
}

- (void)setTakeCoins:(int)value
{
    if (self.pbUser == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setTakeCoins:value];
    self.pbUser = [builder build];    
}

- (void)setBlockDevices:(NSArray*)devices
{
    if (self.pbUser == nil || [devices count] == 0)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder addAllBlockDeviceIds:devices];
    self.pbUser = [builder build];    
}

- (BOOL)canTakeCoins
{
    return _pbUser.takeCoins > 0;
}

- (int)getTakeCoins
{
    return self.pbUser.takeCoins;
}


- (BOOL)incAndCheckIsExceedMaxTakeNumber
{    
    NSString* key = @"CURRENT_TAKE_NUMBER_COUNT";
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    int count = [[userDefaults objectForKey:key] intValue];
    
    PPDebug(@"max take number count = %d", count);
    if (count >= [PPConfigManager maxTakeNumberCount]){
        return YES;
    }
    else{
        count ++;
        [userDefaults setInteger:count forKey:key];
        return NO;
    }
}

- (NSUserDefaults *)userDefaults
{
    if (self.userId) {
        return [[[NSUserDefaults alloc] initWithUser:self.userId] autorelease];
    }
    return nil;
}

#define SHOW_FULL_HOME_KEY @"SHOW_FULL_HOME_KEY"

- (BOOL)isShowFullHome
{
    if ([self hasUser] == NO){
        return NO;
    }
    
    if ([self isOldUserWithoutXiaoji]){
        return YES;
    }
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:SHOW_FULL_HOME_KEY];
}

- (void)enableShowFullHome
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:SHOW_FULL_HOME_KEY];
    [userDefaults synchronize];
}

#define LOCAL_USERS_KEY @"LOCAL_USERS_KEY"

+ (BOOL)updateHistoryUsers:(NSArray *)users
{
    PPDebug(@"<updateHistoryUsers> users count = %d",[users count]);
    
    NSMutableArray *dataList = [NSMutableArray array];
    @try {
        for (PBGameUser *user in users) {
            if ([user isKindOfClass:[PBGameUser class]]) {
                [dataList addObject:[user data]];
            }
        }
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:dataList forKey:LOCAL_USERS_KEY];
        [userDefaults synchronize];
    }
    @catch (NSException *exception) {
        return NO;
    }
    return YES;
}

+ (void)syncHistoryUsers
{
    if ([[self defaultManager] hasXiaojiNumber]) {
        [self addUserToHistoryList:[[self defaultManager] pbUser]];
    }
}

+ (NSMutableArray *)historyUsers
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *dataList = [userDefaults objectForKey:LOCAL_USERS_KEY];
    NSMutableArray *users = [NSMutableArray array];
    @try {
        for (NSData *data in dataList) {
            PBGameUser *user = [PBGameUser parseFromData:data];
            if (user) {
                [users addObject:user];
            }
        }
    }
    @catch (NSException *exception) {
        return nil;
    }
    PPDebug(@"get localUsers, user count = %d", [users count]);
    return users;
}
+ (BOOL)deleteUserFromHistoryList:(NSString *)userId
{
    PPDebug(@"<deleteUser>, uid = %@",userId);
    NSMutableArray *users = [self historyUsers];
    PBGameUser *user = nil;
    for (PBGameUser *u in users) {
        if ([u.userId isEqualToString:userId]){
            user = u;
            break;
        }
    }
    if (user) {
        [users removeObject:user];
        return [self updateHistoryUsers:users];
    }
    return YES;
}
+ (BOOL)addUserToHistoryList:(PBGameUser *)user
{
    PPDebug(@"<addUser>, uid = %@, nick = %@",user.userId,user.nickName);
    if (user == nil) {
        return NO;
    }
    NSMutableArray *users = [self historyUsers];
    NSInteger index = NSNotFound;
    NSInteger i = 0;
    for (PBGameUser *u in users) {
        if ([u.userId isEqualToString:user.userId]) {
            index = i;
            break;
        }
        i ++;
    }
    if (index == NSNotFound) {
        [users addObject:user];
    }else{
        [users replaceObjectAtIndex:index withObject:user];
    }
    [self updateHistoryUsers:users];    
    return YES;
}

+ (NSString*)genderByValue:(int)value
{
    if (value == 0){
        return @"m";
    }
    else if (value == 1){
        return @"f";
    }
    else{
        return @"f";
    }
        
}

#define TRY_SET_HOME_BG @"TRY_SET_HOME_BG"

- (BOOL)hasTrySetHomeBg
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    return [ud boolForKey:TRY_SET_HOME_BG];
}

- (BOOL)setTrySetHomeBg
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:YES forKey:TRY_SET_HOME_BG];
    [ud synchronize];
    return YES;
}

- (BOOL)isVip
{
    
//#ifdef DEBUG
//    return YES;
//#endif
    
    time_t now = time(0);
    if ([_pbUser vip] && [_pbUser vipExpireDate] > now){
        PPDebug(@"user is vip");
        return YES;
    }
    
    PPDebug(@"user is not vip");
    return NO;
}

- (int)finalVip
{
    if ([self isVip] == NO)
        return 0;
    
    return self.pbUser.vip;
}

- (void)setVip:(int)vip
{
    if (self.pbUser == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setVip:vip];
    self.pbUser = [builder build];    
}

- (void)setVipExpireDate:(int)vipExpireDate
{
    if (self.pbUser == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setVipExpireDate:vipExpireDate];
    self.pbUser = [builder build];
}

- (BOOL)isVipExpire
{
    time_t now = time(0);
    if (_pbUser.vip && _pbUser.vipExpireDate < now){
        return YES;
    }
    else{
        return NO;
    }
}

- (void)setVipLastPayDate:(int)vipLastPayDate
{
    if (self.pbUser == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder setVipLastPayDate:vipLastPayDate];
    self.pbUser = [builder build];
}

- (void)setOffGroupIds:(NSArray*)offGroupIds
{
    if (self.pbUser == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    [builder clearOffGroupIdsList];
    if (offGroupIds){
        [builder addAllOffGroupIds:offGroupIds];
    }
    
    self.pbUser = [builder build];
}

#define KEY_BUY_VIP_USER @"KEY_BUY_VIP_USER"

- (int)buyVipUserCount
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    return [[ud objectForKey:KEY_BUY_VIP_USER] integerValue];
}

- (void)setBuyVipUserCount:(int)value
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:value forKey:KEY_BUY_VIP_USER];
    [ud synchronize];
}

- (BOOL)hasAwardApp:(NSString*)appId
{
    for (NSString* value in self.pbUser.awardAppsList){
        if ([value isEqualToString:appId]){
            return YES;
        }
    }
    
    return NO;
}

- (void)setUserGroupNotice:(NSString*)groupId status:(int)status
{
    if (self.pbUser == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    
    NSMutableArray* offGroupIds = [NSMutableArray array];
    if ([builder offGroupIdsList]){
        [offGroupIds addObjectsFromArray:[builder offGroupIdsList]];
    }
    
    if (status){
        [offGroupIds removeObject:groupId];
    }
    else{
        if ([offGroupIds indexOfObject:groupId] == NSNotFound){
            [offGroupIds addObject:groupId];
        }
    }
    
    [builder clearOffGroupIdsList];
    [builder addAllOffGroupIds:offGroupIds];
    self.pbUser = [builder build];
}

- (BOOL)isDisableGroupNotice:(NSString*)groupId
{
    if (groupId == nil){
        return NO;
    }
    
    if ([self.pbUser.offGroupIdsList indexOfObject:groupId] != NSNotFound){
        return YES;
    }
    else{
        return NO;
    }
}

- (BOOL)canBlackUser
{
    if ([self isSuperUser]){
        return YES;
    }
    
    return [_pbUser.permissionsList containsObject:PERMISSION_BLACK_USER];
}

- (void)setUserPermissions:(NSArray*)persmissions
{
    if (self.pbUser == nil)
        return;
    
    PBGameUser_Builder* builder = [PBGameUser builderWithPrototype:self.pbUser];
    
    NSMutableArray* permissions = [NSMutableArray array];
    if ([builder permissionsList]){
        [permissions addObjectsFromArray:[builder permissionsList]];
    }
    
    [builder clearPermissionsList];
    [builder addAllPermissions:permissions];
    self.pbUser = [builder build];
}

@end
