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

- (void)dealloc
{
    [_roomId release];
    [_roomName release];
    [_gameServerAddress release];
    [_gameServerPort release];
    [_password release];
    [_createDate release];
    [_expireDate release];
    [_userList release];
    [_creator release];
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

- (NSString *)description
{
    NSString *text = @"";
    NSString *prefix = @"Room[ ";
    NSString *suffux = @" ]";

    text = [self string:text appendKey:@"RoomId" value:self.roomId];
    text = [self string:text appendKey:@"RoomName" value:self.roomName];
    text = [self string:text appendKey:@"password" value:self.password];
    text = [self string:text appendKey:@"address" value:self.gameServerAddress];
    text = [self string:text appendKey:@"port" value:self.gameServerPort];
    text = [self string:text appendKey:@"Creator" value:[self.creator description]];
    text = [self string:text appendKey:@"userList" value:[self.userList description]];
    
    return [NSString stringWithFormat:@"%@%@%@",prefix,text,suffux];
}

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
    [_userId release];
    [_nickName release];
    [_gender release];
    [_avatar release];
    [_lastPlayDate release];
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

- (NSString *)description
{
    NSString *text = @"";
    NSString *prefix = @"RoomUser[ ";
    NSString *suffux = @" ]";
    
    text = [self string:text appendKey:@"userId" value:self.userId];
    text = [self string:text appendKey:@"nickname" value:self.nickName];
    text = [self string:text appendKey:@"gender" value:self.gender];
    text = [self string:text appendKey:@"avatar" value:self.avatar];
    
    return [NSString stringWithFormat:@"%@%@%@",prefix,text,suffux];
}

- (BOOL)isFemale
{
    if ([self.gender isEqualToString:@"f"] || [self.gender isEqualToString:@"F"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isMe
{
    return [self.userId isEqualToString:[[UserManager defaultManager] userId]];
}
@end