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
- (void)didGetFeedList:(NSArray *)feedList resultCode:(NSInteger)resultCode;

@end

@interface FeedService : CommonService
{
    
}

+ (FeedService *)defaultService;

- (void)getFeedList:(FeedListType)feedListType 
             offset:(NSInteger)offset 
              limit:(NSInteger)limit 
           delegate:(id<FeedServiceDelegate>)delegate;
@end
