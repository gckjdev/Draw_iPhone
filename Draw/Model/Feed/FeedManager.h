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



typedef enum{
    
    FeedListTypeUnknow = 0,
    FeedListTypeMy = 1,
    FeedListTypeAll = 2,
    FeedListTypeHot = 3,
    FeedListTypeUserFeed = 4,
    FeedListTypeUserOpus = 5,
    FeedListTypeLatest = 6,
    
}FeedListType;


@protocol FeedManagerDelegate <NSObject>

@optional
- (void)didParseFeedDrawData:(Feed *)feed;

@end

@interface FeedManager : NSObject
{
    NSMutableDictionary *_dataMap;
}
+ (FeedManager *)defaultManager;
+ (void)releaseDefaultManager;
- (NSMutableArray *)feedListForType:(FeedListType)type;
- (void)setFeedList:(NSMutableArray *)feedList forType:(FeedListType)type;
- (void)addFeedList:(NSArray *)feedList forType:(FeedListType)type;
- (void)cleanData;


+ (NSArray *)parsePbFeedList:(NSArray *)pbFeedList;
+ (NSArray *)parsePbCommentFeedList:(NSArray *)pbFeedList;
@end
