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


- (void)updateItemListWithType:(int)type
                       handler:(GetItemsListResultHandler)handler;

- (void)updatePromotingItemsList:(GetItemsListResultHandler)handler;

- (void)getItemsListWithType:(int)type
               resultHandler:(GetItemsListResultHandler)handler;

- (void)getPromotingItemsList:(GetItemsListResultHandler)handler;

+ (void)createTestDataFile;

@end
