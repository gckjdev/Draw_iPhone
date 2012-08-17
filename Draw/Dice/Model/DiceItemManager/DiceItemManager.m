//
//  DiceItemManager.m
//  Draw
//
//  Created by 小涛 王 on 12-8-17.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceItemManager.h"
#import "ItemType.h"
#import "LocaleUtils.h"
#import "Item.h"

static DiceItemManager *_defaultManager = nil;

@interface DiceItemManager()

@property (retain, nonatomic) NSArray *itemList;

@end


@implementation DiceItemManager
@synthesize itemList = _itemList;

- (void)dealloc
{
    [_itemList release];
    [super dealloc];
}


+ (DiceItemManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[DiceItemManager alloc] init];
    }
    
    return _defaultManager;
}

- (id)init
{
    if (self = [super init]) {
        
    }
}

- (NSArray *)itemNameList
{
    
}


@end
