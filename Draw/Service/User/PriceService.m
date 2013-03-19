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
    [self fetchCoinProductList:nil];
    [self fetchShoppingListByType:SHOPPING_COIN_TYPE viewController:nil];
    [self fetchShoppingListByType:SHOPPING_ITEM_TYPE viewController:nil];
}

- (void)fetchShoppingListByType:(SHOPPING_MODEL_TYPE)type
                 viewController:(PPViewController<PriceServiceDelegate> *)viewController
{
    if ([viewController respondsToSelector:@selector(didBeginFetchData)]) {
        [viewController didBeginFetchData];
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
    if ([viewController respondsToSelector:@selector(didBeginFetchData)]) {
        [viewController didBeginFetchData];
    }
    
    // read IAP Product Identifier from shopping manager
    NSArray* priceList = [[ShoppingManager defaultManager] getShoppingListByType:SHOPPING_COIN_TYPE];    
    NSMutableSet* productIdSet = [[[NSMutableSet alloc] init] autorelease];
    for (PriceModel* price in priceList){
        if ([price productId] != nil){
            [productIdSet addObject:[price productId]];
        }
    }
    
    // request data from Apple IAP server
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:productIdSet];
    request.delegate = self;
    [request start];
    [request release];
    PPDebug(@"<fetchCoinProductList> Send Query IAP Product for (%@)", [productIdSet description]);
    
    // save delegate for call back
    delegate = viewController;
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
    
    // notify UI to update
    NSArray* coinPriceList = [[ShoppingManager defaultManager] findCoinPriceList];
    if (delegate &&[delegate respondsToSelector:@selector(didFinishFetchShoppingList:resultCode:)]) {
        [delegate didFinishFetchShoppingList:coinPriceList resultCode:0];
    }
}

// Populate your UI from the products list.
// Save a reference to the products list.
- (void)fetchAccountBalanceWithUserId:(NSString *)userId viewController:(id<PriceServiceDelegate> )priceServiceDelegate
{
    if ([priceServiceDelegate respondsToSelector:@selector(didBeginFetchData)]) {
        [priceServiceDelegate didBeginFetchData];
    }
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = nil;        
        output = [GameNetworkRequest fetchAccountBalance:SERVER_URL userId:userId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                NSDecimalNumber *number = (NSDecimalNumber *)output.jsonDataArray;
                int balance = number.integerValue;

                if ([priceServiceDelegate respondsToSelector:@selector(didFinishFetchAccountBalance:resultCode:)]) {
                    [priceServiceDelegate didFinishFetchAccountBalance:balance resultCode:output.resultCode];
                }
            }
        });
        
    });  
}

@end
