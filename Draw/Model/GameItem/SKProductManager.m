//
//  SKProductManager.m
//  Draw
//
//  Created by 王 小涛 on 13-4-27.
//
//

#import "SKProductManager.h"
#import "SynthesizeSingleton.h"

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
        if (product.productIdentifier == productId) {
            return product;
        }
    }
    return nil;
}



@end
