//
//  MyFriend.m
//  Draw
//
//  Created by  on 12-10-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


//Just use the class replace the Friend
#import "MyFriend.h"
#import "GameNetworkConstants.h"
#import "TimeUtils.h"
#import "UserManager.h"

@implementation MyFriend

@synthesize friendUserId = _friendUserId;
@synthesize nickName = _nickName;
@synthesize avatar = _avatar;
@synthesize gender = _gender;
@synthesize sinaId = _sinaId;
@synthesize qqId = _qqId;
@synthesize facebookId = _facebookId;
@synthesize sinaNick = _sinaNick;
@synthesize qqNick = _qqNick;
@synthesize facebookNick = _facebookNick;
@synthesize createDate = _createDate;
@synthesize lastModifiedDate = _lastModifiedDate;
@synthesize location = _location;

@synthesize level = _level;
@synthesize type = _type;
@synthesize onlineStatus = _onlineStatus;
@synthesize relation = _relation; 
@synthesize coins = _coins;




- (id)initWithDict:(NSDictionary *)dict
{
    self = [super  init];
    if (self) {
        self.friendUserId = [dict objectForKey:PARA_USERID];
        self.nickName = [dict objectForKey:PARA_NICKNAME];
        self.avatar = [dict objectForKey:PARA_AVATAR];     
        self.gender = [dict objectForKey:PARA_GENDER];
        self.sinaId = [dict objectForKey:PARA_SINA_ID];
        self.qqId = [dict objectForKey:PARA_QQ_ID];
        self.facebookId = [dict objectForKey:PARA_FACEBOOKID];
        self.sinaNick = [dict objectForKey:PARA_SINA_NICKNAME];
        self.qqNick = [dict objectForKey:PARA_QQ_NICKNAME];
        self.facebookNick = [dict objectForKey:PARA_FACEBOOK_NICKNAME];
        self.type =[[dict objectForKey:PARA_FRIENDSTYPE] intValue];
        self.location = [dict objectForKey:PARA_LOCATION];
        self.relation = [[dict objectForKey:PARA_RELATION] intValue];
        self.level = [[dict objectForKey:PARA_LEVEL] intValue]; 
        self.coins = [[dict objectForKey:PARA_USER_COINS] longValue];
        self.memo = [dict objectForKey:PARA_MEMO];
        if (self.level < 1) {
            self.level = 1;
        }
    }
    return self;
}
+ (id)friendWithDict:(NSDictionary *)dict
{
    return [[[MyFriend alloc] initWithDict:dict] autorelease];
}
- (id)initWithFid:(NSString *)fid 
         nickName:(NSString *)nickName
           avatar:(NSString *)avatar
           gender:(NSString *)gender 
            level:(NSInteger)level
{
    self = [super init];
    if (self) {
        self.friendUserId = fid;
        self.nickName = nickName;
        self.avatar = avatar;
        self.gender = gender;
        self.level = level;
    }
    return self;
}

+ (id)friendWithFid:(NSString *)fid 
           nickName:(NSString *)nickName
             avatar:(NSString *)avatar
             gender:(NSString *)gender     
              level:(NSInteger)level
{
    return [[[MyFriend alloc] initWithFid:fid 
                                 nickName:nickName 
                                   avatar:avatar 
                                   gender:gender 
                                    level:1] autorelease];
}
+ (id)myself
{
    return [MyFriend friendWithFid:[[UserManager defaultManager] userId] 
                          nickName:[[UserManager defaultManager] nickName]
                            avatar:[[UserManager defaultManager] avatarURL]
                            gender:[[UserManager defaultManager] gender] 
                             level:1];
}


- (NSString *)friendNick;
{
    if ([self.memo length] > 0){
        return self.memo;
    }
    
    if ([self.nickName length] != 0) {
        return [self nickName];
    }
    if ([self.sinaNick length] != 0) {
        return [self sinaNick];
    }
    
    if ([self.qqNick length] != 0) {
        return [self qqNick];
    }
    
    if ([self.facebookNick length] != 0) {
        return [self facebookNick];
    }
    return @"";
}

- (BOOL)hasFollow
{
    return [MyFriend hasFollow:self.relation];
}

- (BOOL)hasBlack
{
    return [MyFriend hasBlack:self.relation];
}

- (BOOL)isMyFan
{
    return [MyFriend isMyFan:self.relation];
}
- (BOOL)isMale
{
    return [self.gender isEqualToString:@"m"];
}

- (BOOL)isSinaUser
{
    if ([self.sinaId length] != 0 || [self.sinaNick length] != 0) {
        return YES;
    }
    return NO;
}
- (BOOL)isQQUser
{
    if ([self.qqId length] != 0 || [self.qqNick length] != 0) {
        return YES;
    }
    return NO;
}
- (BOOL)isFacebookUser
{
    if ([self.facebookId length] != 0 || [self.facebookNick length] != 0) {
        return YES;
    }
    return NO;    
}


- (NSString *)genderDesc
{
    if ([self isMale]) {
        return NSLS(@"kMale");
    }
    return NSLS(@"kFemale");
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[friendUserId = %@,nickName = %@,avatar = %@,gender = %@,sinaId = %@,qqId = %@,facebookId = %@,sinaNick = %@,qqNick = %@,facebookNick = %@,createDate = %@,lastModifiedDate = %@,location = %@,level = %d,type = %d,onlineStatus = %d,relation = %d]",
            
            self.friendUserId,
            self.nickName,
            self.avatar,
            self.gender,
            self.sinaId,
            self.qqId,
            self.facebookId,
            self.sinaNick,
            self.qqNick,
            self.facebookNick,
            self.createDate,
            self.lastModifiedDate,
            self.location,
            self.level,
            self.type,
            self.onlineStatus,
            self.relation];
}

- (void)dealloc
{
    PPRelease(_friendUserId);
    PPRelease(_nickName);
    PPRelease(_avatar);
    PPRelease(_gender);
    PPRelease(_sinaId);
    PPRelease(_qqId);
    PPRelease(_facebookId);
    PPRelease(_sinaNick);
    PPRelease(_qqNick);
    PPRelease(_facebookNick);
    PPRelease(_createDate);
    PPRelease(_lastModifiedDate);
    PPRelease(_location);
    PPRelease(_memo);
    
    [super dealloc];
}

+ (BOOL)hasFollow:(RelationType)type
{
    return (type & RelationTypeFollow) != 0;
}

+ (BOOL)hasBlack:(RelationType)type
{
    return (type & RelationTypeBlack) != 0;
}

+ (BOOL)isMyFan:(RelationType)type
{
    return (type & RelationTypeFan) != 0;
}

//- (NSString*)displayName
//{
//    if ([self.memo length] > 0){
//        return self.memo;
//    }
//    
//    return self.nickName;
//}

@end
