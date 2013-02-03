//
//  ShoppingManager.m
//  Draw
//
//  Created by  on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShoppingManager.h"
#import "PriceModel.h"
#import "GameNetworkConstants.h"
#import <StoreKit/StoreKit.h>
#import "CoreDataUtil.h"
#import "PPDebug.h"
#import "MobClick.h"

static ShoppingManager *staticShoppingManager = nil;

@implementation ShoppingManager

@synthesize appleProductList = _appleProductList;

- (void)dealloc
{
    [_appleProductList release];
    [super dealloc];
}

+(ShoppingManager *)defaultManager
{
    if (staticShoppingManager == nil) {
        staticShoppingManager = [[ShoppingManager alloc] init];
        staticShoppingManager.appleProductList = [NSMutableDictionary dictionary];
    }
    return staticShoppingManager;
}

- (SKProduct*)productWithId:(NSString*)product
{
    if (product == nil)
        return nil;
    
    return [_appleProductList objectForKey:product];
}

- (NSArray*)findPriceListByType:(int)type
{
    return [[CoreDataManager defaultManager] execute:@"findPriceListByType" 
                                              forKey:@"TYPE" 
                                               value:[NSNumber numberWithInt:type] 
                                              sortBy:@"seq" 
                                           ascending:YES];
}

- (NSArray*)findCoinPriceList
{
    return [self findPriceListByType:SHOPPING_COIN_TYPE];
}

- (NSArray*)findItemPriceList
{
    return [self findPriceListByType:SHOPPING_ITEM_TYPE];
}

- (PriceModel*)findCoinPriceByProductId:(NSString*)productId
{
    NSArray* coinPriceList = [self findCoinPriceList];        
    for (PriceModel* price in coinPriceList){
        if ([[price productId] isEqualToString:productId]){
            return price;
        }
    }    
    
    return nil;
}

- (void)updateCoinSKProduct:(SKProduct*)product
{
    if (product == nil)
        return;
    
    [self.appleProductList setObject:product forKey:product.productIdentifier];    
}

- (NSArray *)getShoppingListByType:(SHOPPING_MODEL_TYPE)type
{
    return [self findPriceListByType:type];
}

//- (NSArray *)getShoppingListByType:(SHOPPING_MODEL_TYPE)type
//{
//    // TODO, read data locally
//    
//    
//    // Test, simulate data here, shall read from local storage
//    NSMutableArray *array = [[[NSMutableArray alloc] init]autorelease];
//
//    ShoppingModel *model1 = [[[ShoppingModel alloc] initWithType:type 
//                                                         count:400 
//                                                         price:0
//                                                    savePercen:0
//                                                     productId:@"com.orange.draw.coins_400"] autorelease];
//    
//    ShoppingModel *model2 = [[[ShoppingModel alloc] initWithType:type 
//                                                           count:1200 
//                                                           price:0
//                                                      savePercen:0
//                                                       productId:@"com.orange.draw.coins_1200"] autorelease];
//
//    [array addObject:model1];
//    [array addObject:model2]; 
//    
//    self.coinPriceList = array;    
//    return array;
//}

- (void)createPriceModel:(int)type
                   price:(double)price
                   count:(int)count
             savePercent:(int)savePercent
               productId:(NSString*)productId
                     seq:(int)seq
{
    CoreDataManager* dataManager = [CoreDataManager defaultManager];
    PriceModel* priceModel = [dataManager insert:@"PriceModel"];
    
    priceModel.type = [NSNumber numberWithInt:type];
    priceModel.count = [NSNumber numberWithInt:count];
    priceModel.savePercent = [NSNumber numberWithInt:savePercent];
    priceModel.productId = productId;
    priceModel.seq = [NSNumber numberWithInt:seq];
    priceModel.price = [NSNumber numberWithDouble:price];
    
    [dataManager save];
    
    PPDebug(@"<createPriceModel> = (%@)", [priceModel description]);
}



- (NSArray *)getShoppingListFromOutputList:(NSArray *)list type:(SHOPPING_MODEL_TYPE)type
{
    if ([list count] == 0)
        return [self findPriceListByType:type];
    
    // clear all existing data
    CoreDataManager* dataManager = [CoreDataManager defaultManager];
    NSArray* listInDatabase = [self findPriceListByType:type];
    for (PriceModel* price in listInDatabase){
        [dataManager del:price];
    }
    
    // insert new ones        
    NSMutableArray *array = [[[NSMutableArray alloc] init]autorelease];
    int seq = 1;
    for (NSDictionary *dictionary in list) {
        NSNumber * amount = [dictionary objectForKey:PARA_SHOPPING_AMOUNT];
        NSNumber * value = [dictionary objectForKey:PARA_SHOPPING_VALUE];
        NSString * productId = [dictionary objectForKey:PARA_APPLE_IAP_PRODUCT_ID];
        NSNumber * savePercent = [dictionary objectForKey:PARA_SAVE_PERCENT];
//        ShoppingModel *model = [[ShoppingModel alloc] initWithType:type count:amount.integerValue price:value.floatValue savePercen:0 productId:productId];
//        [array addObject:model];
        
        [self createPriceModel:type
                         price:value.floatValue
                         count:amount.integerValue
                   savePercent:savePercent.integerValue
                     productId:productId
                           seq:seq];
        seq ++;
//        [model release];
    }
    return array;
}

