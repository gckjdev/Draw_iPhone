//
//  Room.m
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Room.h"
#import "UserManager.h"

@implementation Room

@synthesize roomId = _roomId;
@synthesize gameServerAddress = _gameServerAddress;
@synthesize gameServerPort = _gameServerPort;
@synthesize roomName = _roomName;
@synthesize password = _password;
@synthesize status = _status;
@synthesize createDate = _createDate;
@synthesize expireDate = _expireDate;
@synthesize creator = _creator;
@synthesize userList = _userList;
@synthesize myStatus = _myStatus;
- (void)dealloc
{
    PPRelease(_roomId);
    PPRelease(_roomName);
    PPRelease(_gameServerAddress);
    PPRelease(_password);
    PPRelease(_createDate);
    PPRelease(_expireDate);
    PPRelease(_userList);
    PPRelease(_creator);
    [super dealloc];
}


- (NSString *)string:(NSString *)string appendKey:(NSString *)key value:(NSString *)value
{
    NSString* p = key;
	NSString* v = value;
	if (p == nil)
		p = @"";
	if (v == nil)
		v = @"";
	return [string stringByAppendingFormat:@",%@=%@", p, v];

}

- (NSMutableArray *)userListForStatus:(RoomUserStatus)stat
{
    NSMutableArray *array = [[[NSMutableArray alloc] init]autorelease];
    for (RoomUser *user in self.userList) {
        if (user.status == stat) {
            [array addObject:user];
        }
    }
    if (self.creator.status == stat) {
        [array addObject:self.creator];
    }
    return array;
}


- (NSArray *)playingUserList
{
    return [self userListForStatus:UserPlaying];
}


- (NSString *)description
{
    NSString *text = @"";
    NSString *prefix = @"Room[ ";
    NSString *suffux = @" ]";

    text = [self string:text appendKey:@"RoomId" value:self.roomId];
    text = [self string:text appendKey:@"RoomName" value:self.roomName];
    text = [self string:text appendKey:@"password" value:self.password];
    text = [self string:text appendKey:@"address" value:self.gameServerAddress];

    text = [self string:text appendKey:@"port" value:[NSString stringWithFormat:@"%d",self.gameServerPort]];
    
    text = [self string:text appendKey:@"Creator" value:[self.creator description]];
    text = [self string:text appendKey:@"userList" value:[self.userList description]];
    
    return [NSString stringWithFormat:@"%@%@%@",prefix,text,suffux];
}

- (BOOL)isMeCreator
{
    if ([[UserManager defaultManager] isMe:self.creator.userId]) {
        return YES;
    }
    return NO;
}

//- (RoomUser *)meInUserList
//{
//    for (RoomUser *user in self.userList) {
//        if ([[UserManager defaultManager] isMe:user.userId]) {
//            return user;
//        }
//    }
//    return nil;
//}
//
//- (RoomUserStatus)myStatus
//{
//    RoomUser *user = [self meInUserList];
//    if (user) {
//        return user.status;
//    }
//    return UserUnInvited;
//}
@end


@implementation RoomUser

@synthesize userId = _userId;
@synthesize nickName = _nickName;
@synthesize gender = _gender;
@synthesize avatar = _avatar;
@synthesize playTimes = _playTimes;
@synthesize lastPlayDate = _lastPlayDate;
@synthesize status = _status;

- (void)dealloc
{
    PPRelease(_userId);
    PPRelease(_nickName);
    PPRelease(_gender);
    PPRelease(_avatar);
    PPRelease(_lastPlayDate);
    [super dealloc];
}


- (id)initWithFriend:(MyFriend *)aFriend
              status:(RoomUserStatus)status
{
    self = [super init];
    if (self) {
        self.userId = aFriend.friendUserId;
        self.nickName = aFriend.friendNick;
        self.avatar = aFriend.avatar;
        self.gender = aFriend.gender;
        self.status = status;
    }
    return self;
}

- (NSString *)string:(NSString *)string appendKey:(NSString *)key value:(NSString *)value
{
    NSString* p = key;
	NSString* v = value;
	if (p == nil)
		p = @"";
	if (v == nil)
		v = @"";
	return [string stringByAppendingFormat:@",%@=%@", p, v];
    
}

- (NSString *)description
{
    NSString *text = @"";
    NSString *prefix = @"RoomUser[ ";
    NSString *suffux = @" ]";
    
    text = [self string:text appendKey:@"userId" value:self.userId];
    text = [self string:text appendKey:@"nickname" value:self.nickName];
    text = [self string:text appendKey:@"gender" value:self.gender];
    text = [self string:text appendKey:@"avatar" value:self.avatar];
    text = [self string:text appendKey:@"status" value:[NSString stringWithFormat:@"%d",self.status]];
    
    return [NSString stringWithFormat:@"%@%@%@",prefix,text,suffux];
}

- (BOOL)isMale
{
    if ([self.gender isEqualToString:@"m"] || [self.gender isEqualToString:@"M"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isMe
{
    return [self.userId isEqualToString:[[UserManager defaultManager] userId]];
}
@end