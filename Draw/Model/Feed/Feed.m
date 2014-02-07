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
    PPRelease(_pbFeed);
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
        self.pbFeed = pbFeed;
        self.categoryType = pbFeed.category;
        
        self.feedUser = [FeedUser feedUserWithUserId:pbFeed.userId
                                            nickName:pbFeed.nickName 
                                              avatar:pbFeed.avatar 
                                              gender:pbFeed.gender
                                           signature:pbFeed.signature
                                                 vip:pbFeed.vip];
        
        
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
#define KEY_CATEGORY_TYPE @"CATEGORY_TYPE"

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
        self.categoryType = [[aDecoder decodeObjectForKey:KEY_CATEGORY_TYPE] intValue];

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
    [aCoder encodeObject:@(self.categoryType) forKey:KEY_CATEGORY_TYPE];

}

- (BOOL)isMyFeed
{
    UserManager *defaultManager  = [UserManager defaultManager];
    return [defaultManager isMe:self.feedUser.userId];    
}


// TODO check this impact on SING
- (BOOL) isOpusType
{
    return (self.feedType == FeedTypeDraw) || (self.feedType == FeedTypeDrawToUser)
    || (self.feedType == FeedTypeSing) || (self.feedType == FeedTypeSingToUser)
    || (self.feedType == FeedTypeSingContest) || (self.feedType == FeedTypeDrawToContest);
}

- (BOOL)isDrawCategory
{
    return (self.categoryType == PBOpusCategoryTypeDrawCategory);
}

- (BOOL)isSingCategory
{
    return (self.categoryType == PBOpusCategoryTypeSingCategory);
}


- (BOOL)isGuessType
{
    return self.feedType == FeedTypeGuess;
}
- (BOOL)isCommentType
{
    return IS_OPUS_ACTION(self.feedType);
    
//    return self.feedType == FeedTypeComment ||
//    self.feedType == ItemTypeFlower || 
//    self.feedType == ItemTypeTomato || 
//    self.feedType == FeedTypeGuess ||
//    self.feedType == FeedTypeContestComment;
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


- (NSString*)displayText
{
    return self.desc;
}

@end
