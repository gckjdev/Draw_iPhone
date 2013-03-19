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

#define PARA_KEY_USER_ID @"PARA_KEY_USER_ID"
#define PARA_KEY_OPUS_ID @"PARA_KEY_OPUS_ID"

@interface FlowerItem : CommonItem <ItemActionProtocol>

+ (FlowerItem*)sharedFlowerItem;

- (void)useItem:(NSString*)toUserId
      isOffline:(BOOL)isOffline
     feedOpusId:(NSString*)feedOpusId
     feedAuthor:(NSString*)feedAuthor
        forFree:(BOOL)isFree
  resultHandler:(ConsumeItemResultHandler)resultHandler;

@end
