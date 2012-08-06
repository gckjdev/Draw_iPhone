//
//  FeedClasses.m
//  Draw
//
//  Created by  on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedClasses.h"
#import "PPDebug.h"

@implementation FeedUser
@synthesize userId = _userId;
@synthesize nickName = _nickName;
@synthesize avatar = _avatar;
@synthesize gender = _gender;


- (void)dealloc
{
    PPRelease(_userId);
    PPRelease(_nickName);
    PPRelease(_avatar);
    [super dealloc];
}

- (id)initWithUserId:(NSString *)userId 
            nickName:(NSString *)nickName 
              avatar:(NSString *)avatar 
              gender:(BOOL)gender
{
    self = [super init];
    if (self) {
        self.userId = userId;
        self.nickName = nickName;
        self.avatar = avatar;
        self.gender = gender;        
    }
    return self;
}

+ (FeedUser *)feedUserWithUserId:(NSString *)userId 
                        nickName:(NSString *)nickName 
                          avatar:(NSString *)avatar 
                          gender:(BOOL)gender
{
    return [[[FeedUser alloc] 
             initWithUserId:userId 
             nickName:nickName 
             avatar:avatar 
             gender:gender] 
            autorelease];
}


- (NSString *)description
{
    return [NSString stringWithFormat:  
            @"feed user = [userId = %@, nickName = %@, avatar = %@, gender = %d]",
            _userId,_nickName,_avatar,_gender];
}

@end

@implementation FeedTimes
@synthesize times = _times;
@synthesize type = _type;

- (id)initWithType:(NSInteger)type times:(NSInteger)times
{
    self = [super init];
    if (self) {
        self.type = type;
        self.times = times;
    }
    return self;
}

+ (FeedTimes *)feedTimesWithType:(NSInteger)type times:(NSInteger)times
{
    return [[[FeedTimes alloc] initWithType:type times:times] autorelease];
}

-(void)dealloc
{
    [super dealloc];
}

@end
