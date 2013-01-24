//
//  ThrowItemScene.m
//  Draw
//
//  Created by Orange on 12-10-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UseItemScene.h"
#import "DrawToUserFeed.h"
#import "DrawFeed.h"

#define DEFAULT_MAX_FLOWER  10
#define DEFAULT_MAX_TOMATO  10

#define ONLINE_FLOWER   10
#define ONLINE_TOMATO   10

@implementation UseItemScene
@synthesize feed = _feed;

+ (UseItemScene*)createSceneByType:(UseSceneType)type
                              feed:(DrawFeed*)feed
{
    switch (type) {
        case UseSceneTypeOnlineGuess: {
            return [[[UseItemScene alloc] initWithMaxTomatoCount:ONLINE_TOMATO
                                                  maxFlowerCount:ONLINE_FLOWER
                                                            feed:nil
                                                    isTomatoFree:NO
                                                    isFlowerFree:NO
                                                            type:UseSceneTypeOnlineGuess] autorelease];
        }break;
        case UseSceneTypeOnlineGuessResult: {
            return [[[UseItemScene alloc] initWithMaxTomatoCount:ONLINE_TOMATO
                                                  maxFlowerCount:ONLINE_FLOWER
                                                            feed:nil
                                                    isTomatoFree:NO
                                                    isFlowerFree:NO
                                                            type:UseSceneTypeOnlineGuessResult] autorelease];
        }break;
        case UseSceneTypeOfflineGuess: {
            return [[[UseItemScene alloc] initWithMaxTomatoCount:DEFAULT_MAX_TOMATO
                                                  maxFlowerCount:DEFAULT_MAX_FLOWER
                                                            feed:feed
                                                    isTomatoFree:NO
                                                    isFlowerFree:NO
                                                            type:UseSceneTypeOfflineGuess] autorelease];
        }break;
        case UseSceneTypeOfflineGuessResult: {
            return [[[UseItemScene alloc] initWithMaxTomatoCount:DEFAULT_MAX_TOMATO
                                                  maxFlowerCount:DEFAULT_MAX_FLOWER
                                                            feed:feed
                                                    isTomatoFree:NO
                                                    isFlowerFree:NO
                                                            type:UseSceneTypeOfflineGuessResult] autorelease];
        }break;
        case UseSceneTypeShowFeedDetail: {
            return [[[UseItemScene alloc] initWithMaxTomatoCount:DEFAULT_MAX_TOMATO
                                                  maxFlowerCount:DEFAULT_MAX_FLOWER
                                                            feed:feed
                                                    isTomatoFree:NO
                                                    isFlowerFree:NO
                                                            type:UseSceneTypeShowFeedDetail] autorelease];
        }break;
        case UseSceneTypeDrawMatch: {
            return [[[UseItemScene alloc] initWithMaxTomatoCount:DEFAULT_MAX_TOMATO
                                                  maxFlowerCount:DEFAULT_MAX_FLOWER
                                                            feed:feed
                                                    isTomatoFree:YES
                                                    isFlowerFree:YES
                                                            type:UseSceneTypeDrawMatch] autorelease];
        }break;
        case UseSceneTypeMatchRank: {
            return [[[UseItemScene alloc] initWithMaxTomatoCount:0
                                                  maxFlowerCount:0
                                                            feed:feed
                                                    isTomatoFree:NO
                                                    isFlowerFree:NO
                                                            type:UseSceneTypeMatchRank] autorelease];
        }break;
        default:
            break;
    }
    return [[[UseItemScene alloc] initWithMaxTomatoCount:DEFAULT_MAX_TOMATO
                                          maxFlowerCount:DEFAULT_MAX_FLOWER
                                                    feed:nil
                                            isTomatoFree:NO
                                            isFlowerFree:NO
                                                    type:UseSceneTypeOfflineGuess] autorelease];
}

- (id)initWithMaxTomatoCount:(int)maxTomatoCount 
              maxFlowerCount:(int)maxFlowerCount 
                        feed:(DrawFeed*)feed 
                isTomatoFree:(BOOL)isTomatoFree 
                isFlowerFree:(BOOL)isFlowerFree
                        type:(UseSceneType)type
{
    self = [super init];
    if (self) {
        self.feed = feed;
        _maxTomatoCount = maxTomatoCount;
        _maxFlowerCount = maxFlowerCount;
        _canThrowFlowerCount = maxFlowerCount;
        _canThrowTomatoCount = maxTomatoCount;
        _isFlowerFree = isFlowerFree;
        _isTomatoFree = isTomatoFree;
        _sceneType = type;
    }
    return self;
}
- (BOOL)canThrowTomato
{
    if (_feed) {
        return [_feed canThrowTomato] && (_maxTomatoCount > 0);
    }
    return (_canThrowTomatoCount > 0);
}
- (BOOL)canThrowFlower
{
    if (_feed) {
        return [_feed canSendFlower] && (_maxFlowerCount > 0);
    }
    return (_canThrowFlowerCount > 0);
}

- (BOOL)isFlowerFree
{
    return _isFlowerFree;
}
- (BOOL)isTomatoFree
{
    return _isTomatoFree;
}

- (BOOL)isItemFree:(ItemType)type
{
    switch (type) {
        case ItemTypeFlower:
            return _isFlowerFree;
        case ItemTypeTomato:
            return _isTomatoFree;
        default:
            return NO;
            break;
    }
}

- (void)throwATomato
{
    if (_feed) {
        [_feed increaseLocalTomatoTimes];
        return;
    }
    _canThrowTomatoCount--;
}

- (void)throwAFlower
{
    if (_feed) {
        [_feed increaseLocalFlowerTimes];
        return;
    }
    _canThrowFlowerCount--;
}

- (int)itemLimitForType:(ItemType)type
{
    if (_feed) {
        return _feed.itemLimit;
    }
    if (type == ItemTypeTomato) {
        return _maxTomatoCount;
    }
    if (type == ItemTypeFlower) {
        return _maxFlowerCount;
    }
    return 0;
}

- (NSString *)unavailableItemMessage
{
    if (_sceneType == UseSceneTypeMatchRank) {
        return  [NSString stringWithFormat:NSLS(@"kCanotSendItemToOverContestOpus")];
    }
    if ([self.feed isContestFeed]) {
        return  [NSString stringWithFormat:NSLS(@"kCanotSendItemToContestOpus"),self.feed.itemLimit];
    }
    return [NSString stringWithFormat:NSLS(@"kCanotSendItemToOpus"),self.feed.itemLimit];
}

@end
