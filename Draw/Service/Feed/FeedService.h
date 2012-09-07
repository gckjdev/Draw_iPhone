//
//  FeedService.h
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"
#import "FeedManager.h"
#import "ItemType.h"
#import "PPViewController.h"

#define DB_FIELD_ACTION_SAVE_TIMES      @"save_times"

@protocol FeedServiceDelegate <NSObject>

@optional
- (void)didGetFeedList:(NSArray *)feedList 
          feedListType:(FeedListType)type 
            resultCode:(NSInteger)resultCode;

- (void)didGetFeedList:(NSArray *)feedList 
            targetUser:(NSString *)userId 
                  type:(FeedListType)type
            resultCode:(NSInteger)resultCode;


- (void)didGetFeedCommentList:(NSArray *)feedList 
                       opusId:(NSString *)opusId
                         type:(int)type
                   resultCode:(NSInteger)resultCode;

- (void)didCommentOpus:(NSString *)opusId
         commentFeedId:(NSString *)commentFeedId
               comment:(NSString *)comment 
            resultCode:(NSInteger)resultCode;

- (void)didDeleteFeed:(Feed *)feed
            resultCode:(NSInteger)resultCode;

- (void)didThrowFlowerToOpus:(NSString *)opusId
            resultCode:(NSInteger)resultCode;

- (void)didThrowTomatoToOpus:(NSString *)opusId
                  resultCode:(NSInteger)resultCode;

- (void)didGetFeed:(DrawFeed *)feed 
        resultCode:(NSInteger)resultCode;

- (void)didUpdateFeedTimes:(DrawFeed *)feed 
                resultCode:(NSInteger)resultCode;
@end

@interface FeedService : CommonService
{
    
}

+ (FeedService *)defaultService;

- (void)getUserFeedList:(NSString *)userId
             offset:(NSInteger)offset 
              limit:(NSInteger)limit 
           delegate:(PPViewController<FeedServiceDelegate> *)delegate;

- (void)getUserOpusList:(NSString *)userId
                 offset:(NSInteger)offset 
                  limit:(NSInteger)limit 
               delegate:(PPViewController<FeedServiceDelegate> *)delegate;

- (void)getFeedList:(FeedListType)feedListType 
             offset:(NSInteger)offset 
              limit:(NSInteger)limit 
           delegate:(PPViewController<FeedServiceDelegate> *)delegate;

- (void)getOpusCommentList:(NSString *)opusId 
                      type:(int)type
                    offset:(NSInteger)offset 
                     limit:(NSInteger)limit 
                  delegate:(id<FeedServiceDelegate>)delegate;

- (void)getFeedByFeedId:(NSString *)feedId 
               delegate:(id<FeedServiceDelegate>)delegate;

- (void)commentOpus:(NSString *)opusId 
             author:(NSString *)author 
            comment:(NSString *)comment            
           delegate:(id<FeedServiceDelegate>)delegate;

- (void)deleteFeed:(Feed *)feed
          delegate:(id<FeedServiceDelegate>)delegate;

- (void)throwFlowerToOpus:(NSString *)opusId 
                   author:(NSString *)author  
                 delegate:(id<FeedServiceDelegate>)delegate;

- (void)throwTomatoToOpus:(NSString *)opusId 
                   author:(NSString *)author 
                 delegate:(id<FeedServiceDelegate>)delegate;

- (void)actionSaveOpus:(NSString *)opusId 
            actionName:(NSString*)actionName;

- (void)throwItem:(ItemType)itemType toOpus:(NSString *)opusId 
           author:(NSString *)author   
         delegate:(id<FeedServiceDelegate>)delegate;

- (void)updateFeedTimes:(DrawFeed *)feed
               delegate:(id<FeedServiceDelegate>)delegate;
@end
