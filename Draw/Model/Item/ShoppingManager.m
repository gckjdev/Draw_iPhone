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

static ShoppingManager *staticShoppingManager = nil;

@implementation ShoppingManager
+(ShoppingManager *)defaultManager
{
    if (staticShoppingManager == nil) {
        staticShoppingManager = [[ShoppingManager alloc] init];
    }
    return staticShoppingManager;
}
- (NSArray *)getShoppingListFromOutputList:(NSArray *)list type:(SHOPPING_MODEL_TYPE)type
{
    NSMutableArray *array = [[[NSMutableArray alloc] init]autorelease];
    for (NSDictionary *dictionary in list) {
        NSNumber * amount = [dictionary objectForKey:PARA_SHOPPING_AMOUNT];
        NSNumber * value = [dictionary objectForKey:PARA_SHOPPING_VALUE];
        ShoppingModel *model = [[ShoppingModel alloc] initWithType:type count:amount.integerValue price:value.floatValue savePercen:0];
        [array addObject:model];
        [model release];
    }
    return array;
}


@end
