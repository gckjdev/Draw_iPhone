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

#define ONLINE_FLOWER   2
#define ONLINE_TOMATO   2

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
                                                    isFlowerFree:NO] autorelease];
        }break;
        case UseSceneTypeOnlineGuessResult: {
            return [[[UseItemScene alloc] initWithMaxTomatoCount:ONLINE_TOMATO
                                                  maxFlowerCount:ONLINE_FLOWER
                                                            feed:nil
                                                    isTomatoFree:NO
                                                    isFlowerFree:NO] autorelease];
        }break;
        case UseSceneTypeOfflineGuess: {
            return [[[UseItemScene alloc] initWithMaxTomatoCount:DEFAULT_MAX_TOMATO
                                                  maxFlowerCount:DEFAULT_MAX_FLOWER
                                                            feed:feed
                                                    isTomatoFree:NO
                                                    isFlowerFree:NO] autorelease];
        }break;
        case UseSceneTypeOfflineGuessResult: {
            return [[[UseItemScene alloc] initWithMaxTomatoCount:DEFAULT_MAX_TOMATO
                                                  maxFlowerCount:DEFAULT_MAX_FLOWER
                                                            feed:feed
                                                    isTomatoFree:NO
                                                    isFlowerFree:NO] autorelease];
        }break;
        case UseSceneTypeShowFeedDetail: {
            return [[[UseItemScene alloc] initWithMaxTomatoCount:DEFAULT_MAX_TOMATO
                                                  maxFlowerCount:DEFAULT_MAX_FLOWER
                                                            feed:feed
                                                    isTomatoFree:NO
                                                    isFlowerFree:NO] autorelease];
        }break;
        case UseSceneTypeDrawMatch: {
            return [[[UseItemScene alloc] initWithMaxTomatoCount:DEFAULT_MAX_TOMATO
                                                  maxFlowerCount:DEFAULT_MAX_FLOWER
                                                            feed:feed
                                                    isTomatoFree:YES
                                                    isFlowerFree:YES] autorelease];
        }break;
        default:
            break;
    }
    return [[[UseItemScene alloc] initWithMaxTomatoCount:DEFAULT_MAX_TOMATO
                                          maxFlowerCount:DEFAULT_MAX_FLOWER
                                                    feed:nil
                                            isTomatoFree:NO
                                            isFlowerFree:NO] autorelease];
}

- (id)initWithMaxTomatoCount:(int)maxTomatoCount 
              maxFlowerCount:(int)maxFlowerCount 
                        feed:(DrawFeed*)feed 
                isTomatoFree:(BOOL)isTomatoFree 
                isFlowerFree:(BOOL)isFlowerFree 
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
    }
    return self;
}
- (BOOL)canThrowTomato
{
    if (_feed) {
        return [_feed canThrowTomato]; 
    }
    return (_canThrowTomatoCount > 0);
}
- (BOOL)canThrowFlower
{
    if (_feed) {
        return [_feed canSendFlower];
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

@end
