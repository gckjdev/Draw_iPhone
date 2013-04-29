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


@end
