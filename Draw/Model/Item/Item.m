//
//  Item.m
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Item.h"
#import "ItemType.h"
#import "LocaleUtils.h"

@implementation Item
@synthesize amount = _amount;
@synthesize type = _type;
@synthesize itemImage = _itemImage;
@synthesize itemName = _itemName;
@synthesize itemDescription = _itemDescription;
@synthesize buyAmountForOnce;
@synthesize price;

- (void)dealloc
{
    [_itemName release];
    [_itemImage release];
    [_itemDescription release];
    [super dealloc];
}

- (id)initWithType:(int)type amount:(NSInteger)amount
{
    self = [super init];
    if (self) {
        self.type = type;
        self.amount = amount;
    }
    return self;
}

#define KEY_TYPE @"KEY_TYPE"
#define KEY_AMOUNT @"KEY_AMOUNT"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_type forKey:KEY_TYPE];
    [aCoder encodeInteger:_amount forKey:KEY_AMOUNT];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self){
        self.type = [aDecoder decodeIntegerForKey:KEY_TYPE];
        self.amount = [aDecoder decodeIntegerForKey:KEY_AMOUNT];
    }
    return self;
}

- (id)initWithType:(int)type 
             image:(UIImage*)anImage 
              name:(NSString*)aName 
       description:(NSString*)aDescription 
  buyAmountForOnce:(int)amount 
             price:(int)aPrice
{
    self = [super init];
    if(self){
        self.type = type;
        self.itemImage = anImage;
        self.itemName = aName;
        self.itemDescription = aDescription;
        self.buyAmountForOnce = amount;
        self.price = aPrice;
    }
    return self;
}

+ (Item *)itemWithType:(int)type amount:(NSInteger)amount
{
    return [[[Item alloc] initWithType:type amount:amount]autorelease];
}

+ (Item*)tomato
{
    return [[[Item alloc] initWithType:ITEM_TYPE_TOMATO 
                                 image:[UIImage imageNamed:@"tomato"] 
                                  name:NSLS(@"kTomato") 
                           description:NSLS(@"kTomatoDescription") 
                      buyAmountForOnce:10 
                                 price:500] autorelease];
}

+ (Item*)flower
{
    return [[[Item alloc] initWithType:ITEM_TYPE_FLOWER 
                                 image:[UIImage imageNamed:@"flower"] 
                                  name:NSLS(@"kFlower") 
                           description:NSLS(@"kFlowerDescription") 
                      buyAmountForOnce:10 
                                 price:500] autorelease];
}

+ (Item*)tips
{
    return [[[Item alloc] initWithType:ITEM_TYPE_TIPS 
                                 image:[UIImage imageNamed:@"tipbag"] 
                                  name:NSLS(@"kTips") 
                           description:NSLS(@"kTipsDescription") 
                      buyAmountForOnce:10 
                                 price:500] autorelease];
}

+ (Item*)colors
{
    return [[[Item alloc] initWithType:ITEM_TYPE_COLORS 
                                 image:[UIImage imageNamed:@"print_oil"] 
                                  name:NSLS(@"kColors") 
                           description:NSLS(@"kColorsDescription") 
                      buyAmountForOnce:10 
                                 price:500] autorelease];
}

+ (Item*)removeAd
{
    return [[[Item alloc] initWithType:ITEM_TYPE_REMOVE_AD 
                                 image:[UIImage imageNamed:@"clean_ad"] 
                                  name:NSLS(@"kRemoveAd") 
                           description:NSLS(@"kFlowerDescription") 
                      buyAmountForOnce:10 
                                 price:500] autorelease];
}

+ (Item*)featherPen
{
    return [[[Item alloc] initWithType:ITEM_TYPE_PEN_FEATHER 
                                 image:[UIImage imageNamed:@"quill_pen"] 
                                  name:NSLS(@"kFeather") 
                           description:NSLS(@"kFeatherDescription") 
                      buyAmountForOnce:10 
                                 price:500] autorelease];
}

+ (Item*)brushPen
{
    return [[[Item alloc] initWithType:ITEM_TYPE_PEN_FOUNTAIN 
                                 image:[UIImage imageNamed:@"brush_pen"] 
                                  name:NSLS(@"kPen") 
                           description:NSLS(@"kPenDescription") 
                      buyAmountForOnce:10 
                                 price:500] autorelease];
}

+ (Item*)iceCreamPen
{
    return [[[Item alloc] initWithType:ITEM_TYPE_PEN_ICE_CREAM 
                                 image:[UIImage imageNamed:@"cones_pen"] 
                                  name:NSLS(@"kIceCream") 
                           description:NSLS(@"kIceCreamDescription") 
                      buyAmountForOnce:10 
                                 price:500] autorelease];
}

@end
