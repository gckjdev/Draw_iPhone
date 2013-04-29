//
//  SKProductManager.m
//  Draw
//
//  Created by 王 小涛 on 13-4-27.
//
//

#import "SKProductManager.h"
#import "SynthesizeSingleton.h"
#import "SKProduct+LocalizedPrice.h"

#define KEY_SKPRODUCT_LIST @"KEY_SKPRODUCT_LIST"

@interface SKProductManager()

@end

@implementation SKProductManager

SYNTHESIZE_SINGLETON_FOR_CLASS(SKProductManager);

- (void)dealloc{
    [_productList release];
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.productList = [userDefaults objectForKey:KEY_SKPRODUCT_LIST];
    }
    
    return self;
}

- (SKProduct *)productWithId:(NSString *)productId
{
    for (SKProduct *product in _productList) {
        NSString *productIdentifier = product.productIdentifier;
        if ([productIdentifier isEqualToString:productId]) {
            return product;
        }
    }
    return nil;
}

- (void)setProductList:(NSArray *)productList
{
    if ([productList count] <= 0) {
        return;
    }
    
    [_productList release];
    _productList = [productList retain];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[self.productList data]forKey:KEY_SKPRODUCT_LIST];
    [userDefaults synchronize];
}


@end
