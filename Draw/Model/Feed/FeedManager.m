//
//  FeedManager.m
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedManager.h"
#import "PPDebug.h"
#import "UserManager.h"
#import "Draw.h"
#import "FileUtil.h"
#import "ItemType.h"

FeedManager *_staticFeedManager = nil;

#define FeedKeyMy @"FeedKeyMy"
#define FeedKeyAll @"FeedKeyAll"
#define FeedKeyHot @"FeedKeyHot"
#define FeedKeyLatest @"FeedKeyLatest"

@implementation FeedManager


- (void)addListForKey:(NSString *)key
{
    NSMutableArray *list = [NSMutableArray array];
    [_dataMap setObject:list forKey:key];
}


- (NSString *)keyForType:(FeedListType )type
{
    if (type == FeedListTypeMy) {
        return FeedKeyMy;
    }
    if (type == FeedListTypeAll) {
        return FeedKeyAll;
    }
    if (type == FeedListTypeHot) {
        return FeedKeyHot;
    }else if(type == FeedListTypeLatest){
        return FeedKeyLatest;
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        _dataMap = [[NSMutableDictionary alloc] init];
        [self addListForKey:FeedKeyMy];
        [self addListForKey:FeedKeyAll];
        [self addListForKey:FeedKeyHot];
        [self addListForKey:FeedKeyLatest];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_dataMap);
    [super dealloc];
}


- (void)cleanData
{
    [_dataMap removeAllObjects];
}

+ (FeedManager *)defaultManager
{
    if (_staticFeedManager == nil) {
        _staticFeedManager = [[FeedManager alloc] init];
    }
    return _staticFeedManager;
}

+ (void)releaseDefaultManager
{
    [_staticFeedManager cleanData];
    [_staticFeedManager release];
    _staticFeedManager = nil;
}

- (NSMutableArray *)feedListForType:(FeedListType)type
{
    NSString *key = [self keyForType:type];
    if (key) {
        return [_dataMap objectForKey:key];
    }
    return nil;
}
- (void)setFeedList:(NSMutableArray *)feedList forType:(FeedListType)type
{
    NSString *key = [self keyForType:type];
    if (key) {
        if (feedList) {
            [_dataMap setObject:feedList forKey:key];            
        }else{
            //if the list is nil;
            NSMutableArray *list = [self feedListForType:type];
            [list removeAllObjects];
        }
    }
}
- (void)addFeedList:(NSArray *)feedList forType:(FeedListType)type
{
    if ([feedList count] == 0) {
        return;
    }
    NSMutableArray *list = [self feedListForType:type];
    if (list) {
        [list addObjectsFromArray:feedList];
    }
}


+ (Feed *)parsePbFeed:(PBFeed *)pbFeed
{
    Feed *feed = nil;
    switch (pbFeed.actionType) {
        case FeedTypeDraw:
            feed = [[[DrawFeed alloc] initWithPBFeed:pbFeed] autorelease];
            break;
        case FeedTypeGuess:
            feed = [[[GuessFeed alloc] initWithPBFeed:pbFeed] autorelease];
            break;
        case FeedTypeDrawToUser:
            feed = [[[DrawToUserFeed alloc] initWithPBFeed:pbFeed] autorelease];
            break;                
        case FeedTypeDrawToContest:
            feed = [[[ContestFeed alloc] initWithPBFeed:pbFeed] autorelease];
            break;
        default:
            break;
    }
    return feed;
}
#pragma mark - parse pbfeed list
+ (NSArray *)parsePbFeedList:(NSArray *)pbFeedList
{
    if ([pbFeedList count] == 0) {
        return nil;
    }
    NSMutableArray *list = [NSMutableArray array];
    for (PBFeed *pbFeed in pbFeedList) {
        Feed *feed = [FeedManager parsePbFeed:pbFeed];
        if (feed) {
            [list addObject:feed];
        }
    }
    return list;
}

+ (NSArray *)parsePbCommentFeedList:(NSArray *)pbFeedList
{
    if ([pbFeedList count] == 0) {
        return nil;
    }
    NSMutableArray *list = [NSMutableArray array];
    for (PBFeed *pbFeed in pbFeedList) {
        Feed *feed = [[CommentFeed alloc] initWithPBFeed:pbFeed];
        if (feed && feed.isCommentType) {
            [list addObject:feed];
        }
        [feed release];
    }
    return list;    
}
@end
