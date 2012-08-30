//
//  ConfigManager.m
//  Draw
//
//  Created by  on 12-4-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ConfigManager.h"
#import "LocaleUtils.h"
#import "PPApplication.h"

#define KEY_GUESS_DIFF_LEVEL    @"KEY_GUESS_DIFF_LEVEL"
#define KEY_CHAT_VOICE_ENABLE   @"KEY_CHAT_VOICE_ENABLE"

@implementation ConfigManager

+ (BOOL)isLiarDice
{
    return [[GameApp appId] isEqualToString:DICE_APP_ID];
}

+ (BOOL)isProVersion
{
    return [GameApp disableAd];
}

+ (NSString*)appId
{
    return [GameApp appId];
}

+ (NSString*)gameId
{
    return [GameApp gameId];
}

+ (int)getBalanceDeviation
{
    return [MobClickUtils getIntValueByKey:@"BALANCE_DEVIATION" defaultValue:4000];
}

+ (NSString*)getTrafficAPIServerURL
{
    if ([LocaleUtils isChina]){
        return [MobClickUtils getStringValueByKey:@"TRAFFIC_API_SERVER_CN" defaultValue:@"http://www.place100.com:8100/api/i?"];    
    }
    else{
        return [MobClickUtils getStringValueByKey:@"TRAFFIC_API_SERVER_EN" defaultValue:@"http://www.place100.com:8100/api/i?"];    
    }
}

+ (NSString*)getAPIServerURL
{
    return [MobClickUtils getStringValueByKey:@"API_SERVER_URL" defaultValue:@"http://www.you100.me:8001/api/i?"];        
}


+ (NSString*)getMusicDownloadHomeURL
{
    if ([LocaleUtils isChina]){
        return [MobClickUtils getStringValueByKey:@"MUSIC_HOME_CN" defaultValue:@"http://m.easou.com/col.e?id=112"];
    }
    else{
        return [MobClickUtils getStringValueByKey:@"MUSIC_HOME_EN" defaultValue:@"http://mp3skull.com/"];
    }
}

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
    return [MobClickUtils getStringValueByKey:@"CHINESE_SERVER_ADDRESS" defaultValue:@"www.place100.com"];
}

+ (int)defaultEnglishPort
{
    return [MobClickUtils getIntValueByKey:@"ENGLISH_SERVER_PORT" defaultValue:9000];
}

+ (int)defaultChinesePort
{
    return [MobClickUtils getIntValueByKey:@"CHINESE_SERVER_PORT" defaultValue:9000];
}

+ (GuessLevel)guessDifficultLevel
{
//    NSInteger level = [[[NSUserDefaults standardUserDefaults] objectForKey:KEY_GUESS_DIFF_LEVEL] intValue];
//    if (level == 0) {
    return NormalLevel;
//    }
//    return level;
}

+ (void)setGuessDifficultLevel:(GuessLevel)level
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:level] forKey:KEY_GUESS_DIFF_LEVEL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)enableReview
{
    return ([MobClickUtils getIntValueByKey:@"ENABLE_REVIEW" defaultValue:0] == 1);
}

+ (BOOL)isInReview
{
    return ([MobClickUtils getIntValueByKey:@"IN_REVIEW" defaultValue:0] == 1);    
}

+ (BOOL)isInReviewVersion
{
    NSString* currentVersion = [PPApplication getAppVersion];
    NSString* inReviewVersion = [MobClickUtils getStringValueByKey:@"IN_REVIEW_VERSION" defaultValue:@""];
    if ([inReviewVersion length] > 0){
        return [currentVersion isEqualToString:inReviewVersion];
    }
    else{
        return NO;
    }    
}

+ (ChatVoiceEnable)getChatVoiceEnable
{
    //2012-6-22 update: default without voice
    return EnableNot;
    
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    NSNumber *number = [userDefault objectForKey:KEY_CHAT_VOICE_ENABLE];
//    if (number == nil) {
//        return EnableWifi;
//    }
//    return [number intValue];
}

+ (void)setChatVoiceEnable:(ChatVoiceEnable)enable
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:enable] forKey:KEY_CHAT_VOICE_ENABLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)wallEnabled
{
    if ([ConfigManager isInReviewVersion] == NO && 
        ([LocaleUtils isChina] == YES || 
         [LocaleUtils isOtherChina] == YES)){   
            
        if ([MobClickUtils getIntValueByKey:@"ENABLE_WALL" defaultValue:0] == 1){            
            return YES;
        }            
        else{
            return NO;
        }
    }
    else{
        return NO;
    }
}

