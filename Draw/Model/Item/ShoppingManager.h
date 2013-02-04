//
//  ShoppingManager.h
//  Draw
//
//  Created by  on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PriceModel.h"
#import <StoreKit/StoreKit.h>

@interface ShoppingManager : NSObject
{
    
}

@property (nonatomic, retain) NSMutableDictionary *appleProductList;

+(ShoppingManager *)defaultManager;


// coin price handling
- (PriceModel*)findCoinPriceByProductId:(NSString*)productId;
- (void)updateCoinSKProduct:(SKProduct*)product;

- (NSArray *)getShoppingListByType:(SHOPPING_MODEL_TYPE)type;
- (NSArray *)getShoppingListFromOutputList:(NSArray *)list type:(SHOPPING_MODEL_TYPE)type;

- (NSArray*)findCoinPriceList;
- (NSArray*)findItemPriceList;
- (NSInteger)getColorPrice;
- (NSInteger)getPenPrice;
- (NSInteger)getTomatoPrice;
- (NSInteger)getFlowerPrice;
- (NSInteger)getTipBagPrice;
- (NSInteger)getRemoveAdPrice;
- (SKProduct*)productWithId:(NSString*)product;

- (NSInteger)getRollAgainPrice;
- (NSInteger)getCutPrice;
- (NSInteger)getPeekPrice;
- (NSInteger)getPostPonePrice;
- (NSInteger)getUrgePrice;
- (NSInteger)getTurtlePrice;
- (NSInteger)getDiceRobotPrice;
- (NSInteger)getReversePrice;

- (NSInteger)getPatriotDicePrice;
- (NSInteger)getGoldenDicePrice;        
- (NSInteger)getWoodDicePrice;                                     
- (NSInteger)getCrystalDicePrice;                                       
- (NSInteger)getDiamondDicePrice;          

- (NSInteger)getPaletteItemPrice;
- (NSInteger)getColorAlphaItemPrice;
- (NSInteger)getPaintPlayerItemPrice;

@end
