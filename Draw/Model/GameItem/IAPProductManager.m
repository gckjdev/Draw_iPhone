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
        NSString *path = [bundle pathForResource:[IAPProductManager IAPProductFileName] ofType:IAP_PRODUCT_FILE_TYPE];
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

+ (NSString *)IAPProductFileName
{
    return [[[[IAP_PRODUCT_FILE_WITHOUT_SUFFIX stringByAppendingString:@"_"] stringByAppendingString:[GameApp gameId]] stringByAppendingString:@"."] stringByAppendingString:[self IAPProductFileType]];
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

@end