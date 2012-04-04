//
//  ShoppingModel.h
//  Draw
//
//  Created by  on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef enum{
    SHOPPING_COIN_TYPE = 1,
    SHOPPING_ITEM_TYPE = 2
}SHOPPING_MODEL_TYPE;



@interface ShoppingModel : NSObject
{
    SHOPPING_MODEL_TYPE _type;
    NSInteger _count;
    CGFloat _price;
    CGFloat _savePercent;
    SKProduct *_product;
}

@property(nonatomic, assign) SHOPPING_MODEL_TYPE type;
@property(nonatomic, assign) NSInteger count;
@property(nonatomic, assign) CGFloat price;
@property(nonatomic, assign) CGFloat savePercent;
@property(nonatomic, retain) NSString *productId;
@property(nonatomic, retain) SKProduct *product;

- (id)initWithType:(SHOPPING_MODEL_TYPE)type 
             count:(NSInteger)count 
             price:(CGFloat)price 
        savePercen:(CGFloat)savePercent;

- (id)initWithType:(SHOPPING_MODEL_TYPE)type 
             count:(NSInteger)count 
             price:(CGFloat)price 
        savePercen:(CGFloat)savePercent
         productId:(NSString*)productId;

@end
