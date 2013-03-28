//
//  IngotService.h
//  Draw
//
//  Created by 王 小涛 on 13-3-7.
//
//

#import <Foundation/Foundation.h>

typedef void (^GetIngotsListResultHandler)(BOOL success, NSArray *ingotsList);

@class PBSaleIngot;

@interface IngotService : NSObject

+ (IngotService *)defaultService;

- (void)syncData:(GetIngotsListResultHandler)handler;

+ (void)createTestDataFile;

@end
