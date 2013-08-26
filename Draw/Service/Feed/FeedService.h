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
#define DB_FIELD_ACTION_SHARE_SINA      @"share_sina"
#define DB_FIELD_ACTION_SHARE_QQ        @"share_qq"
#define DB_FIELD_ACTION_SHARE_FACEBOOK  @"share_facebook"
#define DB_FIELD_ACTION_SHARE_EMAIL     @"share_email"
#define DB_FIELD_ACTION_SHARE_WECHAT    @"share_wechat"
#define DB_FIELD_ACTION_SHARE_WECHAT_FRIENDS      @"share_wechat_friends"
#define DB_FIELD_ACTION_SAVE_ALBUM      @"save_album"

typedef void (^ LoadPBDrawResultHandler) (int resultCode, NSData *pbDrawData, DrawFeed *feed, BOOL fromCache);
typedef void (^ DownloadProgressHandler) (float progress);
typedef void (^ FeedActionResultBlock) (int resultCode);

@protocol FeedServiceDelegate <NSObject>

@optional
- (void)didGetFeedList:(NSArray *)feedList 
          feedListType:(FeedListType)type 
            resultCode:(NSInteger)resultCode;

- (void)didGetContestOpusList:(NSArray *)feedList 
                         type:(int)type 
                   resultCode:(NSInteger)resultCode;

- (void)didGetFeedList:(NSArray *)feedList 
            targetUser:(NSString *)userId 
                  type:(FeedListType)type
            resultCode:(NSInteger)resultCode;


- (void)didGetFeedCommentList:(NSArray *)feedList 
                       opusId:(NSString *)opusId
                         type:(int)type
                   resultCode:(NSInteger)resultCode
                       offset:(int)offset;

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
        resultCode:(NSInteger)resultCode
         fromCache:(BOOL)fromCache;

- (void)didGetPBDraw:(PBDraw *)pbDraw
          byDrawFeed:(DrawFeed *)drawFeed
          resultCode:(NSInteger)resultCode
           fromCache:(BOOL)fromCache;

- (void)didUpdateFeedTimes:(DrawFeed *)feed
                resultCode:(NSInteger)resultCode;

- (void)didGetMyCommentList:(NSArray *)commentList resultCode:(NSInteger)resultCode;

- (void)didGetUser:(NSString *)userId
         opusCount:(NSInteger)count
        resultCode:(NSInteger)resultCode;

@end

@interface FeedService : CommonService
{
    
}

+ (FeedService *)defaultService;

- (void)getUserFeedList:(NSString *)userId
             offset:(NSInteger)offset 
              limit:(NSInteger)limit 
           delegate:(id<FeedServiceDelegate>)delegate;

- (void)getUserOpusList:(NSString *)userId
                 offset:(NSInteger)offset 
                  limit:(NSInteger)limit
                   type:(FeedListType)type
               delegate:(id<FeedServiceDelegate>)delegate;

- (NSArray *)getCachedFeedList:(FeedListType)feedListType;

- (void)getFeedList:(FeedListType)feedListType 
             offset:(NSInteger)offset 
              limit:(NSInteger)limit 
           delegate:(id<FeedServiceDelegate>)delegate;

- (void)getFeedListByIds:(NSArray*)idList
                delegate:(id<FeedServiceDelegate>)delegate;

- (void)getContestCommentFeedList:(NSString*)contestId
                           offset:(NSInteger)offset
                            limit:(NSInteger)limit
                         delegate:(id<FeedServiceDelegate>)delegate;


- (void)getContestOpusList:(int)type 
                 contestId:(NSString *)contestId
                    offset:(NSInteger)offset 
                     limit:(NSInteger)limit 
                  delegate:(id<FeedServiceDelegate>)delegate;

- (void)getOpusCommentList:(NSString *)opusId 
                      type:(CommentType)type
                    offset:(NSInteger)offset 
                     limit:(NSInteger)limit 
                  delegate:(id<FeedServiceDelegate>)delegate;

- (void)getMyCommentList:(NSInteger)offset 
                   limit:(NSInteger)limit 
                delegate:(id<FeedServiceDelegate>)delegate;

- (void)getUserFavoriteOpusList:(NSString *)userId
                         offset:(NSInteger)offset
                          limit:(NSInteger)limit
                       delegate:(id<FeedServiceDelegate>)delegate;

//not return data ...
- (void)getFeedByFeedId:(NSString *)feedId 
               delegate:(id<FeedServiceDelegate>)delegate;

//- (void)getPBDrawByFeed:(DrawFeed *)feed
//                 delegate:(id<FeedServiceDelegate>)delegate;

- (void)getPBDrawByFeed:(DrawFeed *)feed
                 handler:(LoadPBDrawResultHandler)handler
       downloadDelegate:(id)downloadDelegate;


- (void)getOpusCount:(NSString *)targetUid
            delegete:(id<FeedServiceDelegate>)delegate;

- (void)commentOpus:(NSString *)opusId 
             author:(NSString *)author 
            comment:(NSString *)comment          
        commentType:(CommentType)commentType
          commentId:(NSString *)commentId 
     commentSummary:(NSString *)commentSummary
      commentUserId:(NSString *)commentUserId 
    commentNickName:(NSString *)commentNickName
          contestId:(NSString *)contestId
   forContestReport:(BOOL)forContestReport
           delegate:(id<FeedServiceDelegate>)delegate;



- (void)deleteFeed:(Feed *)feed
          delegate:(id<FeedServiceDelegate>)delegate;


- (void)actionSaveOpus:(NSString *)opusId 
            actionName:(NSString*)actionName;

// user favorite methods
- (void)getUserFavoriteOpusList:(NSString *)userId
                         offset:(NSInteger)offset
                          limit:(NSInteger)limit
                       delegate:(id<FeedServiceDelegate>)delegate;

- (void)addOpusIntoFavorite:(NSString *)opusId resultBlock:(FeedActionResultBlock)resultBlock;
- (void)removeOpusFromFavorite:(NSString *)opusId resultBlock:(FeedActionResultBlock)resultBlock;
- (void)recommendOpus:(NSString *)opusId resultBlock:(FeedActionResultBlock)resultBlock;

- (void)throwItem:(ItemType)itemType
           toOpus:(NSString *)opusId
           author:(NSString *)author
     awardBalance:(int)awardBalance
         awardExp:(int)awardExp
         delegate:(id<FeedServiceDelegate>)delegate;

- (void)updateFeedTimes:(DrawFeed *)feed
               delegate:(id<FeedServiceDelegate>)delegate;


- (void)updateOpus:(NSString *)opusId image:(UIImage *)image;
- (void)updateOpus:(NSString *)opusId
             image:(UIImage *)image
       description:(NSString*)description
     resultHandler:(void(^)(int resultCode))resultHandler;


- (void)unRecommendOpus:(NSString *)opusId
            resultBlock:(FeedActionResultBlock)resultBlock;

- (void)rejectOpusDrawToMe:(NSString *)opusId
               resultBlock:(FeedActionResultBlock)resultBlock;

@end
