//
//  FeedManager.h
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"


@interface FeedManager : NSObject
{
    NSMutableDictionary *_dataMap;
}
+ (FeedManager *)defaultManager;
- (NSMutableArray *)feedListForType:(FeedListType)type;
- (void)setFeedList:(NSMutableArray *)feedList forType:(FeedListType)type;
- (void)addFeedList:(NSArray *)feedList forType:(FeedListType)type;
//- (NSMutableArray *)myFeedList;
//- (NSMutableArray *)allFeedList;
//- (NSMutableArray *)hotFeedList;
//
//- (void)setMyFeedList:(NSMutableArray *)list;
//- (void)setAllFeedList:(NSMutableArray *)list;
//- (void)seHhotFeedList:(NSMutableArray *)list;


@end
