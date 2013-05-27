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

+ (void)createDrawIngotTestDataFile;
+ (void)createLittlegeeIngotTestDataFile;
+ (void)createLearnDrawIngotTestDataFile;
+ (void)createPureDrawIngotTestDataFile;
+ (void)createPureDrawFreeIngotTestDataFile;
+ (void)createPhotoDrawIngotTestDataFile;
+ (void)createPhotoDrawFreeIngotTestDataFile;
+ (void)createDreamAvatarIngotTestDataFile;
+ (void)createDreamAvatarFreeIngotTestDataFile;
+ (void)createDreamLockscreenIngotTestDataFile;
+ (void)createDreamLockscreenFreeIngotTestDataFile;
+ (void)createZJHCoinTestDataFile;
+ (void)createDiceCoinTestDataFile;

@end
