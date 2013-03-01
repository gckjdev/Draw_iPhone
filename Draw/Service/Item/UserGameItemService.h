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

typedef void* (^UserItemResultHandler)(int resultCode, int itemId, int count, NSString *userId);

@interface UserGameItemService : CommonService

- (void)buyItem:(int)itemId
           count:(int)count
         handler:(UserItemResultHandler)handler;

- (void)giveItem:(int)itemId
         toUser:(NSString *)userId
          count:(int)count
        handler:(UserItemResultHandler)handler;

- (void)useItem:(int)itemId
         toUser:(NSString *)userId
        handler:(UserItemResultHandler)handler;

@end
