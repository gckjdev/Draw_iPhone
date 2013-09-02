//
//  FlowerItem.h
//  Draw
//
//  Created by 王 小涛 on 13-3-15.
//
//

#import <Foundation/Foundation.h>
#import "CommonItem.h"

@class BlockArray;
@class DrawFeed;
@class Opus;

#define PARA_KEY_USER_ID @"PARA_KEY_USER_ID"
#define PARA_KEY_OPUS_ID @"PARA_KEY_OPUS_ID"

@interface FlowerItem : CommonItem <ItemActionProtocol>

+ (FlowerItem*)sharedFlowerItem;

- (void)useItem:(NSString*)toUserId
      isOffline:(BOOL)isOffline
       drawFeed:(DrawFeed*)drawFeed
        forFree:(BOOL)isFree
  resultHandler:(ConsumeItemResultHandler)resultHandler;

- (void)useItem:(NSString*)toUserId
      isOffline:(BOOL)isOffline
           opus:(Opus*)opus
        forFree:(BOOL)isFree
  resultHandler:(ConsumeItemResultHandler)handler;

@end