+ (BOOL)useLmWall
{
    return ([MobClickUtils getIntValueByKey:@"WALL_TYPE" defaultValue:1] == 1);
}

+ (BOOL)removeAdByIAP
{
    return ([MobClickUtils getIntValueByKey:@"DEL_AD_TYPE" defaultValue:0] == 1);
}

+ (int)getTomatoAwardExp
{
    return [MobClickUtils getIntValueByKey:@"TOMATO_EXP" defaultValue:-5];
}

+ (int)getTomatoAwardAmount
{
    return [MobClickUtils getIntValueByKey:@"TOMATO_AMOUNT" defaultValue:-3];
}

+ (int)getFlowerAwardExp
{
    return [MobClickUtils getIntValueByKey:@"FLOWER_EXP" defaultValue:5];
}

+ (int)getFlowerAwardAmount
{
    return [MobClickUtils getIntValueByKey:@"FLOWER_AMOUNT" defaultValue:3];
}

+ (int)getShareFriendReward
{
    return [MobClickUtils getIntValueByKey:@"REWARD_SHARE_APP" defaultValue:10];
}

+ (int)getShareWeiboReward
{
    return [MobClickUtils getIntValueByKey:@"REWARD_SHARE_WEIBO" defaultValue:10];
}

+ (int)getFollowWeiboReward
{
    return [MobClickUtils getIntValueByKey:@"REWARD_FOLLOW_WEIBO" defaultValue:100];
}
+ (int)flowerAwardFordLevelUp
{
    return [MobClickUtils getIntValueByKey:@"REWARD_FLOWER_FOR_LVL_UP" defaultValue:2];
}

+ (NSString*)getRecommendAppLinkZh
{
    return [MobClickUtils getStringValueByKey:@"ENGLISH_RECOMMEND_APP" defaultValue:@"http://you100.me:8080/dat/app_zh.txt"];
}
+ (NSString*)getRecommendAppLinkZht
{
    return [MobClickUtils getStringValueByKey:@"CHINESE_SIMPLIFY_APP" defaultValue:@"http://you100.me:8080/dat/app_zht.txt"];
}
+ (NSString*)getRecommendAppLinkEn
{
    return [MobClickUtils getStringValueByKey:@"CHINESE_TRADITIONAL_APP" defaultValue:@"http://you100.me:8080/dat/app_en.txt"];
}

+ (NSString*)getRecommendAppLink
{
    if ([LocaleUtils isChina]) {
        return [ConfigManager getRecommendAppLinkZh];
    } else  if ([LocaleUtils isOtherChina]){
        return [ConfigManager getRecommendAppLinkZht];
    } else {
        return [ConfigManager getRecommendAppLinkEn];
    }
}

+ (BOOL)isShowRecommendApp
{
    return [MobClickUtils getBoolValueByKey:@"SHOW_RECOMMEND_APP" defaultValue:NO];
}

+ (NSString*)getFacetimeServerListString
{
    return [MobClickUtils getStringValueByKey:@"FACETIME_SERVER_LIST" defaultValue:@"192.168.1.5:8191"];
}

+ (NSString *)currentVersion
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];  
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleVersion"];
    return currentVersion;
}

+ (int)getOnLineDrawExp
{
    return [MobClickUtils getIntValueByKey:@"ONLINE_DRAW_EXP" defaultValue:15];
}
+ (int)getOnLineGuessExp
{
    return [MobClickUtils getIntValueByKey:@"ONLINE_GUESS_EXP" defaultValue:10];
}
+ (int)getOffLineDrawExp
{
    return [MobClickUtils getIntValueByKey:@"OFFLINE_DRAW_EXP" defaultValue:15];
}
+ (int)getOffLineGuessExp
{
    return [MobClickUtils getIntValueByKey:@"OFFLINE_GUESS_EXP" defaultValue:2];
}
+ (int)getLiarDiceExp
{
    return [MobClickUtils getIntValueByKey:@"LIAR_DICE_EXP" defaultValue:5];
}

+ (int)getDiceFleeCoin
{
    return [MobClickUtils getIntValueByKey:@"DICE_FLEE_COIN_COIN" defaultValue:200];
}
+ (int)getDiceThresholdCoin
{
    return [MobClickUtils getIntValueByKey:@"DICE_THRESHOLD_COIN" defaultValue:400];
}

+ (NSString*)getDiceServerListString
{
    return [MobClickUtils getStringValueByKey:@"DICE_SERVER_LIST" defaultValue:@"106.187.89.232:8018"];
}

@end
