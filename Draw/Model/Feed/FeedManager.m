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

@implementation FeedManager



#define FEED_DIR @"feedCache"
#define FEED_LIST_DATA_SUFFIX @".flist"
#define FEED_LIST_DIR @"feedListCache"
#define FEED_IMAGE_DIR @"feed_image"
#define THUMB_IMAGE_SUFFIX @".png"
#define LARGE_IMAGE_SUFFIX @"_l.png"

- (id)init
{
    self = [super init];
    if (self) {
        _storeManager = [[StorageManager alloc] initWithStoreType:StorageTypeCache directoryName:FEED_DIR];
        _feedImageManager = [[StorageManager alloc] initWithStoreType:StorageTypeCache directoryName:FEED_IMAGE_DIR];
        
        _feedListStoreManager = [[StorageManager alloc] initWithStoreType:StorageTypeCache directoryName:FEED_LIST_DIR];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_feedImageManager);
    PPRelease(_storeManager);
    PPRelease(_feedListStoreManager);
    [super dealloc];
}

+ (FeedManager *)defaultManager
{
    if (_staticFeedManager == nil) {
        _staticFeedManager = [[FeedManager alloc] init];
    }
    return _staticFeedManager;
}


+ (Feed *)parsePbFeed:(PBFeed *)pbFeed
{
    Feed *feed = nil;
    @try {
        switch (pbFeed.actionType) {
            case FeedTypeDraw:
            case FeedTypeSing:
            case FeedTypeConquerDraw:
            case FeedTypePracticeDraw:
                feed = [[[DrawFeed alloc] initWithPBFeed:pbFeed] autorelease];
                break;
            case FeedTypeGuess:
                feed = [[[GuessFeed alloc] initWithPBFeed:pbFeed] autorelease];
                break;
            case FeedTypeDrawToUser:
            case FeedTypeSingToUser:
                // TODO check impact on SING
                feed = [[[DrawToUserFeed alloc] initWithPBFeed:pbFeed] autorelease];
                break;
            case FeedTypeDrawToContest:
            case FeedTypeSingContest:
                feed = [[[ContestFeed alloc] initWithPBFeed:pbFeed] autorelease];
                break;
            case FeedTypeContestComment:
                feed = [[[CommentFeed alloc] initWithPBFeed:pbFeed] autorelease];
                break;
            default:
                break;
        }
    }
    @catch (NSException *exception) {
        PPDebug(@"<parsePbFeed> but catch exception (%@)", [exception description]);
        feed = nil;
    }
    @finally {
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


#define PBDRAW_KEY(x) [NSString stringWithFormat:@"%@_pbdraw",x]

- (void)cachePBDrawData:(NSData *)pbDrawData forFeedId:(NSString *)feedId
{
    [pbDrawData retain];
    
    @try {
        NSString *key = PBDRAW_KEY(feedId);
        PPDebug(@"<cachePBDrawData> Key = %@",key);
        [_storeManager saveData:pbDrawData forKey:key];
    }
    @catch (NSException *exception) {
        PPDebug(@"<cachePBDrawData> exception : %@",exception);
    }
    @finally {
        
    }
    
    [pbDrawData release];
    
}

- (void)cachePBDraw:(PBDraw *)pbDraw forFeedId:(NSString *)feedId;
{
    [pbDraw retain];

    @try {
        NSString *key = PBDRAW_KEY(feedId);
        PPDebug(@"<cachePBDraw> Key = %@",key);
        [_storeManager saveData:[pbDraw data] forKey:key];
    }
    @catch (NSException *exception) {
        PPDebug(@"<cachePBDraw> exception : %@",exception);
    }
    @finally {
        
    }
    
    [pbDraw release];

}

- (NSData *)loadPBDrawDataWithFeedId:(NSString *)feedId
{
    NSString *key = PBDRAW_KEY(feedId);
    NSData *data = [_storeManager dataForKey:key];
    return data;
//    if (data) {
//        PBDraw *pbDraw = [PBDraw parseFromData:data];
//        PPDebug(@"<loadPBDrawWithFeedId>, key= %@", key);
//        return pbDraw;
//    }
//    return nil;
}


- (PBDraw *)loadPBDrawWithFeedId:(NSString *)feedId
{
    NSString *key = PBDRAW_KEY(feedId);
    NSData *data = [_storeManager dataForKey:key];
    if (data) {
        PBDraw *pbDraw = [PBDraw parseFromData:data];
        PPDebug(@"<loadPBDrawWithFeedId>, key= %@", key);
        return pbDraw;
    }
    return nil;
}



#define FEED_INTERVAL 3600 * 24 * 5 //5 DAYS

- (void)removeOldFiles
{
    [_storeManager removeOldFilestimeIntervalSinceNow:FEED_INTERVAL];
}



#pragma mark - Feed Cache Image

#define FEED_IMAGE_INTERVAL 3600 * 24 * 10 //10 DAYS

- (void)removeOldImages
{
    [_feedImageManager removeOldFilestimeIntervalSinceNow:FEED_IMAGE_INTERVAL];
}

- (void)removeOldCache
{
    PPDebug(@"<removeOldCache>");
    [self removeOldFiles];
    [self removeOldImages];
}

- (void)cacheFeedDataQueryResponse:(DataQueryResponse *)response
                            forKey:(NSString *)key
{
    if ([key length] != 0) {
        key = [key stringByAppendingString:FEED_LIST_DATA_SUFFIX];
        [_feedListStoreManager saveData:[response data] forKey:key];
    }
}

- (NSArray *)loadFeedListForKey:(NSString *)key
{
    if ([key length] != 0) {
        key = [key stringByAppendingString:FEED_LIST_DATA_SUFFIX];
        NSData *data = [_feedListStoreManager dataForKey:key];
        @try {
            DataQueryResponse *response = [DataQueryResponse parseFromData:data];
            NSArray *feedList = response.feed;
            return [FeedManager parsePbFeedList:feedList];
        }
        @catch (NSException *exception) {
            return nil;
        }
    }
}


@end
