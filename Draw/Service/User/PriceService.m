//
//  PriceService.m
//  Draw
//
//  Created by  on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PriceService.h"
#import "GameNetworkConstants.h"
#import "GameNetworkRequest.h"
#import "PPNetworkRequest.h"
#import "ShoppingManager.h"
#import "PPDebug.h"
#import <StoreKit/StoreKit.h>

static PriceService* staticPriceService = nil;

@implementation PriceService

+ (PriceService *)defaultService
{
    if (staticPriceService == nil) {
        staticPriceService = [[PriceService alloc] init];
    }
    return staticPriceService;
}

- (void)fetchShoppingListByType:(SHOPPING_MODEL_TYPE)type
                 viewController:(PPViewController<PriceServiceDelegate> *)viewController
{
    if ([viewController respondsToSelector:@selector(didBeginFetchShoppingList)]) {
        [viewController didBeginFetchShoppingList];
    }
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = nil;        
        output = [GameNetworkRequest fetchShoppingList:SERVER_URL type:type];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS) {
                NSArray *array =[[ShoppingManager defaultManager] getShoppingListFromOutputList:output.jsonDataArray type:type];
                if ([viewController respondsToSelector:@selector(didFinishFetchShoppingList:resultCode:)]) {
                    [viewController didFinishFetchShoppingList:array resultCode:output.resultCode];
                }
            }
        });
        
    });    

}

- (void)fetchCoinProductList:(PPViewController<PriceServiceDelegate> *)viewController
{        
    // read price list
    NSArray* priceList = [[ShoppingManager defaultManager] getShoppingListByType:SHOPPING_COIN_TYPE];    
    NSMutableSet* productIdSet = [[[NSMutableSet alloc] init] autorelease];
    for (ShoppingModel* price in priceList){
        if ([price productId] != nil){
            [productIdSet addObject:[price productId]];
        }
    }
    
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:productIdSet];
    request.delegate = self;
    [request start];
    [request release];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *myProducts = response.products;
    
    for (SKProduct* product in myProducts){
        PPDebug(@"IAP products = %@, %@", [product localizedDescription], [product localizedTitle]);        
    }

    // Populate your UI from the products list.
    // Save a reference to the products list.
}

@end
