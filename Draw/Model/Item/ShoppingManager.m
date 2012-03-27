//
//  ShoppingManager.m
//  Draw
//
//  Created by  on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShoppingManager.h"
#import "ShoppingModel.h"
#import "GameNetworkConstants.h"
#import <StoreKit/StoreKit.h>

static ShoppingManager *staticShoppingManager = nil;

@implementation ShoppingManager

@synthesize coinPriceList = _coinPriceList;

- (void)dealloc
{
    [_coinPriceList release];
    [super dealloc];
}

+(ShoppingManager *)defaultManager
{
    if (staticShoppingManager == nil) {
        staticShoppingManager = [[ShoppingManager alloc] init];
    }
    return staticShoppingManager;
}

- (ShoppingModel*)findCoinPriceByProductId:(NSString*)productId
{
    for (ShoppingModel* price in _coinPriceList){
        if ([[price productId] isEqualToString:productId]){
            return price;
        }
    }    
    
    return nil;
}

- (void)updateCoinSKProduct:(SKProduct*)product
{
    for (ShoppingModel* price in _coinPriceList){
        if ([[price productId] isEqualToString:[product productIdentifier]]){
            // update product in price
            price.product = product;
        }
    }
}

- (NSArray *)getShoppingListByType:(SHOPPING_MODEL_TYPE)type
{
    // TODO, read data locally

    
    // Test, simulate data here, shall read from local storage
    NSMutableArray *array = [[[NSMutableArray alloc] init]autorelease];

    ShoppingModel *model1 = [[[ShoppingModel alloc] initWithType:type 
                                                         count:400 
                                                         price:0
                                                    savePercen:0
                                                     productId:@"com.orange.draw.coins_400"] autorelease];
    
    ShoppingModel *model2 = [[[ShoppingModel alloc] initWithType:type 
                                                           count:1200 
                                                           price:0
                                                      savePercen:0
                                                       productId:@"com.orange.draw.coins_1200"] autorelease];

    [array addObject:model1];
    [array addObject:model2]; 
    
    self.coinPriceList = array;    
    return array;
}


- (NSArray *)getShoppingListFromOutputList:(NSArray *)list type:(SHOPPING_MODEL_TYPE)type
{
    NSMutableArray *array = [[[NSMutableArray alloc] init]autorelease];
    for (NSDictionary *dictionary in list) {
        NSNumber * amount = [dictionary objectForKey:PARA_SHOPPING_AMOUNT];
        NSNumber * value = [dictionary objectForKey:PARA_SHOPPING_VALUE];
        NSString * productId = [dictionary objectForKey:PARA_APPLE_IAP_PRODUCT_ID];
        ShoppingModel *model = [[ShoppingModel alloc] initWithType:type count:amount.integerValue price:value.floatValue savePercen:0 productId:productId];
        [array addObject:model];
        [model release];
    }
    return array;
}


@end
