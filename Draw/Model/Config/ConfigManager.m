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

#define ZJH_TIME_INTERVAL 15

@implementation ConfigManager

+ (int)supportRecovery
{
    return [MobClickUtils getIntValueByKey:@"SUPPORT_RECOVERY" defaultValue:1];
}

+ (int)recoveryBackupInterval
{
    return [MobClickUtils getIntValueByKey:@"RECOVERY_BACKUP_INTERVAL" defaultValue:5];
}

+ (int)maxCacheBulletinCount
{
    return [MobClickUtils getIntValueByKey:@"MAX_CACHE_BULLETIN_COUNT" defaultValue:20];
}

+ (NSString*)getSystemUserId
{
    return [MobClickUtils getStringValueByKey:@"SYSTEM_USER_ID" defaultValue:@"888888888888888888888888"];
}

+ (BOOL)isLiarDice
{
    return [[GameApp appId] isEqualToString:DICE_APP_ID];
}

+ (BOOL)isEnableAd
{
    return [MobClickUtils getBoolValueByKey:@"ENABLE_AD" defaultValue:YES];
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


+ (NSInteger)historyRankNumber
{
    return [MobClickUtils getIntValueByKey:@"HISTORY_RANK_NUMBER" defaultValue:300];
}

+ (NSInteger)drawAutoSavePaintTimeInterval
{
    return [MobClickUtils getIntValueByKey:@"DRAFT_PAINT_TIME_INTERVAL" defaultValue:30];   // 30 seconds to save unsaved paint
}

+ (NSInteger)drawAutoSavePaintInterval
{
    return [MobClickUtils getIntValueByKey:@"DRAFT_PAINT_COUNT_1" defaultValue:50];         // 50 paint for save
}

+ (NSInteger)opusDescMaxLength
{
    return [MobClickUtils getIntValueByKey:@"OPUS_DESC_MAX_LENGTH" defaultValue:300];
}

+ (NSInteger)maxPenWidth
{
    NSInteger value = [MobClickUtils getIntValueByKey:@"MAX_PEN_WIDTH" defaultValue:36];
    return ISIPAD ? (value * 2) : value;
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
            
        if ([MobClickUtils getIntValueByKey:@"ENABLE_WALL" defaultValue:1] == 1){            
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
//    return YES;
    return ([MobClickUtils getIntValueByKey:@"WALL_TYPE" defaultValue:WallTypeLimei] == WallTypeLimei);
}

+ (WallType)wallType
{
//    return WallTypeLimei;
    return [MobClickUtils getIntValueByKey:@"NEW_WALL_TYPE" defaultValue:WallTypeLimei];
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
    return [MobClickUtils getIntValueByKey:@"REWARD_SHARE_APP" defaultValue:100];
}

+ (int)getFollowReward
{
    return [MobClickUtils getIntValueByKey:@"FOLLOW_AWARD_COIN" defaultValue:400];
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

+ (int)diceCutAwardForLevelUp
{
    return [MobClickUtils getIntValueByKey:@"REWARD_CUT_FOR_LVL_UP" defaultValue:2];
}

//+ (NSString*)getRecommendAppLinkZh
//{
//    return [MobClickUtils getStringValueByKey:@"ENGLISH_RECOMMEND_APP" defaultValue:@"http://you100.me:8080/dat/app_zh.txt"];
//}
//+ (NSString*)getRecommendAppLinkZht
//{
//    return [MobClickUtils getStringValueByKey:@"CHINESE_SIMPLIFY_APP" defaultValue:@"http://you100.me:8080/dat/app_zht.txt"];
//}
//+ (NSString*)getRecommendAppLinkEn
//{
//    return [MobClickUtils getStringValueByKey:@"CHINESE_TRADITIONAL_APP" defaultValue:@"http://you100.me:8080/dat/app_en.txt"];
//}

//+ (NSString*)getRecommendAppLink
//{
//    if ([LocaleUtils isChina]) {
//        return [ConfigManager getRecommendAppLinkZh];
//    } else  if ([LocaleUtils isOtherChina]){
//        return [ConfigManager getRecommendAppLinkZht];
//    } else {
//        return [ConfigManager getRecommendAppLinkEn];
//    }
//}

+ (BOOL)isShowRecommendApp
{
    return NO;
//    return [MobClickUtils getBoolValueByKey:@"SHOW_RECOMMEND_APP" defaultValue:NO];
}

//+ (NSString*)getFacetimeServerListString
//{
//    return [MobClickUtils getStringValueByKey:@"FACETIME_SERVER_LIST" defaultValue:@"192.168.1.5:8191"];
//}

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

+ (int)getZhajinhuaExp
{
    return [MobClickUtils getIntValueByKey:@"ZJH_EXP" defaultValue:5];
}

+ (int)getDiceFleeCoin
{
    return [MobClickUtils getIntValueByKey:@"DICE_FLEE_COIN_COIN" defaultValue:200];
}

+ (int)getZJHFleeCoin
{
    return [MobClickUtils getIntValueByKey:@"ZJH_FLEE_COIN_COIN" defaultValue:200];
}

+ (int)getDiceThresholdCoinWithNormalRule
{
    return [MobClickUtils getIntValueByKey:@"DICE_THRESHOLD_COIN" defaultValue:200];
}

+ (int)getDiceThresholdCoinWithHightRule
{
    return [MobClickUtils getIntValueByKey:@"DICE_THRESHOLD_COIN_HIGHT" defaultValue:2000];
}

+ (int)getDiceThresholdCoinWithSuperHightRule
{
    return [MobClickUtils getIntValueByKey:@"DICE_THRESHOLD_COIN_SUPER_HIGHT" defaultValue:10000];
}

+ (NSString*)getDiceServerListStringWithNormal
{
//    return @"192.168.1.198:8080";
    return [MobClickUtils getStringValueByKey:@"DICE_SERVER_LIST" defaultValue:@"58.215.164.153:8018"];
}

+ (NSString *)getDiceServerListStringWithHightRule
{
//    return @"58.215.172.169:8019";
    return [MobClickUtils getStringValueByKey:@"DICE_SERVER_LIST_HIGHT" defaultValue:@"58.215.164.153:8019"];
}

+ (NSString *)getDiceServerListStringWithSuperHightRule
{
//    return @"58.215.172.169:8020";
    return [MobClickUtils getStringValueByKey:@"DICE_SERVER_LIST_SUPER_HIGHT" defaultValue:@"58.215.164.153:8020"];
}

+ (NSString*)getZJHServerListStringWithNormal
{
//    return [MobClickUtils getStringValueByKey:@"ZJH_SERVER_LIST_NORMAL" defaultValue:@"192.168.1.5:8027"];
    return [MobClickUtils getStringValueByKey:@"ZJH_SERVER_LIST_NORMAL" defaultValue:@"58.215.184.18:8028"];
}
+ (NSString *)getZJHServerListStringWithRich
{
    return [MobClickUtils getStringValueByKey:@"ZJH_SERVER_LIST_RICH" defaultValue:@"58.215.184.18:8029"];
}
+ (NSString *)getZJHServerListStringWithDual
{
    return [MobClickUtils getStringValueByKey:@"ZJH_SERVER_LIST_DUAL" defaultValue:@"58.215.184.18:8030"];
}

+ (int)getBetAnteWithNormalRule
{
    return [MobClickUtils getIntValueByKey:@"DICE_BET_ANTE_COIN_NORMAL" defaultValue:50];
}

+ (int)getBetAnteWithHighRule
{
    return [MobClickUtils getIntValueByKey:@"DICE_BET_ANTE_COIN_HIGH" defaultValue:100];
}

+ (int)getBetAnteWithSuperHighRule
{
    return [MobClickUtils getIntValueByKey:@"DICE_BET_ANTE_COIN_SUPER_HIGH" defaultValue:200];
}

+ (int)getDailyGiftCoin
{
    return [MobClickUtils getIntValueByKey:@"DAILY_GIFT_COIN" defaultValue:70];
}

+ (int)getDailyGiftCoinIncre
{
    return [MobClickUtils getIntValueByKey:@"DAILY_GIFT_COIN_INCRE" defaultValue:12];
}

+ (NSString*)getAwardItemImageName:(int)dicePoint
{
    return [MobClickUtils getStringValueByKey:@"AWARD_ITEM_IMAGE" defaultValue:[NSString stringWithFormat:@"open_bell_%dbig.png", dicePoint]];
}

+ (int)getPostponeTime
{
    return [MobClickUtils getIntValueByKey:@"POSTPONE_TIME" defaultValue:10];
}

+ (int)getUrgeTime
{
    return [MobClickUtils getIntValueByKey:@"URGE_TIME" defaultValue:5];
}

+ (int)numberOfItemCanUsedOnNormalOpus
{
    return [MobClickUtils getIntValueByKey:@"ITEM_TIMES_ON_NORMAL_OPUS" defaultValue:10];    
}
+ (int)numberOfItemCanUsedOnContestOpus
{
    return [MobClickUtils getIntValueByKey:@"ITEM_TIMES_ON_CONTEST_OPUS"
                              defaultValue:3];
}

+ (int)getZJHTimeInterval
{
    return ZJH_TIME_INTERVAL;
}

+ (int)getTreeMatureTime
{
    return [MobClickUtils getIntValueByKey:@"ZJH_TREE_MATURE_TIME"
                              defaultValue:60];
}

+ (int)getTreeGainTime
{
    return [MobClickUtils getIntValueByKey:@"ZJH_TREE_GAIN_TIME"
                              defaultValue:60];
}

+ (int)getTreeCoinVale
{
    return [MobClickUtils getIntValueByKey:@"ZJH_TREE_COIN_VALUE"
                              defaultValue:25];
}

+ (int)getZJHMaxAutoBetCount
{
    return 5;
}

#pragma mark - draw data version
+ (int)currentDrawDataVersion
{
    return 1;
}


#pragma mark - BBS online attributes
+ (int)getBBSCreationFrequency
{
    return [MobClickUtils getIntValueByKey:@"BBS_CREATE_INTERVAL"
                              defaultValue:10];
}
//support limit
+ (int)getBBSSupportMaxTimes
{
    return [MobClickUtils getIntValueByKey:@"BBS_SUPPORT_TIMES_LIMIT"
                               defaultValue:1];
}

+ (int)getBBSCommentMaxLength
{
    return [MobClickUtils getIntValueByKey:@"BBS_COMMENT_MAX_LENGTH"
                              defaultValue:500];
}

//content
+ (int)getBBSPostMaxLength
{
    return [MobClickUtils getIntValueByKey:@"BBS_POST_MAX_LENGTH"
                              defaultValue:3000];
}
+ (int)getBBSTextMinLength
{
    return [MobClickUtils getIntValueByKey:@"BBS_TEXT_MIN_LENGTH"
                              defaultValue:5];
}

+ (NSString*)getShareImageWaterMark
{
    return [MobClickUtils getStringValueByKey:@"SNS_IMAGE_WATER_MARK" defaultValue:NSLS(@"kDefaultWaterMark")];
}

+ (int)getMaxCountForFetchFreeCoinsOneDay
{
    return  [MobClickUtils getIntValueByKey:@"MAX_COINT_FOR_FETCH_FREE_COINS_ONE_DAY" defaultValue:20];
}

+ (int)getFreeCoinsAward
{
    return  [MobClickUtils getIntValueByKey:@"FREE_COINS_AWARD" defaultValue:50];
}

+ (int)getFreeFlowersAward
{
    return  [MobClickUtils getIntValueByKey:@"FREE_FLOWERS_AWARD" defaultValue:2];
}

+ (int)getFreeTipsAward
{
    return  [MobClickUtils getIntValueByKey:@"FREE_TIPS_AWARD" defaultValue:1];
}

+ (int)getFreeCoinsMoneyTreeGrowthTime
{
    return  [MobClickUtils getIntValueByKey:@"FREE_COINS_MONEY_TREE_GROWTH_TIME" defaultValue:30];
}

+ (int)getFreeCoinsMoneyTreeGainTime
{
    return  [MobClickUtils getIntValueByKey:@"FREE_COINS_MONEY_TREE_GAIN_TIME" defaultValue:60];
}


#define KEY_AUTO_SAVE @"AutoSave"
+ (BOOL)isAutoSave
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:KEY_AUTO_SAVE];
}

+ (void)setAutoSave:(BOOL)isAutoSave
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isAutoSave forKey:KEY_AUTO_SAVE];
    [defaults synchronize];
}


@end
