//
//  FeedManager.h
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"

typedef enum{
    ActionTypeHidden = 0,
    ActionTypeOneMore = 1,
    ActionTypeGuess = 2,
    ActionTypeCorrect = 3,
    ActionTypeChallenge = 4
}ActionType;

typedef enum{
    FeedActionDescNo = 0,
    FeedActionDescGuessed = 1,
    FeedActionDescTried,
    FeedActionDescDrawed,
    FeedActionDescDrawedToUser,
    
    FeedActionDescDrawedNoWord = 1001,
    FeedActionDescGuessedNoWord,
    FeedActionDescTriedNoWord,
    FeedActionDescDrawedToUserNoWord,    
    
    
}FeedActionDescType;


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


+ (ActionType)actionTypeForFeed:(Feed *)feed;
+ (NSString *)userNameForFeed:(Feed *)feed;
+ (NSString *)opusCreatorForFeed:(Feed *)feed;
+ (FeedActionDescType)feedActionDescFor:(Feed *)feed;
+ (NSString *)targetNameForFeed:(Feed *)feed;

+ (Draw *)localDrawDataForFeedId:(NSString *)feedId;
+ (void)saveDrawData:(Draw *)drawData 
          withFeedId:(NSString *)feedId 
                asyn:(BOOL)asyn;
+ (BOOL)isDrawDataExsit:(NSString *)feedId;
+ (void)parseDrawData:(Feed *)feed
             delegate:(id<FeedManagerDelegate>)delegate;
@end
