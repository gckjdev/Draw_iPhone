//
//  FeedManager.m
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedManager.h"
#import "PPDebug.h"

FeedManager *_staticFeedManager = nil;

#define FeedKeyMy @"FeedKeyMy"
#define FeedKeyAll @"FeedKeyAll"
#define FeedKeyHot @"FeedKeyHot"

@implementation FeedManager


- (NSMutableArray *)listForKey:(NSString *)key
{
    return [_dataMap objectForKey:key];
}

- (void)setList:(NSMutableArray *)list forKey:(NSString *)key
{
    if (list == nil) {
        NSMutableArray *array = [self listForKey:key];
        [array removeAllObjects];
    }else{
        [_dataMap setObject:list forKey:key];
    }
}
- (void)addListForKey:(NSString *)key
{
    NSMutableArray *list = [NSMutableArray array];
    [_dataMap setObject:list forKey:key];
}




- (id)init
{
    self = [super init];
    if (self) {
        _dataMap = [[NSMutableDictionary alloc] init];
        [self addListForKey:FeedKeyMy];
        [self addListForKey:FeedKeyAll];
        [self addListForKey:FeedKeyHot];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_dataMap);
    [super dealloc];
}

+ (FeedManager *)defaultManager
{
    if (_staticFeedManager == nil) {
        _staticFeedManager = [[FeedManager alloc] init];
    }
    return _staticFeedManager;
}



- (NSMutableArray *)myFeedList
{
    return [self listForKey:FeedKeyMy];
}
- (NSMutableArray *)allFeedList
{
    return [self listForKey:FeedKeyAll];    
}
- (NSMutableArray *)hotFeedList
{
    return [self listForKey:FeedKeyHot];
}


- (void)setMyFeedList:(NSMutableArray *)list
{
    [self setList:list forKey:FeedKeyMy];
}
- (void)setAllFeedList:(NSMutableArray *)list
{
    [self setList:list forKey:FeedKeyAll];    
}
- (void)seHhotFeedList:(NSMutableArray *)list
{
    [self setList:list forKey:FeedKeyHot];
}


@end
