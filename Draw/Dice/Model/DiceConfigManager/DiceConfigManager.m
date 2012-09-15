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
#import "GameConstants.pb.h"

@implementation DiceConfigManager

+ (int)getThresholdCoins:(int)ruleType
{
    int thresholdCoins;
    switch (ruleType) {
        case DiceGameRuleTypeRuleNormal:
            thresholdCoins = [ConfigManager getDiceThresholdCoinWithNormalRule];
            break;
            
        case DiceGameRuleTypeRuleHigh:
            thresholdCoins = [ConfigManager getDiceThresholdCoinWithHightRule];
            break;
            
        case DiceGameRuleTypeRuleSuperHigh:
            thresholdCoins = [ConfigManager getDiceThresholdCoinWithSuperHightRule];
            break;
            
        default:
            
            break;
    }
    
    return thresholdCoins;
}

+ (BOOL)meetJoinGameCondictionWithRuleType:(int)ruleType
{
    int thresholdCoins = [self getThresholdCoins:ruleType];
    
    if ([[AccountService defaultService] getBalance] < thresholdCoins) {
        return NO;
    }else {
        return YES;
    }
}

+ (NSString *)coinsNotEnoughNoteWithRuleType:(int)ruleType
{
    NSString* message;
    int thresholdCoins = [self getThresholdCoins:ruleType];

    if ([ConfigManager wallEnabled]) {
        message = [NSString stringWithFormat:NSLS(@"kCoinsNotEnoughAndGetFreeCoins"), thresholdCoins];
    }else {
        message = [NSString stringWithFormat:NSLS(@"kCoinsNotEnoughAndEnterCoinsShop"), thresholdCoins];
    }
    
    return message;
}


@end