#define DEFAULT_COLOR_PRICE     250
#define DEFAULT_PEN_PRICE       400
#define DEFAULT_TOMATO_PRICE    400
#define DEFAULT_FLOWER_PRICE    400
#define DEFAULT_REMOVE_AD_PRICE 400
#define DEFAULT_TIPS_PRICE      400


#define DEFAULT_ROLL_AGAIN_PRICE 2000
#define DEFAULT_CUT_PRICE       1000
#define DEFAULT_PEEK_PRICE       500
#define DEFAULT_POST_PONE_PRICE  500
#define DEFAULT_URGE_PRICE       500
#define DEFAULT_TURTLE_PRICE     1500
#define DEFAULT_DICE_ROBOT_PRICE 500
#define DEFAULT_REVERSE_PRICE    1000

#define DEFAULT_PATRIOT_DICE_PRICE  20000
#define DEFAULT_GOLDEN_DICE_PRICE  20000
#define DEFAULT_WOOD_DICE_PRICE  20000
#define DEFAULT_CRYSAL_DICE_PRICE  20000
#define DEFAULT_DIAMOND_DICE_PRICE  20000

#define DEFAULT_PALETTE_PRICE   4000
#define DEFAULT_ALPHA_PRICE     3000
#define DEFAULT_PAINTA_PLAYER_PRICE 1000

