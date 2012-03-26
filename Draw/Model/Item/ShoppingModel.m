//
//  ShoppingModel.m
//  Draw
//
//  Created by  on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShoppingModel.h"


@implementation ShoppingModel
@synthesize price = _price;
@synthesize count = _count;
@synthesize type = _type;
@synthesize savePercent = _savePercent;

- (id)initWithType:(SHOPPING_MODEL_TYPE)type 
             count:(NSInteger)count 
             price:(CGFloat)price 
        savePercen:(CGFloat)savePercent
{
    self = [super init];
    if (self) {
        self.type = type;
        self.count = count;
        self.price = price;
        self.savePercent = savePercent;
    }
    return self;
}

@end
