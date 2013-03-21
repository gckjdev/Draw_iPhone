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
#import "UserManager.h"

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

+ (NSInteger)getHotOpusCountOnce
{
    return [MobClickUtils getIntValueByKey:@"HOT_OPUS_FETCH_LIMIT" defaultValue:18];
}
+ (NSInteger)getTimelineCountOnce
{
    return [MobClickUtils getIntValueByKey:@"TIMELINE_FETCH_LIMIT" defaultValue:12];
}
+ (BOOL)showOpusCount
{
    return [MobClickUtils getBoolValueByKey:@"SHOW_OPUS_COUNT" defaultValue:NO];
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

+ (double)minAlpha
{
    double value = [MobClickUtils getDoubleValueByKey:@"MIN_ALPHA" defaultValue:0.05];
    return value;
}


+ (NSInteger)maxPenWidth
{
    NSInteger value = [MobClickUtils getIntValueByKey:@"MAX_PEN_WIDTH" defaultValue:36];
    return ISIPAD ? (value * 2) : value;
}

+ (NSInteger)defaultPenWidth
{
    NSInteger value = [MobClickUtils getIntValueByKey:@"DEFAULT_PEN_WIDTH" defaultValue:6];
    return ISIPAD ? (value * 2) : value;    
}

+ (NSInteger *)penWidthList;
{
    static int bList[10] = {0};
    NSString *bonusList = [MobClickUtils getStringValueByKey:@"PEN_WIDTH_LIST" defaultValue:@"1,6,12,20,32"];
    NSArray *list = [bonusList componentsSeparatedByString:@","];
    int i = 0;
    for (NSInteger j = [list count] - 1; j >= 0; -- j) {
        NSInteger value = [[list objectAtIndex:j] integerValue];
        if ([DeviceDetection isIPAD]) {
            value *= 2;
        }
        bList[i++] = value;
    }
    bList[i] = -1;
    return bList;
}

+ (NSInteger)getMessageStatMaxCount
{
    NSInteger value = [MobClickUtils getIntValueByKey:@"MESSAGE_STAT_MAX_COUNT" defaultValue:30];
    return value;
}
/*
+ (int)getGuessRewardNormal
{
    return [MobClickUtils getIntValueByKey:@"REWARD_GUESS_1" defaultValue:3];
}
*/

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

+ (NSString*)getDrawServerString
{
//    
//    return @"192.168.1.198:8080";
    
    if ([[UserManager defaultManager] getLanguageType] == ChineseType ){        
        return [MobClickUtils getStringValueByKey:@"DRAW_SERVER_LIST_CN" defaultValue:@"58.215.172.169:9000"];
    }
    else{
        return [MobClickUtils getStringValueByKey:@"DRAW_SERVER_LIST_EN" defaultValue:@"58.215.172.169:9010"];
    }
}

/*

 5.8版本即将发布，先公告一下功能特性给大家：1) 解决了回放作品有竖线的问题； 2) 提供了回放播放器； 3) 画画增加了五种默认粗细，可直接选择； 4) 画画支持取色； 5) 在线猜画可以显示所有房间列表，可以自由选择房间加入； 6) 修复了创建自定义词闪退的问题； 7) 解决了画画比赛保存为草稿后无法提交的问题； 8) 增加画画上传进度的显示，支持直接分享到微博； 9) iPhone和iPod Touch也支持透明度了。
 
 
 */

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

+ (double)getOnlinePlayDrawSpeed
{
    return [MobClickUtils getDoubleValueByKey:@"ONLINE_PLAY_SPEED" defaultValue:0.03];
}
+ (double)getMaxPlayDrawSpeed
{
    return [MobClickUtils getDoubleValueByKey:@"PLAY_DRAW_MAX_SPEED" defaultValue:0.05];
}
+ (double)getMinPlayDrawSpeed
{
    return [MobClickUtils getDoubleValueByKey:@"PLAY_DRAW_MIN_SPEED" defaultValue:0.001];
}
+ (double)getDefaultPlayDrawSpeed
{
    return [MobClickUtils getDoubleValueByKey:@"PLAY_DRAW_DEFAULT_SPEED" defaultValue:0.005];
}


+ (int)getOnLineDrawExp
{
    return [MobClickUtils getIntValueByKey:@"ONLINE_DRAW_EXP" defaultValue:5];//15 --> 5 ,2013.3.2  --kira
}

+ (int)getOnLineGuessExp
{
    return [MobClickUtils getIntValueByKey:@"ONLINE_GUESS_EXP" defaultValue:2];//10 --> 2 ,2013.3.2  --kira
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
    if (([LocaleUtils isChina] == YES ||
         [LocaleUtils isOtherChina] == YES)){
    
        return [MobClickUtils getStringValueByKey:@"ZJH_SERVER_LIST_NORMAL" defaultValue:@"58.215.164.153:8028"];
    }
    else{
        return [MobClickUtils getStringValueByKey:@"ZJH_EN_SERVER_LIST_NORMAL" defaultValue:@"58.215.164.153:8028"];
    }
}
+ (NSString *)getZJHServerListStringWithRich
{
    if (([LocaleUtils isChina] == YES ||
         [LocaleUtils isOtherChina] == YES)){
        
        return [MobClickUtils getStringValueByKey:@"ZJH_SERVER_LIST_RICH" defaultValue:@"58.215.164.153:8029"];
    }
    else{
        return [MobClickUtils getStringValueByKey:@"ZJH_EN_SERVER_LIST_RICH" defaultValue:@"58.215.164.153:8029"];
    }
}
+ (NSString *)getZJHServerListStringWithDual
{
    if (([LocaleUtils isChina] == YES ||
         [LocaleUtils isOtherChina] == YES)){
        
        return [MobClickUtils getStringValueByKey:@"ZJH_SERVER_LIST_DUAL" defaultValue:@"58.215.164.153:8030"];
    }
    else{
        return [MobClickUtils getStringValueByKey:@"ZJH_EN_SERVER_LIST_DUAL" defaultValue:@"58.215.164.153:8030"];
    }
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
    return [MobClickUtils getStringValueByKey:@"AWARD_ITEM_IMAGE" defaultValue:[NSString stringWithFormat:@"open_bell_%dbigx2.png", dicePoint]];
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
    // version 0 : old
    // version 1 : support alpha
    // version 2 : support pens, new data compress //never release
    // version 3 : support shape, draw bg, scale, new  data compress
    return 3;
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

#define BONUS_LIST_END (-1)

+ (int *)getBBSRewardBounsList
{
//    BBS_REWARD_BONUS
    static int bList[10] = {0};
    NSString *bonusList = [MobClickUtils getStringValueByKey:@"BBS_REWARD_BONUS" defaultValue:@"100,300,500,1000"];
    NSArray *list = [bonusList componentsSeparatedByString:@","];
    int i = 1;
    for (NSString *value in list) {
        bList[i++] = [value integerValue];
    }
    //set the list start and end.
    bList[i] = BONUS_LIST_END;
    return bList;
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

+ (BOOL)freeCoinsEnabled
{
    if ([ConfigManager isInReviewVersion] == NO &&
        ([LocaleUtils isChina] == YES ||
         [LocaleUtils isOtherChina] == YES)){
            
            if ([MobClickUtils getIntValueByKey:@"FREE_COINS_ENABLED" defaultValue:1] == 1){
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


+ (int)offlineGuessAwardScore
{
    return [MobClickUtils getIntValueByKey:@"GUESS_WORD_SCORE" defaultValue:3];
}

+ (int)offlineDrawMyWordScore
{
    return [MobClickUtils getIntValueByKey:@"DRAW_MY_WORD_SCORE" defaultValue:2];
}

+ (int)offlineDrawSystemWordScore
{
    return [MobClickUtils getIntValueByKey:@"DRAW_SYSTEM_WORD_SCORE" defaultValue:2];
}

+ (int)offlineDrawHotWordScore
{
    return [MobClickUtils getIntValueByKey:@"DRAW_HOT_WORD_SCORE" defaultValue:6];
}

+ (int)getLevelUpAward
{
    return [MobClickUtils getIntValueByKey:@"LEVEL_UP_AWARD" defaultValue:400];
}

+ (int)getOnlineDrawFleeCoin
{
    return [MobClickUtils getIntValueByKey:@"ONLINE_DRAW_FLEE_COIN" defaultValue:5];
}

+ (int)onlineRoomCountPerPage
{
    return [MobClickUtils getIntValueByKey:@"ONLINE_ROOM_COUNT_PER_PAGE" defaultValue:25];
}

+ (int)maxWeixinImageWidth
{
    return [MobClickUtils getIntValueByKey:@"MAX_WEIXIN_IMAGE_WIDTH" defaultValue:320];
}

+ (NSString*)getAdMobId
{
    return [MobClickUtils getStringValueByKey:@"ADMOB_ID" defaultValue:@"a14fed16c562e5d"];
}

// http://58.215.164.153:8100/api/i?&m=delf&app=513819630&fid=51087c79e4b0d9b30df33cb9&uid=50b4596fe4b03dc20a9e7e51
// http://58.215.164.153:8100/api/i?&m=delf&app=513819630&fid=51087c32e4b0d9b30df33c94&uid=50b4596fe4b03dc20a9e7e51



+ (int)maxTotalBetWithNormalRule
{
    return  [MobClickUtils getIntValueByKey:@"MAX_TOTAL_BET_WITH_NORMAL_RULE" defaultValue:50000];
}

+ (int)maxTotalBetWithDualRule
{    return  [MobClickUtils getIntValueByKey:@"MAX_TOTAL_BET_WITH_DUAL_RULE" defaultValue:500000];
}

+ (int)maxTotalBetWithRichRule
{
    return  [MobClickUtils getIntValueByKey:@"MAX_TOTAL_BET_WITH_RICH_RULE" defaultValue:500000];
}

+ (BOOL)showBetViewEnabled
{
    return [MobClickUtils getIntValueByKey:@"BET_VIEW_ENABLED" defaultValue:1];
}

+ (NSString *)currentDrawBgVersion
{
    return @"1.0";
}

+ (BOOL)isEnableLimeiWall
{
    return [MobClickUtils getBoolValueByKey:@"ENABLE_LIMEI_WALL" defaultValue:YES];
}

+ (BOOL)isEnableYoumiWall
{
    return [MobClickUtils getBoolValueByKey:@"ENABLE_YOUMI_WALL" defaultValue:YES];
}


+ (BOOL)isEnableWanpuWall
{
    return [MobClickUtils getBoolValueByKey:@"ENABLE_WANPU_WALL" defaultValue:YES];
}

+ (BOOL)isEnableAderWall
{
    return [MobClickUtils getBoolValueByKey:@"ENABLE_ADER_WALL" defaultValue:YES];
}

+ (BOOL)isEnableTapjoyWall
{
    return [MobClickUtils getBoolValueByKey:@"ENABLE_TAPJOY_WALL" defaultValue:YES];
}


@end
