//
//  Feed.m
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Feed.h"
#import "TimeUtils.h"
#import "PPDebug.h"
#import "UserManager.h"
#import "FeedManager.h"
#import "ShareImageManager.h"
#import "ItemType.h"

@implementation Feed

@synthesize opusStatus = _opusStatus;
@synthesize feedId = _feedId;
@synthesize feedType = _feedType;
@synthesize createDate = _createDate;
@synthesize feedUser = _feedUser;
@synthesize desc = _desc;

- (void)dealloc
{
    PPRelease(_feedId);
    PPRelease(_feedUser);
    PPRelease(_createDate);
    PPRelease(_desc);
    [super dealloc];
}



- (id)initWithPBFeed:(PBFeed *)pbFeed
{
    self = [super init];
    if(self){
        self.feedId = [pbFeed feedId];
        self.feedType = [pbFeed actionType];
        self.createDate = [NSDate dateWithTimeIntervalSince1970:pbFeed.createDate];
        self.opusStatus = [pbFeed opusStatus];        
        self.feedUser = [FeedUser feedUserWithUserId:pbFeed.userId 
                                            nickName:pbFeed.nickName 
                                              avatar:pbFeed.avatar 
                                              gender:pbFeed.gender
                                           signature:pbFeed.signature];
        
    }
    return self;
}

- (id)initWithFeedId:(NSString *)feedId 
            feedType:(FeedType)feedType 
          opusStatus:(OpusStatus)status 
          createData:(NSDate *)createDate 
            feedUser:(FeedUser*)feedUser
{
    self = [super init];
    if(self){
        self.feedId = feedId;
        self.feedType = feedType;
        self.createDate = createDate;
        self.opusStatus = status;
        self.feedUser = feedUser;
    }
    return self;
}

#define KEY_ID @"ID"
#define KEY_TYPE @"TYPE"
#define KEY_CREATE_DATE @"CREATE_DATE"
#define KEY_USER @"USER"
#define KEY_STATUS @"STATUS"
#define KEY_DESC @"DESC"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.feedId = [aDecoder decodeObjectForKey:KEY_ID];
        self.feedType = [aDecoder decodeIntegerForKey:KEY_TYPE];
        self.createDate = [aDecoder decodeObjectForKey:KEY_CREATE_DATE];
        self.feedUser = [aDecoder decodeObjectForKey:KEY_USER];
        self.opusStatus = [aDecoder decodeIntegerForKey:KEY_STATUS];
        self.desc = [aDecoder decodeObjectForKey:KEY_DESC];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.feedId forKey:KEY_ID];
    [aCoder encodeInteger:self.feedType forKey:KEY_TYPE];
    [aCoder encodeObject:self.createDate forKey:KEY_CREATE_DATE];
    [aCoder encodeObject:self.feedUser forKey:KEY_USER];
    [aCoder encodeInteger:self.opusStatus forKey:KEY_STATUS];
    [aCoder encodeObject:self.desc forKey:KEY_DESC];
}

- (BOOL)isMyFeed
{
    UserManager *defaultManager  = [UserManager defaultManager];
    return [defaultManager isMe:self.feedUser.userId];    
}


- (BOOL) isDrawType
{
    return self.feedType == FeedTypeDraw || 
    self.feedType == FeedTypeDrawToUser;
}

- (BOOL)isGuessType
{
    return self.feedType == FeedTypeGuess;
}
- (BOOL)isCommentType
{
    return self.feedType == FeedTypeComment ||
    self.feedType == ItemTypeFlower || 
    self.feedType == ItemTypeTomato || 
    self.feedType == FeedTypeGuess;
}

//need to override
- (void)updateDesc
{

}

- (FeedUser *)author
{
    return self.feedUser;
}

- (NSString *)desc
{
    if (_desc == nil) {
        [self updateDesc];
    }
    return _desc;
}

- (BOOL)showAnswer
{
    return NO;
}
@end
