//
//  GameSessionUser.m
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameSessionUser.h"
#import "GameBasic.pb.h"

@implementation GameSessionUser

@synthesize userId = _userId;
@synthesize nickName = _nickName;
@synthesize userAvatar = _userAvatar;
@synthesize gender = _gender;

- (void)dealloc
{
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
    
    return user;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"[userId=%@, nickName=%@, avatar=%@, gender=%d]",
            _userId, _nickName, _userAvatar, _gender];            
}

@end
