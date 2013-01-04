//
//  ThrowItemScene.h
//  Draw
//
//  Created by Orange on 12-10-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemType.h"
@class DrawFeed;

typedef enum {
    UseSceneTypeOnlineGuess = 0,
    UseSceneTypeOnlineGuessResult,
    UseSceneTypeOfflineGuess,
    UseSceneTypeOfflineGuessResult,
    UseSceneTypeShowFeedDetail,
    UseSceneTypeDrawMatch,
    UseSceneTypeMatchRank,
}UseSceneType;

@interface UseItemScene : NSObject {
    int _maxTomatoCount;
    int _maxFlowerCount;
    int _canThrowTomatoCount;
    int _canThrowFlowerCount;
    BOOL _isFlowerFree;
    BOOL _isTomatoFree;
    int _itemLimit;
}

@property (nonatomic, retain) DrawFeed* feed;
@property (nonatomic, assign) UseSceneType sceneType;

+ (UseItemScene*)createSceneByType:(UseSceneType)type
                              feed:(DrawFeed*)feed;

- (id)initWithMaxTomatoCount:(int)maxTomatoCount 
              maxFlowerCount:(int)maxFlowerCount 
                        feed:(DrawFeed*)feed 
                isTomatoFree:(BOOL)isTomatoFree 
                isFlowerFree:(BOOL)isFlowerFree
                        type:(UseSceneType)type;
- (BOOL)canThrowTomato;
- (BOOL)canThrowFlower;
- (BOOL)isFlowerFree;
- (BOOL)isTomatoFree;
- (void)throwATomato;
- (void)throwAFlower;
- (int)itemLimitForType:(ItemType)type;
- (BOOL)isItemFree:(ItemType)type;
- (NSString *)unavailableItemMessage;
@end
