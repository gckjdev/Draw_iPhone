//
//  TopPlayer.m
//  Draw
//
//  Created by  on 12-9-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopPlayer.h"
#import "GameNetworkConstants.h"

@implementation TopPlayer

@synthesize userId = _userId;
@synthesize nickName = _nickName;
@synthesize avatar = _avatar;
@synthesize level = _level;
@synthesize opusCount = _opusCount;
@synthesize exp = _exp;
@synthesize gender = _gender;

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.nickName = [dict objectForKey:PARA_NICKNAME];
        self.avatar = [dict objectForKey:PARA_AVATAR];
        self.userId = [dict objectForKey:PARA_USERID];
        self.level = [[dict objectForKey:PARA_LEVEL] integerValue];    
        NSString *userGender = [dict objectForKey:PARA_GENDER];
        self.gender = [userGender isEqualToString:@"m"];
        self.opusCount = [[dict objectForKey:PARA_OPUS_COUNT] integerValue];        
    }
    return self;
}

@end
