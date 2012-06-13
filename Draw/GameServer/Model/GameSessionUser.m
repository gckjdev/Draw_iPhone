//
//  GameSessionUser.m
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameSessionUser.h"
#import "GameBasic.pb.h"
#import "SNSConstants.h"

@implementation GameSessionUser

@synthesize userId = _userId;
@synthesize nickName = _nickName;
@synthesize userAvatar = _userAvatar;
@synthesize gender = _gender;
@synthesize snsUserData = _snsUserData;
@synthesize location = _location;
@synthesize level = _level;

- (void)dealloc
{
    [_location release];
    [_snsUserData release];
    [_userId release];
    [_nickName release];
    [_userAvatar release];
    [super dealloc];
}

+ (GameSessionUser*)fromPBUser:(PBGameUser*)pbUser
{
    GameSessionUser* user = [[[GameSessionUser alloc] init] autorelease];
    user.userId = [pbUser userId];
    user.nickName = [pbUser nickName];
    user.userAvatar = [pbUser avatar]; 
    user.gender = [pbUser gender];
    user.snsUserData = [pbUser snsUsersList];
    user.location = [pbUser location];
    user.level = [pbUser userLevel];
    return user;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"[userId=%@, nickName=%@, avatar=%@, gender=%d, location=%@, userLevel=%d, snsUser=%@]",
            _userId, _nickName, _userAvatar, _gender, _location, _level, [_snsUserData description]];            
}

- (BOOL)isBindSNSByType:(int)type
{
    for (PBSNSUser* snsUser in _snsUserData){
        if ([snsUser type] == type){
            return YES;
        }
    }
    
    return NO;    
}

- (BOOL)isBindSina
{
    return [self isBindSNSByType:TYPE_SINA];
}

- (BOOL)isBindQQ
{
    return [self isBindSNSByType:TYPE_QQ];    
}

- (BOOL)isBindFacebook
{
    return [self isBindSNSByType:TYPE_FACEBOOK];        
}

@end
