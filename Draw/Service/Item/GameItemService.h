//
//  GameItemService.h
//  Draw
//
//  Created by qqn_pipi on 13-2-22.
//
//

#import <Foundation/Foundation.h>
#import "GameBasic.pb.h"

// SHOP_ITEMS_FILE_VERSION

typedef void (^SyncItemsDataResultHandler)(BOOL success);

@interface GameItemService : NSObject

+ (GameItemService *)defaultService;

- (void)syncData:(SyncItemsDataResultHandler)handler;

+ (void)createTestDataFile;

@end
