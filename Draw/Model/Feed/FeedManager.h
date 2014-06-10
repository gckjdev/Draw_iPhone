//
//  FeedManager.h
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"
#import "DrawFeed.h"
#import "GuessFeed.h"
#import "DrawToUserFeed.h"
#import "CommentFeed.h"
#import "ContestFeed.h"
#import "StorageManager.h"

typedef enum{
    
    FeedListTypeUnknow = 0,
    FeedListTypeMy = 1,
    FeedListTypeAll = 2,
    FeedListTypeHot = 3,
    FeedListTypeUserFeed = 4,
    FeedListTypeUserOpus = 5,
    FeedListTypeLatest = 6,
    
    //add 2012.9.21
    FeedListTypeDrawToMe = 7,
    FeedListTypeComment = 8,
    FeedListTypeHistoryRank = 9,
    FeedListTypeTopPlayer = 10,
    
    FeedListTypeRecommend = 11,
    FeedListTypeTimelineOpus = 12,
    FeedListTypeTimelineGuess = 13,
    
    FeedListTypeContestComment = 20,
    FeedListTypeIdList = 21,

    FeedListTypeTimelineGroup = 30,
    FeedListTypeTimelineGroupAll = 31,

    FeedListTypeVIP = 41,

    FeedListTypeClassHotTop = 51,
    FeedListTypeClassAlltimeTop = 52,
    FeedListTypeClassLatest = 53,
    FeedListTypeClassFeature = 54,
    FeedListTypeClassOriginal = 55,
    
    FeedListTypeUserFavorite = 100,
    
}FeedListType;


@protocol FeedManagerDelegate <NSObject>

@optional
- (void)didParseFeedDrawData:(Feed *)feed;

@end

@interface FeedManager : NSObject
{
    StorageManager *_storeManager;
    StorageManager *_feedImageManager;
    StorageManager *_feedListStoreManager;
}
+ (FeedManager *)defaultManager;
+ (Feed *)parsePbFeed:(PBFeed *)pbFeed;
+ (NSArray *)parsePbFeedList:(NSArray *)pbFeedList;
+ (NSArray *)parsePbCommentFeedList:(NSArray *)pbFeedList;



//new methods: cache pbdraw after draw version 2.0
- (void)cachePBDraw:(PBDraw *)pbDraw forFeedId:(NSString *)feedId;
- (void)cachePBDrawData:(NSData *)pbDrawData forFeedId:(NSString *)feedId;

- (PBDraw *)loadPBDrawWithFeedId:(NSString *)feedId;
- (NSData *)loadPBDrawDataWithFeedId:(NSString *)feedId;

- (void)removeOldCache;


- (void)cacheFeedDataQueryResponse:(DataQueryResponse *)response
                            forKey:(NSString *)key;

- (NSArray *)loadFeedListForKey:(NSString *)key;

@end
