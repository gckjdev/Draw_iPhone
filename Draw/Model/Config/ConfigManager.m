//
//  ConfigManager.m
//  Draw
//
//  Created by  on 12-4-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ConfigManager.h"

#define KEY_GUESS_DIFF_LEVEL    @"KEY_GUESS_DIFF_LEVEL"

@implementation ConfigManager

+ (int)getGuessRewardNormal
{
    return [MobClickUtils getIntValueByKey:@"REWARD_GUESS_1" defaultValue:3];
}

+ (NSString*)getChannelId
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFChannelId"];
}

+ (NSString*)defaultEnglishServer
{
    return [MobClickUtils getStringValueByKey:@"ENGLISH_SERVER_ADDRESS" defaultValue:@"106.187.89.232"];
}

+ (NSString*)defaultChineseServer
{
    return [MobClickUtils getStringValueByKey:@"CHINESE_SERVER_ADDRESS" defaultValue:@"58.215.190.75"];
}

+ (int)defaultEnglishPort
{
    return [MobClickUtils getIntValueByKey:@"ENGLISH_SERVER_PORT" defaultValue:9000];
}

+ (int)defaultChinesePort
{
    return [MobClickUtils getIntValueByKey:@"CHINESE_SERVER_PORT" defaultValue:9000];
}

+ (int)guessDifficultLevel
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:KEY_GUESS_DIFF_LEVEL] intValue];
}

+ (void)setGuessDifficultLevel:(int)level
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:level] forKey:KEY_GUESS_DIFF_LEVEL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
