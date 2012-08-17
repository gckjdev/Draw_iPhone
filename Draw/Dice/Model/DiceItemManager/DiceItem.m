//
//  DiceItem.m
//  Draw
//
//  Created by 小涛 王 on 12-8-17.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceItem.h"

@interface DiceItem()
{
    int _itemId;
    NSString *_itemName;
    int _count;
}

@end

@implementation DiceItem

- (void)dealloc
{
    [_itemName release];
    [super dealloc];
}

- (DiceItem *)diceItemWithItemId:(int)itemId
                        itemName:(NSString *)itemName
                           count:(int)count
{
    if (self = [super init]) {
        _itemId = itemId;
        _itemName = [itemName copy];
        _count = count;
    }
    
    return self;
}

- (int)itemId
{
    return _itemId;
}

- (NSString *)itemName
{
    return _itemName; 
}

- (int)count
{
    return _count;
}

@end
