//
//  DiceConfigManager.m
//  Draw
//
//  Created by 小涛 王 on 12-9-1.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceConfigManager.h"
#import "AccountManager.h"
#import "CommonDialog.h"
#import "ConfigManager.h"
#import "GameConstants.pb.h"

@implementation DiceConfigManager

+ (int)getThresholdCoins:(int)ruleType
{
    int thresholdCoins;
    switch (ruleType) {
            
        case DiceGameRuleTypeRuleHigh:
            thresholdCoins = [ConfigManager getDiceThresholdCoinWithHightRule];
            break;
            
        case DiceGameRuleTypeRuleSuperHigh:
            thresholdCoins = [ConfigManager getDiceThresholdCoinWithSuperHightRule];
            break;
            
        case DiceGameRuleTypeRuleNormal:
        default:
            thresholdCoins = [ConfigManager getDiceThresholdCoinWithNormalRule];
            break;
    }
    
    return thresholdCoins;
}

+ (BOOL)meetJoinGameCondictionWithRuleType:(int)ruleType
{
    int thresholdCoins = [self getThresholdCoins:ruleType];
    
    if ([[AccountManager defaultManager] getBalanceWithCurrency:PBGameCurrencyCoin] < thresholdCoins) {
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
