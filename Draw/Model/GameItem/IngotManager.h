//
//  IngotManager.h
//  Draw
//
//  Created by 王 小涛 on 13-3-28.
//
//

#import <Foundation/Foundation.h>

#define SALE_INGOT_FILE_WITHOUT_SUFFIX  @"sale_ingot"
#define SALE_INGOT_FILE_TYPE @"pb"
#define SALE_INGOT_FILE @"sale_ingot.pb"
#define SALE_INGOT_FILE_BUNDLE_PATH @"sale_ingot.pb"
#define SALE_INGOT_FILE_VERSION @"1.0"

@interface IngotManager : NSObject

@property (retain, nonatomic) NSArray *ingotList;

+ (IngotManager *)defaultManager;

- (PBSaleIngot *)ingotWithProductId:(NSString *)productId;

@end
