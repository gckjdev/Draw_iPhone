//
//  SKProductService.m
//  Draw
//
//  Created by 王 小涛 on 13-4-27.
//
//

#import "SKProductService.h"
#import "SynthesizeSingleton.h"
#import "IAPProductManager.h"
#import "SKProduct+LocalizedPrice.h"
#import "SKProductManager.h"
#import "NotificationCenterManager.h"
#import "NotificationName.h"

@implementation SKProductService

SYNTHESIZE_SINGLETON_FOR_CLASS(SKProductService);

- (void)dealloc
{
    [super dealloc];
}

- (void)syncDataFromIAPService
{
    // read IAP Product Identifier
    NSArray *productList = [[IAPProductManager defaultManager] productList];
    NSMutableSet* productIdSet = [[[NSMutableSet alloc] init] autorelease];
    for (PBIAPProduct *product in productList) {
        if (product.appleProductId != nil) {
            [productIdSet addObject:product.appleProductId];
        }
    }
    
    // request data from Apple IAP server
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:productIdSet];
    request.delegate = self;
    [request start];
    [request release];
    PPDebug(@"<syncDataFromIAPService> Send Query IAP Product for (%@)", [productIdSet description]);
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    // update SKProduct in coin price list

    NSArray *products = response.products;
    for (SKProduct* product in products){
        PPDebug(@"<didReceiveResponse> IAP products = %@, %@, %@",
                [product localizedDescription],
                [product localizedTitle],
                [product localizedPrice]);
    }
    
    [[SKProductManager defaultManager] setProductList:products];
}


@end
