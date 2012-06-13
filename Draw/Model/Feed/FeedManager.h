//
//  FeedManager.h
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedManager : NSObject
{
    NSMutableDictionary *_dataMap;
}
+ (FeedManager *)defaultManager;
- (NSMutableArray *)myFeedList;
- (NSMutableArray *)allFeedList;
- (NSMutableArray *)hotFeedList;

- (void)setMyFeedList:(NSMutableArray *)list;
- (void)setAllFeedList:(NSMutableArray *)list;
- (void)seHhotFeedList:(NSMutableArray *)list;


@end
