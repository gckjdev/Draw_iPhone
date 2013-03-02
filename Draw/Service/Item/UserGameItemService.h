//
//  UserGameItemService.h
//  Draw
//
//  Created by qqn_pipi on 13-2-22.
//
//

#import <Foundation/Foundation.h>
#import "CommonService.h"
#import "GameBasic.pb.h"

typedef void* (^BuyItemResultHandler)(int resultCode, int itemId, int count, NSString *toUserId);
typedef void* (^UseItemResultHandler)(int resultCode, int itemId, NSString *toOpusId);


@interface UserGameItemService : CommonService

- (void)buyItem:(int)itemId
           count:(int)count
         handler:(BuyItemResultHandler)handler;

- (void)giveItem:(int)itemId
         toUser:(NSString *)userId
          count:(int)count
        handler:(BuyItemResultHandler)handler;

- (void)useItem:(int)itemId
         toOpus:(NSString *)opusId
        handler:(UseItemResultHandler)handler;

@end
