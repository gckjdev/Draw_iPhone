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


//- (NSMutableArray *)listForKey:(NSString *)key
//{
//    return [_dataMap objectForKey:key];
//}
//
//- (void)setList:(NSMutableArray *)list forKey:(NSString *)key
//{
//    if (list == nil) {
//        NSMutableArray *array = [self listForKey:key];
//        [array removeAllObjects];
//    }else{
//        [_dataMap setObject:list forKey:key];
//    }
//}
- (void)addListForKey:(NSString *)key
{
    NSMutableArray *list = [NSMutableArray array];
    [_dataMap setObject:list forKey:key];
}


- (NSString *)keyForType:(FeedListType )type
{
    if (type == FeedListTypeMy) {
        return FeedKeyMy;
    }
    if (type == FeedListTypeAll) {
        return FeedKeyAll;
    }
    if (type == FeedListTypeHot) {
        return FeedKeyHot;
    }
    return nil;
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

- (NSMutableArray *)feedListForType:(FeedListType)type
{
    NSString *key = [self keyForType:type];
    if (key) {
        return [_dataMap objectForKey:key];
    }
    return nil;
}
- (void)setFeedList:(NSMutableArray *)feedList forType:(FeedListType)type
{
    NSString *key = [self keyForType:type];
    if (key) {
        if (feedList) {
            [_dataMap setObject:feedList forKey:key];            
        }else{
            //if the list is nil;
            NSMutableArray *list = [self feedListForType:type];
            [list removeAllObjects];
        }
    }
}
- (void)addFeedList:(NSArray *)feedList forType:(FeedListType)type
{
    if ([feedList count] == 0) {
        return;
    }
    NSMutableArray *list = [self feedListForType:type];
    if (list) {
        [list addObjectsFromArray:feedList];
    }
}



@end
