//
//  IAPProductService.h
//  Draw
//
//  Created by 王 小涛 on 13-3-7.
//
//

#import <Foundation/Foundation.h>

typedef void (^GetIngotsListResultHandler)(BOOL success, NSArray *ingotsList);

@class PBIAPProduct;

@interface IAPProductService : NSObject

+ (IAPProductService *)defaultService;

- (void)syncData:(GetIngotsListResultHandler)handler;

+ (void)createTestDataFile;

@end
