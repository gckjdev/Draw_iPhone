//
//  IAPProductManager.m
//  Draw
//
//  Created by 王 小涛 on 13-3-28.
//
//

#import "IAPProductManager.h"
#import "SynthesizeSingleton.h"

#define IAP_PRODUCT_FILE_WITHOUT_SUFFIX  @"iap_product"
#define IAP_PRODUCT_FILE_TYPE @"pb"
#define IAP_PRODUCT_FILE_VERSION @"1.0"

@interface IAPProductManager()

@end

@implementation IAPProductManager

SYNTHESIZE_SINGLETON_FOR_CLASS(IAPProductManager);

- (void)dealloc{
    [_productList release];
    [super dealloc];
}

- (id)init{
    if (self = [super init]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:[IAPProductManager IAPProductFileNameWithoutSuffix] ofType:IAP_PRODUCT_FILE_TYPE];
        NSData *data = [NSData dataWithContentsOfFile:path];
        self.productList = [[PBIAPProductList parseFromData:data] productsList];
    }
    
    return self;
}

- (PBIAPProduct *)productWithAppleProductId:(NSString *)appleProductId
{
    for (PBIAPProduct *product in _productList) {
        if ([product.appleProductId isEqualToString:appleProductId]) {
            return product;
        }
    }
    
    return nil;
}

- (PBIAPProduct *)productWithAlipayProductId:(NSString *)alipayProductId
{
    for (PBIAPProduct *product in _productList) {
        if ([product.alipayProductId isEqualToString:alipayProductId]) {
            return product;
        }
    }
    
    return nil;
}

+ (NSString *)IAPProductFileNameWithoutSuffix
{
    return [[IAP_PRODUCT_FILE_WITHOUT_SUFFIX stringByAppendingString:@"_"] stringByAppendingString:[GameApp gameId]];
}

+ (NSString *)IAPProductFileName
{
    // change file name by Benson 2013-05-27 for littlegee and draw
    return [[[[IAP_PRODUCT_FILE_WITHOUT_SUFFIX stringByAppendingString:@"_"] stringByAppendingString:[GameApp iapResourceFileName]] stringByAppendingString:@"."] stringByAppendingString:[self IAPProductFileType]];
}

+ (NSString *)IAPProductFileBundlePath
{
    return [self IAPProductFileName];
}

+ (NSString *)IAPProductFileType
{
    return IAP_PRODUCT_FILE_TYPE;
}

+ (NSString *)IAPProductFileVersion
{
    return IAP_PRODUCT_FILE_VERSION;
}

+ (PBGameCurrency)currencyWithIAPProductType:(PBIAPProductType)type
{
    switch (type) {
        case PBIAPProductTypeIapcoin:
            return PBGameCurrencyCoin;
            break;

        case PBIAPProductTypeIapingot:
            return PBGameCurrencyIngot;
            break;
            
        default:
            return -9999;
            break;
    }
}

@end
