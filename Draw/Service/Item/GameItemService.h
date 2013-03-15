//
//  GameItemService.h
//  Draw
//
//  Created by qqn_pipi on 13-2-22.
//
//

#import <Foundation/Foundation.h>
#import "GameBasic.pb.h"

typedef void (^SyncItemsDataResultHandler)(BOOL success);

@interface GameItemService : NSObject

+ (GameItemService *)defaultService;

- (void)syncData:(SyncItemsDataResultHandler)handler;

- (NSArray *)getItemsList;
- (NSArray *)getItemsListWithType:(int)type;
- (NSArray *)getPromotingItemsList;
- (PBGameItem *)itemWithItemId:(int)itemId;

+ (void)createTestDataFile;

@end
