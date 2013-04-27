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
#import "SKProduct+LocalizedPrice.h"
#import "IAPProductManager.h"

static PriceService* staticPriceService = nil;

@implementation PriceService


+ (PriceService *)defaultService
{
    if (staticPriceService == nil) {
        staticPriceService = [[PriceService alloc] init];
    }
    return staticPriceService;
}

- (void)syncShoppingListAtBackground
{
    [self fetchCoinProductList];
//    [self fetchShoppingListByType:SHOPPING_COIN_TYPE];
//    [self fetchShoppingListByType:SHOPPING_ITEM_TYPE];
}

//- (void)fetchShoppingListByType:(SHOPPING_MODEL_TYPE)type
//{
//    dispatch_async(workingQueue, ^{
//        
//        CommonNetworkOutput* output = nil;        
//        output = [GameNetworkRequest fetchShoppingList:SERVER_URL type:type];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (output.resultCode == ERROR_SUCCESS) {
//                [[ShoppingManager defaultManager] getShoppingListFromOutputList:output.jsonDataArray type:type];
//            }
//        });
//        
//    });
//}

- (void)fetchCoinProductList
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
    PPDebug(@"<fetchCoinProductList> Send Query IAP Product for (%@)", [productIdSet description]);
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    // update SKProduct in coin price list
    NSArray *myProducts = response.products;    
    for (SKProduct* product in myProducts){
        PPDebug(@"<didReceiveResponse> IAP products = %@, %@, %@", 
                [product localizedDescription], 
                [product localizedTitle],
                [product localizedPrice]);          
        [[ShoppingManager defaultManager] updateCoinSKProduct:product];
    }
}

@end
