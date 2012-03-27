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

- (void)fetchAccountBalanceWithUserId:(NSString *)userId viewController:(PPViewController<PriceServiceDelegate> *)viewController
{
    if ([viewController respondsToSelector:@selector(didBeginFetchData)]) {
        [viewController didBeginFetchData];
    }
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = nil;        
        output = [GameNetworkRequest fetchAccountBalance:SERVER_URL userId:userId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS) {
                NSDecimalNumber *number = (NSDecimalNumber *)output.jsonDataArray;
                int balance = number.integerValue;
//                int balance =[[ShoppingManager defaultManager] getBalanceFromOutputList:output.jsonDataArray];
                if ([viewController respondsToSelector:@selector(didFinishFetchAccountBalance:resultCode:)]) {
                    [viewController didFinishFetchAccountBalance:balance resultCode:output.resultCode];
                }
            }
        });
        
    });  
}

@end
