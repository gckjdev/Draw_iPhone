//
//  FeedService.h
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"
#import "Feed.h"

@protocol FeedServiceDelegate <NSObject>

@optional
- (void)didGetFeedList:(NSArray *)feedList 
          feedListType:(FeedListType)type 
            resultCode:(NSInteger)resultCode;

- (void)didGetFeedList:(NSArray *)feedList 
          targetUser:(NSString *)userId
            resultCode:(NSInteger)resultCode;


- (void)didGetFeedCommentList:(NSArray *)feedList 
                       opusId:(NSString *)opusId 
                   resultCode:(NSInteger)resultCode;

- (void)didCommentOpus:(NSString *)opusId
               comment:(NSString *)comment 
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


- (void)getFeedList:(FeedListType)feedListType 
             offset:(NSInteger)offset 
              limit:(NSInteger)limit 
           delegate:(id<FeedServiceDelegate>)delegate;

- (void)getOpusCommentList:(NSString *)opusId
             offset:(NSInteger)offset 
              limit:(NSInteger)limit 
           delegate:(id<FeedServiceDelegate>)delegate;


- (void)commentOpus:(NSString *)opusId 
             author:(NSString *)author 
            comment:(NSString *)comment            
           delegate:(id<FeedServiceDelegate>)delegate;
@end
