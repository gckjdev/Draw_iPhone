//
//  DiceAnimationManager.m
//  Draw
//
//  Created by 小涛 王 on 12-8-10.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceAnimationManager.h"

static DiceAnimationManager *_defaultManager = nil;

@implementation DiceAnimationManager

+ (DiceAnimationManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[DiceAnimationManager alloc] init];
    }
    
    return _defaultManager;
}


@end
