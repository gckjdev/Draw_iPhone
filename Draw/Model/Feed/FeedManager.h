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
}
+ (FeedManager *)defaultManager;
+ (Feed *)parsePbFeed:(PBFeed *)pbFeed;
+ (NSArray *)parsePbFeedList:(NSArray *)pbFeedList;
+ (NSArray *)parsePbCommentFeedList:(NSArray *)pbFeedList;


//deprecated method
- (void)cachePBFeed:(PBFeed *)feed;

//deprecated method
- (PBFeed *)loadPBFeedWithFeedId:(NSString *)feedId;

//new methods: cache pbdraw after draw version 2.0
- (void)cachePBDraw:(PBDraw *)pbDraw forFeedId:(NSString *)feedId;
- (void)cachePBDrawData:(NSData *)pbDrawData forFeedId:(NSString *)feedId;

- (PBDraw *)loadPBDrawWithFeedId:(NSString *)feedId;
- (NSData *)loadPBDrawDataWithFeedId:(NSString *)feedId;

- (void)removeOldCache;

- (UIImage *)thumbImageForFeedId:(NSString *)feedId;
- (UIImage *)largeImageForFeedId:(NSString *)feedId;

//working in the background queue.
- (void)saveFeed:(NSString *)feedId thumbImage:(UIImage *)image;
- (void)saveFeed:(NSString *)feedId largeImage:(UIImage *)image;

+ (NSString*)getFeedCacheDir;

@end
