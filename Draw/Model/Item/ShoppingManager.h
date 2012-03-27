//
//  ShoppingManager.h
//  Draw
//
//  Created by  on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ShoppingModel.h"

@interface ShoppingManager : NSObject
{
    
}

@property (nonatomic, retain) NSArray *coinPriceList;

+(ShoppingManager *)defaultManager;


// coin price handling
- (ShoppingModel*)findCoinPriceByProductId:(NSString*)productId;
- (void)updateCoinSKProduct:(SKProduct*)product;

- (NSArray *)getShoppingListByType:(SHOPPING_MODEL_TYPE)type;
- (NSArray *)getShoppingListFromOutputList:(NSArray *)list type:(SHOPPING_MODEL_TYPE)type;

@end
