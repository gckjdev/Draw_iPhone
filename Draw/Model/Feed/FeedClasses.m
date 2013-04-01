//
//  FeedClasses.m
//  Draw
//
//  Created by  on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedClasses.h"
#import "PPDebug.h"
#import "GameMessage.pb.h"
#import "GameBasic.pb.h"


@implementation FeedUser
@synthesize userId = _userId;
@synthesize nickName = _nickName;
@synthesize avatar = _avatar;
@synthesize gender = _gender;


- (void)dealloc
{
    PPRelease(_signature);
    PPRelease(_userId);
    PPRelease(_nickName);
    PPRelease(_avatar);
    [super dealloc];
}

- (id)initWithUserId:(NSString *)userId 
            nickName:(NSString *)nickName 
              avatar:(NSString *)avatar 
              gender:(BOOL)gender
           signature:(NSString*)signature
{
    self = [super init];
    if (self) {
        self.userId = userId;
        self.nickName = nickName;
        self.avatar = avatar;
        self.gender = gender;
        self.signature = signature;
    }
    return self;
}

#define KEY_UID @"UID"
#define KEY_NICK @"NICK"
#define KEY_AVATAR @"AVATAR"
#define KEY_GENDER @"GENDER"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.userId = [aDecoder decodeObjectForKey:KEY_UID];
        self.nickName = [aDecoder decodeObjectForKey:KEY_NICK];
        self.avatar = [aDecoder decodeObjectForKey:KEY_AVATAR];
        self.gender = [aDecoder decodeBoolForKey:KEY_GENDER];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_userId forKey:KEY_UID];
    [aCoder encodeObject:_nickName forKey:KEY_NICK];
    [aCoder encodeObject:_avatar forKey:KEY_AVATAR];
    [aCoder encodeBool:_gender forKey:KEY_GENDER];
}

+ (FeedUser *)feedUserWithUserId:(NSString *)userId 
                        nickName:(NSString *)nickName 
                          avatar:(NSString *)avatar 
                          gender:(BOOL)gender
                       signature:(NSString*)signature
{
    return [[[FeedUser alloc] 
             initWithUserId:userId 
             nickName:nickName 
             avatar:avatar 
             gender:gender
             signature:signature]
            autorelease];
}

- (NSString *)genderString
{
    return _gender ? @"m" : @"f";
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

#define KEY_TYPE @"TYPE"
#define KEY_TIMES @"TIMES"
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_type forKey:KEY_TYPE];
    [aCoder encodeInteger:_times forKey:KEY_TIMES];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.type = [aDecoder decodeIntegerForKey:KEY_TYPE];
        self.times = [aDecoder decodeIntegerForKey:KEY_TIMES];
    }
    return self;
}


- (id)initWithPbFeedTimes:(PBFeedTimes *)pbFeedTimes
{
    self = [super init];
    if (self) {
        self.type = [pbFeedTimes type];
        self.times = [pbFeedTimes value];
    }
    return self;
    
}

+ (FeedTimes *)feedTimesWithPbFeedTimes:(PBFeedTimes *)pbFeedTimes
{
    return [[[FeedTimes alloc] initWithPbFeedTimes:pbFeedTimes]autorelease];
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
