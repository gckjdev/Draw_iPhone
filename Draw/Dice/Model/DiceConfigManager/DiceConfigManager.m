//
//  DiceConfigManager.m
//  Draw
//
//  Created by 小涛 王 on 12-9-1.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceConfigManager.h"
#import "AccountService.h"
#import "CommonDialog.h"
#import "ConfigManager.h"

#define DICE_THRESHOLD_COIN ([ConfigManager getDiceThresholdCoin])

@implementation DiceConfigManager


+ (BOOL)meetJoinGameCondiction
{
    if ([[AccountService defaultService] getBalance] <= DICE_THRESHOLD_COIN) {
        return NO;
    }else {
        return YES;
    }
}

+ (NSString *)coinsNotEnoughNote
{
    NSString* message;
    if ([ConfigManager wallEnabled]) {
        message = [NSString stringWithFormat:NSLS(@"kCoinsNotEnoughAndGetFreeCoins"), DICE_THRESHOLD_COIN];
    }else {
        message = [NSString stringWithFormat:NSLS(@"kCoinsNotEnoughAndEnterCoinsShop"), DICE_THRESHOLD_COIN];
    }
    
    return message;
}


@end