- (NSInteger)getColorPrice
{
    NSString* price = [MobClick getConfigParams:@"COLOR_PRICE"];
    if (price == nil) {
        PPDebug(@"<getColorPrice>: price is nil, return default price = %d",DEFAULT_COLOR_PRICE);
        return DEFAULT_COLOR_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getColorPrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getPenPrice
{
    NSString* price = [MobClick getConfigParams:@"PEN_PRICE"];
    if (price == nil) {
        PPDebug(@"<getPenPrice>: price is nil, return default price = %d",DEFAULT_PEN_PRICE);
        return DEFAULT_PEN_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getPenPrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getPaletteItemPrice
{
    NSString* price = [MobClick getConfigParams:@"PALETTE_PRICE"];
    if (price == nil) {
        PPDebug(@"<getpalettePrice>: price is nil, return default price = %d",DEFAULT_PALETTE_PRICE);
        return DEFAULT_PALETTE_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getpalettePrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getColorAlphaItemPrice
{
    NSString* price = [MobClick getConfigParams:@"ALPHA_PRICE"];
    if (price == nil) {
        PPDebug(@"<getAlphaPrice>: price is nil, return default price = %d",DEFAULT_ALPHA_PRICE);
        return DEFAULT_ALPHA_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getAlphaPrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getPaintPlayerItemPrice
{
    NSString* price = [MobClick getConfigParams:@"PAINT_PLAYER_PRICE"];
    if (price == nil) {
        PPDebug(@"<getPaintPlayerPrice>: price is nil, return default price = %d",DEFAULT_ALPHA_PRICE);
        return DEFAULT_PAINTA_PLAYER_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getPaintPlayerPrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getRollAgainPrice
{
    NSString* price = [MobClick getConfigParams:@"ROLL_AGAIN_PRICE"];
    if (price == nil) {
        PPDebug(@"<getRollAgainPrice>: price is nil, return default price = %d",DEFAULT_ROLL_AGAIN_PRICE);
        return DEFAULT_ROLL_AGAIN_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getRollAgainPrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getCutPrice
{
    NSString* price = [MobClick getConfigParams:@"CUT_PRICE"];
    if (price == nil) {
        PPDebug(@"<getCutPrice>: price is nil, return default price = %d",DEFAULT_CUT_PRICE);
        return DEFAULT_CUT_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getCutPrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getPeekPrice
{
    NSString* price = [MobClick getConfigParams:@"PEEK_PRICE"];
    if (price == nil) {
        PPDebug(@"<getPeekPrice>: price is nil, return default price = %d",DEFAULT_PEEK_PRICE);
        return DEFAULT_PEEK_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getCutPrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getPostPonePrice
{
    NSString* price = [MobClick getConfigParams:@"POST_PONE_PRICE"];
    if (price == nil) {
        PPDebug(@"<getPostPonePrice>: price is nil, return default price = %d",DEFAULT_POST_PONE_PRICE);
        return DEFAULT_POST_PONE_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getPostPonePrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getUrgePrice
{
    NSString* price = [MobClick getConfigParams:@"URGE_PRICE"];
    if (price == nil) {
        PPDebug(@"<getUrgePrice>: price is nil, return default price = %d",DEFAULT_URGE_PRICE);
        return DEFAULT_URGE_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getUrgePrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getTurtlePrice
{
    NSString* price = [MobClick getConfigParams:@"TURTLE_PRICE"];
    if (price == nil) {
        PPDebug(@"<getTurtlePrice>: price is nil, return default price = %d",DEFAULT_TURTLE_PRICE);
        return DEFAULT_TURTLE_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getTurtlePrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getDiceRobotPrice
{
    NSString* price = [MobClick getConfigParams:@"DICE_ROBOT_PRICE"];
    if (price == nil) {
        PPDebug(@"<getDiceRobotPrice>: price is nil, return default price = %d",DEFAULT_DICE_ROBOT_PRICE);
        return DEFAULT_DICE_ROBOT_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getDiceRobotPrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getReversePrice
{
    NSString* price = [MobClick getConfigParams:@"DICE_REVERSE_PRICE"];
    if (price == nil) {
        PPDebug(@"<getReversePrice>: price is nil, return default price = %d",DEFAULT_REVERSE_PRICE);
        return DEFAULT_REVERSE_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getReversePrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getTomatoPrice
{
    NSString* price = [MobClick getConfigParams:@"TOMATO_PRICE"];
    if (price == nil) {
        PPDebug(@"<getTomatoPrice>: price is nil, return default price = %d",DEFAULT_PEN_PRICE);
        return DEFAULT_TOMATO_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getTomatoPrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getFlowerPrice
{
    NSString* price = [MobClick getConfigParams:@"FLOWER_PRICE"];
    if (price == nil) {
        PPDebug(@"<getFlowerPrice>: price is nil, return default price = %d",DEFAULT_PEN_PRICE);
        return DEFAULT_FLOWER_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getFlowerPrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getTipBagPrice
{
    NSString* price = [MobClick getConfigParams:@"TIPBAG_PRICE"];
    if (price == nil) {
        PPDebug(@"<getTipBagPrice>: price is nil, return default price = %d",DEFAULT_PEN_PRICE);
        return DEFAULT_TIPS_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getTipBagPrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getRemoveAdPrice
{
    NSString* price = [MobClick getConfigParams:@"REMOVE_AD_PRICE"];
    if (price == nil) {
        PPDebug(@"<getRemoveAdPrice>: price is nil, return default price = %d",DEFAULT_REMOVE_AD_PRICE);
        return DEFAULT_REMOVE_AD_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getRemoveAdPrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getPatriotDicePrice
{
    NSString* price = [MobClick getConfigParams:@"PATRIOT_DICE_PRICE"];
    if (price == nil) {
        PPDebug(@"<getPatriotDicePrice>: price is nil, return default price = %d",DEFAULT_PATRIOT_DICE_PRICE);
        return DEFAULT_PATRIOT_DICE_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getPatriotDicePrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getGoldenDicePrice
{
    NSString* price = [MobClick getConfigParams:@"GOLDEN_DICE_PRICE"];
    if (price == nil) {
        PPDebug(@"<getPatriotDicePrice>: price is nil, return default price = %d",DEFAULT_GOLDEN_DICE_PRICE);
        return DEFAULT_GOLDEN_DICE_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getPatriotDicePrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getWoodDicePrice
{
    NSString* price = [MobClick getConfigParams:@"WOOD_DICE_PRICE"];
    if (price == nil) {
        PPDebug(@"<getPatriotDicePrice>: price is nil, return default price = %d",DEFAULT_WOOD_DICE_PRICE);
        return DEFAULT_WOOD_DICE_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getPatriotDicePrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}

- (NSInteger)getCrystalDicePrice
{
    NSString* price = [MobClick getConfigParams:@"CRYSAL_DICE_PRICE"];
    if (price == nil) {
        PPDebug(@"<getPatriotDicePrice>: price is nil, return default price = %d",DEFAULT_CRYSAL_DICE_PRICE);
        return DEFAULT_CRYSAL_DICE_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getPatriotDicePrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}


- (NSInteger)getDiamondDicePrice
{
    NSString* price = [MobClick getConfigParams:@"DIAMOND_DICE_PRICE"];
    if (price == nil) {
        PPDebug(@"<getPatriotDicePrice>: price is nil, return default price = %d",DEFAULT_DIAMOND_DICE_PRICE);
        return DEFAULT_DIAMOND_DICE_PRICE;
    }
    NSInteger retPrice = [price integerValue];
    PPDebug(@"<getPatriotDicePrice>: price string = %@,price value = %d",price,retPrice);
    return retPrice;
}



@end
