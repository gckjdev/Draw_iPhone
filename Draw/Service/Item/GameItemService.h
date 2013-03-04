//
//  GameItemService.h
//  Draw
//
//  Created by qqn_pipi on 13-2-22.
//
//

#import <Foundation/Foundation.h>
#import "GameBasic.pb.h"

typedef void (^GetItemsListResultHandler)(BOOL success, NSArray *itemsList);

@interface GameItemService : NSObject

+ (GameItemService *)sharedGameItemService;

- (void)getItemsList:(GetItemsListResultHandler)handler;

- (void)getItemsListWithType:(int)type
               resultHandler:(GetItemsListResultHandler)handler;

- (void)getPromotingItemsList:(GetItemsListResultHandler)handler;

@end
