//
//  IAPProductManager.h
//  Draw
//
//  Created by 王 小涛 on 13-3-28.
//
//

#import <Foundation/Foundation.h>

@interface IAPProductManager : NSObject

@property (retain, nonatomic) NSArray *productList;

+ (IAPProductManager *)defaultManager;

+ (NSString *)IAPProductFileName;
+ (NSString *)IAPProductFileBundlePath;
+ (NSString *)IAPProductFileVersion;

- (PBIAPProduct *)productWithAppleProductId:(NSString *)appleProductId;
- (PBIAPProduct *)productWithAlipayProductId:(NSString *)alipayProductId;

+ (PBGameCurrency)currencyWithIAPProductType:(PBIAPProductType)type;

@end
