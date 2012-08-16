//
//  DiceItemService.m
//  Draw
//
//  Created by 小涛 王 on 12-8-15.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceItemService.h"

static DiceItemService *_defaultService;

@implementation DiceItemService

+ (DiceItemService *)defaultService
{
    if (_defaultService == nil) {
        _defaultService = [[DiceItemService alloc] init];
    }
    
    return _defaultService;
}




@end
