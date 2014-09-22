//
//  PPConfigManager.m
//  Draw
//
//  Created by  on 12-4-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPConfigManager.h"
#import "LocaleUtils.h"
#import "PPApplication.h"
#import "UserManager.h"
#import "UIUtils.h"
#import "FeedManager.h"
#import "StringUtil.h"

#define KEY_GUESS_DIFF_LEVEL    @"KEY_GUESS_DIFF_LEVEL"
#define KEY_CHAT_VOICE_ENABLE   @"KEY_CHAT_VOICE_ENABLE"

#define ZJH_TIME_INTERVAL 15

#define GET_UMENG_INTVAL(key, intValue) [MobClickUtils getIntValueByKey:key defaultValue:intValue]

#define GET_UMENG_BOOLVALUE(key, boolValue) [MobClickUtils getBoolValueByKey:key defaultValue:boolValue]

#define GET_UMENG_STRVALUE(key, strValue)[MobClickUtils getStringValueByKey:key defaultValue:strValue]

@implementation PPConfigManager

+ (int)defaultHomeControllerFeedType
{
    return [MobClickUtils getIntValueByKey:@"DEFAULT_HOME_CONTROLLER_FEED_TYPE" defaultValue:HotTopIndex];
}

+ (int)defaultHotControllerIndex
{
    return [MobClickUtils getIntValueByKey:@"DEFAULT_HOT_CONTROLLER_INDEX" defaultValue:HotTopIndex];
}

+ (int)maxWeiboShareLength
{
    return [MobClickUtils getIntValueByKey:@"MAX_WEIBO_SHARE_LENGTH" defaultValue:140];
}

+ (NSString*)guessContestShareText
{
    return [MobClickUtils getStringValueByKey:@"GUESS_CONTEST_SHARE_TEXT" defaultValue:NSLS(@"kLookWhatHeDraw")];
}

+ (NSString*)guessContestShareTitleText
{
    return [MobClickUtils getStringValueByKey:@"GUESS_CONTEST_SHARE_TEXT" defaultValue:NSLS(@"kShareGuessTitle")];
}

+ (int)maxTakeNumberCount
{
#ifdef DEBUG
    return 50;
#endif
    
    return [MobClickUtils getIntValueByKey:@"MAX_TAKE_NUMBER_COUNT" defaultValue:5];
}

+ (NSString*)getLimeiWallId
{
    return [MobClickUtils getStringValueByKey:@"LIMEI_WALL_ID" defaultValue:@"69ac217d7a8a8da8f7a90f424f3c9e9f"];   // new wall ID for coins
}

+ (int)supportRecovery
{
    return [MobClickUtils getIntValueByKey:@"SUPPORT_RECOVERY" defaultValue:1];
}

+ (int)recoveryBackupInterval
{
    return [MobClickUtils getIntValueByKey:@"RECOVERY_BACKUP_INTERVAL" defaultValue:30];
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
    return [MobClickUtils getBoolValueByKey:@"ENABLE_AD" defaultValue:NO];
}

+ (BOOL)useSpeedLevel
{
    return [MobClickUtils getBoolValueByKey:@"USE_SPEED_LEVEL" defaultValue:YES];
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

+ (int)getHomeDisplayOpusNumber
{
    return [MobClickUtils getIntValueByKey:@"HOME_DISPLAY_OPUS_NUMBER" defaultValue:9];
}

+ (int)getHomeSwitchOpusInterval
{
    return [MobClickUtils getIntValueByKey:@"HOME_SWITCH_OPUS_INTERVAL" defaultValue:10];
}


+ (int)getBalanceDeviation
{
    return [MobClickUtils getIntValueByKey:@"BALANCE_DEVIATION" defaultValue:4000];
}

+ (int)getPreviewActionCount
{
    return [MobClickUtils getIntValueByKey:@"PREVIEW_ACTION_COUNT" defaultValue:200];
}

+ (NSArray *)getLearnDrawFeedbackEmailList
{
    NSString *string = [MobClickUtils getStringValueByKey:@"LEARN_DRAW_FEEDBACK_EMAILS" defaultValue:@"gckjdev@sina.com;hguangm2009@gmail.com"];
    return [string componentsSeparatedByString:@";"];
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

+ (NSString*)getMessageServerURL
{
#ifdef DEBUG
//    return @"http://58.215.184.18:8699/api/i?";
    //    return @"http://localhost:8100/api/i?";
//    return @"http://192.168.1.12:8100/api/i?";
#endif

    return [MobClickUtils getStringValueByKey:@"MESSAGE_SERVER_URL" defaultValue:@"http://www.place100.com:8300/api/i?"];
}

+ (NSString*)getBBSServerURL
{
#ifdef DEBUG
//    return @"http://58.215.184.18:8699/api/i?";
//    return @"http://localhost:8100/api/i?";
//    return @"http://192.168.1.11:8100/api/i?";
#endif
    
    return [MobClickUtils getStringValueByKey:@"BBS_SERVER_URL" defaultValue:@"http://www.place100.com:8300/api/i?"];
}


+ (NSString*)getGroupServerURL
{
#ifdef DEBUG
//    return @"http://192.168.1.12:8100/api/i?";
//    return @"http://58.215.184.18:8699/api/i?";
//    return @"http://192.168.100.192:8100/api/i?";
//    return @"http://localhost:8100/api/i?";
#endif
    return [MobClickUtils getStringValueByKey:@"GROUP_SERVER_URL" defaultValue:@"http://www.place100.com:8300/api/i?"];
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
//排行榜的数量
+(NSInteger)getRankOpusCountOnce{
    return [MobClickUtils getIntValueByKey:@"RANK_OPUS_FETCH_LIMIT" defaultValue:51];
}

+ (NSInteger)getTimelineCountOnce
{
    return [MobClickUtils getIntValueByKey:@"TIMELINE_FETCH_LIMIT" defaultValue:15];
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

+ (CGFloat)minPenWidth
{
    CGFloat value = [MobClickUtils getFloatValueByKey:@"MIN_PEN_WIDTH" defaultValue:1.0f];
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
#ifdef DEBUG
//    return @"localhost:8080";
//    return @"58.215.172.169:9111";
#endif

    if ([[UserManager defaultManager] getLanguageType] == ChineseType ){
        return [MobClickUtils getStringValueByKey:@"DRAW_SERVER_LIST_CN_NEW" defaultValue:@"58.215.172.169:9000"];
    }
    else{
        return [MobClickUtils getStringValueByKey:@"DRAW_SERVER_LIST_EN_NEW" defaultValue:@"58.215.172.169:9010"];
    }
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
#if DEBUG
    return NO;
#endif
    
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
}

+ (void)setChatVoiceEnable:(ChatVoiceEnable)enable
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:enable] forKey:KEY_CHAT_VOICE_ENABLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)wallEnabled
{
//#ifdef DEBUG
//    return YES;
//#endif
    
    if ([PPConfigManager isInReviewVersion] == NO){               
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

+ (NSInteger)getDrawGridLineSpace
{
    return [MobClickUtils getIntValueByKey:@"GRID_LINE_SPACE" defaultValue:15];
};

+ (int)getTomatoAwardExp
{
    return [MobClickUtils getIntValueByKey:@"TOMATO_EXP" defaultValue:-5];
}

+ (int)getAwardInHappyMode
{
    return [MobClickUtils getIntValueByKey:@"AWARD_COINS_IN_HAPPY_MODE" defaultValue:100];
}

+ (int)getAwardInGeniusMode
{
    return [MobClickUtils getIntValueByKey:@"AWARD_COINS_IN_GENIUS_MODE" defaultValue:500];
}

+ (int)getDeltaAwardInGeniusMode
{
    return [MobClickUtils getIntValueByKey:@"DELTA_COINS_AWARD_IN_GENIUS_MODE" defaultValue:200];
}

+ (int)getDeductCoinsInHappyMode
{
    return [MobClickUtils getIntValueByKey:@"DEDUCT_COINS_IN_HAPPY_MODE" defaultValue:100];
}

+ (int)getDeductCoinsInGeniusMode
{
    return [MobClickUtils getIntValueByKey:@"DEDUCT_COINS_IN_GENIUS_MODE" defaultValue:100];
}

+ (int)getDeductCoinsInContestMode
{
    return [MobClickUtils getIntValueByKey:@"DEDUCT_COINS_IN_CONTEST_MODE" defaultValue:100];
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

+ (int)getCreateOpusWeiboReward
{
    return [MobClickUtils getIntValueByKey:@"CREATE_OPUS_AWARD" defaultValue:30];
}

+ (int)getFirstCreateOpusWeiboReward
{
    return [MobClickUtils getIntValueByKey:@"FIRST_CREATE_OPUS_AWARD" defaultValue:200];
}


+ (int)getFirstGuessOpusReward
{
    return [MobClickUtils getIntValueByKey:@"GUESS_OPUS_AWARD" defaultValue:200];
}



+ (int)getFollowWeiboReward
{
    return [MobClickUtils getIntValueByKey:@"REWARD_FOLLOW_WEIBO" defaultValue:500];
}

+ (int)getShareAppWeiboReward
{
    return [MobClickUtils getIntValueByKey:@"SHARE_APP_WEIBO" defaultValue:100];
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
//        return [PPConfigManager getRecommendAppLinkZh];
//    } else  if ([LocaleUtils isOtherChina]){
//        return [PPConfigManager getRecommendAppLinkZht];
//    } else {
//        return [PPConfigManager getRecommendAppLinkEn];
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
    return [MobClickUtils getDoubleValueByKey:@"PLAY_DRAW_MAX_SPEED" defaultValue:0.1];
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

+ (int)getOffLineGuessAward
{
    return [MobClickUtils getIntValueByKey:@"OFFLINE_GUESS_AWARD" defaultValue:3];
}

+ (int)getOpusNameMaxLength{
    
    return [MobClickUtils getIntValueByKey:@"OPUS_NAME_MAX_LENGTH" defaultValue:7];
}

+ (int)getOpusDescMaxLength{
    return [MobClickUtils getIntValueByKey:@"OPUS_DESC_MAX_LENGTH" defaultValue:4096];
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
//    return @"192.168.1.5:8080";
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
    // version 4 : support, svg image shape
    // version 5 : support shadow, selector, gradient, input text, layers
    // version 6 : support layers
    // version 7 : support eraser with alpha, add brushes
    // version 8 : ???
    return 7;
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
                              defaultValue:6000];
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
                              defaultValue:6000];
}
+ (int)getBBSTextMinLength
{
    return [MobClickUtils getIntValueByKey:@"BBS_TEXT_MIN_LENGTH"
                              defaultValue:5];
}

+ (NSString*)getShareImageWaterMark
{
    return [MobClickUtils getStringValueByKey:@"SNS_IMAGE_WATER_MARK" defaultValue:[UIUtils getAppName]];
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
    
#if DEBUG
    return YES;
#endif
    
    if ([PPConfigManager isInReviewVersion] == NO &&
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
    return @"1.4";
    //Version 1.1 9 Group
    //Version 1.2 +8 Group
    //Version 1.4 = 1.2
}

+ (NSString *)currentImageShapeVersion
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

+ (BOOL)isEnableDomodWall
{
    return [MobClickUtils getBoolValueByKey:@"ENABLE_DOMOD_WALL" defaultValue:YES];
}

+ (NSInteger)getDefaultDetailOpusCount
{
    return  [MobClickUtils getIntValueByKey:@"DEFAULT_DETAIL_OPUS_COUNT" defaultValue:10];
}

+ (NSString*)getFreeIngotPostId
{
    return  [MobClickUtils getStringValueByKey:@"BBS_POST_ID_FREE_INGOT" defaultValue:@"51203af8e4b0b5edbdc36219"];
}

+ (NSString*)getBugReportPostId
{
    return  [MobClickUtils getStringValueByKey:@"BBS_POST_ID_BUG_REPORT" defaultValue:@"50eaa5e2e4b0fa7710d1a820"];
}

+ (NSString*)getFeedbackPostId
{
    return  [MobClickUtils getStringValueByKey:@"BBS_POST_ID_FEEDBACK" defaultValue:@"50eaa5e2e4b0fa7710d1a820"];
}

+ (int)getCoinsIngotRate
{
    return  [MobClickUtils getIntValueByKey:@"COINS_INGOT_RATE" defaultValue:1000];
}

+ (int)getSignatureMaxLen
{
    return  [MobClickUtils getIntValueByKey:@"SIGNATURE_MAX_LEN" defaultValue:400];
}
+ (int)getNicknameMaxLen
{
    return  [MobClickUtils getIntValueByKey:@"NICKNAME_MAX_LEN" defaultValue:60];
}

+ (NSString *)getTaobaoHomeUrl
{
    return [MobClickUtils getStringValueByKey:@"TAOBAO_CHARGE_URL" defaultValue:@"http://shop102713732.m.taobao.com"];
}

#define ALIPAY_PARTNER @"2088901423555415"
#define ALIPAY_SELLER  @"gckjdev@sina.com" // ALIPAY_PARTNER

#define ALIPAY_RSA_PRIVATE_KEY @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAL5KqMc4AL1URSC327Qy85E/iqBVaHD/ZPEyqKCJzImrytIiEECLbHqM6Yb9ZzApln0LppDRaXvViS4Z/59PJwewca0gvkwkc+HeyEe6jdrAgDNuTgxvGAgT9wyTIGynmqt5CMeZn15TOQpZ+xW9kf1ELWHeaygYpshcdAKMYnoxAgMBAAECgYBZue53cWq322J1GPyZrWS32lRNYbhLf8FjEdX9TLyLNdv+1V0Acj2GU6dRpW7ggNuavsGdi4DHiVqTyGKGBdaKsrtXR94BA7sOxWUWJxUppaKY2HLCDjOcHK2c4iFJKcnKK9BlTZGFmF7XDyN2APAy0+rD5tHaGtjY2n+T5aD1gQJBAPBXsKwrdqwUQxep/2JJ2cfrBbmthhOGy9ePqZm+8fv5fJ9qfmDXbYHbsXBiadLrnusI8tVKs8gjmZyZ7EmEuVkCQQDKsD7vTWvMaIvnDAchNtNmqXAWQIGT+CPDCrS96j3SbNfrHCXQsNnjTgJ1TDcJ/u3dGOdPVF9VPj5YhvFi4tSZAkEAwe7gPmzr2zqWULf5vMO+mVSJUCQ2tfbk8NGZlte+xwWvi6sQwu/SCyDM8tRWc71whFK6L2WR4ALp5rVFNqWEMQJAXyEfOKOGr7Z1yygLBJy91ZY6xEbcSj2RU05oDCavg16QbImWef83FIcdgj4WKvvaWgYBMmtwHwsKqfQTwQyjKQJAO2PMKq5Z7BulxRT80S0lzgcTvgrnY0XJ6eqOyEdadDctd4/0623L951EzG4ZP0zf4ftsQ+kbNK5NNY84z+2qOw=="

//#define ALIPAY_ALIPAY_PUBLIC_KEY @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCRlOD4Xgor5mSAovA978ZQMMkIPGE5GYGRTxnF k1puI3N/EXwgiijARIxJs23psCI59vMxcE95lmVo0kyHBG9idAiC9/UebKSUJRGNpmrVa3SXk4Ca APH9fzo8HeagqfwldW0jbhBiiObG/yUb/PCexSw7QK4l7LwmJfekBBxGQQIDAQAB"

#define ALIPAY_ALIPAY_PUBLIC_KEY   @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"


+ (NSString *)getAlipayPartner
{
    return [MobClickUtils getStringValueByKey:@"ALI_PAY_PARTNER" defaultValue:ALIPAY_PARTNER];
}

+ (NSString *)getAlipaySeller
{
    return [MobClickUtils getStringValueByKey:@"ALI_PAY_SELLER" defaultValue:ALIPAY_SELLER];
}

+ (NSString *)getAlipayWebUrl
{    
#ifdef DEBUG
//    return [MobClickUtils getStringValueByKey:@"ALI_PAY_WEB_URL" defaultValue:@"http:/127.0.0.1:9879/api/pay?"];
#endif

    return [MobClickUtils getStringValueByKey:@"ALI_PAY_WEB_URL" defaultValue:@"http://www.you100.me:9879/api/pay?"];
}

+ (NSString *)getAlipayRSAPrivateKey
{
    return [MobClickUtils getStringValueByKey:@"ALI_PAY_RSA_PRIVATE_KEY" defaultValue:ALIPAY_RSA_PRIVATE_KEY];
}

+ (NSString *)getAlipayAlipayPublicKey
{
    return [MobClickUtils getStringValueByKey:@"ALI_PAY_ALIPAY_PUBLIC_KEY" defaultValue:ALIPAY_ALIPAY_PUBLIC_KEY];
}

+ (NSString *)getAlipayNotifyUrl
{
    NSString* url = @"http://www.xxx.com"; //@"http://www.you100.me:9879/alipay/api?m1=notify";
    url = [url encodedURLParameterString];
    
    return [MobClickUtils getStringValueByKey:@"ALI_PAY_NOTIFY_URL"
                                 defaultValue:url];
}

+ (NSString *)getLastAppVersion
{
    return [MobClickUtils getStringValueByKey:@"APP_LAST_VERSION" defaultValue:[UIUtils getAppVersion]];
}

+ (NSString *)getLastAppVersionUpdateLog
{
    if ([LocaleUtils isChina] || [LocaleUtils isChinese]) {
        return [MobClickUtils getStringValueByKey:@"APP_LAST_VERSION_UPDATE_LOG_CHINESE" defaultValue:@""];
    }else{
        return [MobClickUtils getStringValueByKey:@"APP_LAST_VERSION_UPDATE_LOG_ENGLISH" defaultValue:@""];
    }
}

+ (NSString*)getSNSShareSubject
{
    return [MobClickUtils getStringValueByKey:@"SNS_SUBJECT" defaultValue:[GameApp getDefaultSNSSubject]];
}
+ (NSString*)getDrawAppLink
{
    return [MobClickUtils getStringValueByKey:@"DRAW_APP_LINK" defaultValue:NSLS(@"kDrawAppLink")];
}

+ (NSString*)getAppItuneLink
{
    return [MobClickUtils getStringValueByKey:[GameApp appLinkUmengKey] defaultValue:[GameApp appItuneLink]];
}

+ (NSString*)getShareOpusWebLink
{
    return [MobClickUtils getStringValueByKey:@"SHARE_WEB_LINK" defaultValue:@"http://www.xiaoji.fm/opus/%@"];
}



+ (int)getBuyAnswerPrice
{
    return [MobClickUtils getIntValueByKey:@"BUY_ANSWER_PRICE" defaultValue:30];
}

+ (double)getBGMVolume
{
    return [MobClickUtils getDoubleValueByKey:@"BGM_VOLUME" defaultValue:0.0];
}

+ (BOOL)showRestoreButton
{
    return [MobClickUtils getBoolValueByKey:@"SHOW_RESTORE_BUTTON" defaultValue:NO];
}

+ (NSString*)getFeedbackBody
{
    return [NSString stringWithFormat:@"UserId :　%@", [[UserManager defaultManager] userId]];
}

+ (int)maxDrawChineseTitleLen
{
    return [MobClickUtils getIntValueByKey:@"MAX_DRAW_TITLE_LEN_CN" defaultValue:7];
}

+ (int)maxDrawEnglishTitleLen
{
    return [MobClickUtils getIntValueByKey:@"MAX_DRAW_TITLE_LEN_EN" defaultValue:8];
}

+ (float)littleGeeFirstShowOptionsDuration
{
    return [MobClickUtils getFloatValueByKey:@"LITTLE_GEE_FIRST_SHOW_OPTIONS_DURATION" defaultValue:15.0];
}

+ (float)littleGeeShowOptionsDuration
{
    return [MobClickUtils getFloatValueByKey:@"LITTLE_GEE_SHOW_OPTIONS_DURATION" defaultValue:60.0];
}

+ (int)maxShadowDistance
{
    return [MobClickUtils getIntValueByKey:@"MAX_SHADOW_DISTANCE" defaultValue:30];
}
+ (int)maxShadowBlur
{
    return [MobClickUtils getIntValueByKey:@"MAX_SHADOW_BLUR" defaultValue:15];
}
+ (int)cachedActionCount
{
/*
#ifdef DEBUG
    return 6;
#endif
*/
    return [MobClickUtils getIntValueByKey:@"CACHED_ACTION_COUNT" defaultValue:700];
}
+ (int)minUndoActionCount{

//#ifdef DEBUG
//    return 10;
//#endif

    return [MobClickUtils getIntValueByKey:@"MIN_UNDO_ACTION_COUNT" defaultValue:10];
}

+ (BOOL)enableWordFilter
{
    return [MobClickUtils getBoolValueByKey:@"ENABLE_WORD_FILTER" defaultValue:YES];
}

+ (int)getMaxLengthOfDrawDesc{
    return [MobClickUtils getIntValueByKey:@"MAX_LENGTH_OF_DRAW_DESC" defaultValue:4096];
}


#define VIP_LAYER_NUMBER 10

+ (int)getMaxLayerNumber
{
#ifdef DEBUG
        return VIP_LAYER_NUMBER;
#endif
    
    if ([[UserManager defaultManager] isVip]) {
        return [MobClickUtils getIntValueByKey:@"MAX_LAYER_NUMBER_VIP" defaultValue:VIP_LAYER_NUMBER];
    }
    return [MobClickUtils getIntValueByKey:@"MAX_LAYER_NUMBER" defaultValue:4];
}

+ (NSString *)getContestBeginTimeString{
    
    return [MobClickUtils getStringValueByKey:@"CONTEST_BEGIN_TIME_STRING" defaultValue:@"200000"];
}

+ (int)getHotWordAwardCoins{
    return [MobClickUtils getIntValueByKey:@"HOT_WORD_AWARD_COINS" defaultValue:5];

}

+ (int)getFeedCarouselType{
    return [MobClickUtils getIntValueByKey:@"FEED_CAROUSEL_TYPE" defaultValue:8];
}

+ (BOOL)getGuessContestLocalNotificationEnabled{
    return [MobClickUtils getBoolValueByKey:@"GUESS_CONTEST_LOCAL_NOTIFICATION_ENABLED" defaultValue:NO]; // set default to no by Benson
}

+ (int)getHappyGuessExpireTime{
    return [MobClickUtils getIntValueByKey:@"HAPPY_GUESS_EXPIRE_TIME" defaultValue:1];
}

+ (int)getGeniusGuessExpireTime{
    return [MobClickUtils getIntValueByKey:@"GENIUS_GUESS_EXPIRE_TIME" defaultValue:24];
}

+ (int)getGuessRankListCountLoadedAtOnce{
    return [MobClickUtils getIntValueByKey:@"GUESS_RANK_LIST_COUNT_LOADED_AT_ONCE" defaultValue:10];
}

+ (BOOL)showAuthorOnOpus
{
    return [MobClickUtils getBoolValueByKey:@"SHOW_AUTHOR_ON_OPUS" defaultValue:YES];
}

+ (int)getTipUseTimesLimitInGeniusMode{
    
    return [MobClickUtils getIntValueByKey:@"TIP_USE_TIMES_IN_GENIUS_MODE" defaultValue:2];
}

+ (int)getHomeHotOpusCount
{
    return [MobClickUtils getIntValueByKey:@"HOME_HOT_OPUS_COUNT" defaultValue:18];
}

+ (BOOL)showAllPainterTags
{
#ifdef DEBUG
    return YES;
#endif
    
    return [MobClickUtils getBoolValueByKey:@"SHOW_ALL_PAINTER_TAGS" defaultValue:YES];
}

+ (NSString *)getSingTagList{
    
    if ([LocaleUtils isEnglish]) {
     
        return [MobClickUtils getStringValueByKey:@"SING_TAG_LIST" defaultValue:@"Sing$Funny$Story$Imitation$Dialect$Joke"];
    }else{
        return [MobClickUtils getStringValueByKey:@"SING_TAG_LIST" defaultValue:@"唱歌$搞笑$故事$模仿$方言$段子"];
    }
}

+ (int)getRecordLimitTime{
    return [MobClickUtils getIntValueByKey:@"RECORD_LIMIT_TIME" defaultValue:360];
}

+ (int)getRecordLimitMinTime{
    return [MobClickUtils getIntValueByKey:@"RECORD_LIMIT_MIN_TIME" defaultValue:3];
}

+ (int)getRecordDeductCoinsPer30Sec{
    return [MobClickUtils getIntValueByKey:@"RECORD_DEDUCT_COINS_PER_30SEC" defaultValue:1];
}

+ (NSString*)getShareSDKAppId
{
    NSString* defaultValue = [GameApp shareSDKDefaultAppId];    
    return [MobClickUtils getStringValueByKey:@"SHARE_SDK_APP_ID" defaultValue:defaultValue];
}

+ (NSString *)getSingOpusDefaultName{
    
    return [MobClickUtils getStringValueByKey:@"SING_OPUS_DEFAULT_NAME" defaultValue:NSLS(@"kDefaultSingOpusName")];
}





/////GROUP CONSTANT


+ (NSInteger)getGroupCapacityRatio{
    return GET_UMENG_INTVAL(@"GROUP_CAPACITY_RATIO", 10);
}

+ (NSInteger)getGroupGuestCapacityRatio{
    return GET_UMENG_INTVAL(@"GROUP_GUEST_CAPACITY_RATIO", 5);
}

+ (NSInteger)getGroupCreationFeeRatio{
    return GET_UMENG_INTVAL(@"GROUP_CREATION_FEE_RATIO", 100);
}

+ (NSInteger)getGroupNameMaxLength{
    return GET_UMENG_INTVAL(@"GROUP_NAME_MAX_LENGTH", 14);
}

+ (NSInteger)getGroupTitleNameMaxLength{
    return GET_UMENG_INTVAL(@"GROUP_TITLE_NAME_MAX_LENGTH", 14);
}

+ (NSInteger)getGroupIntroduceMaxLength{
    return GET_UMENG_INTVAL(@"GROUP_INTRODUCE_MAX_LENGTH", 500);
}

+ (NSInteger)getGroupSignatureMaxLength{
    return GET_UMENG_INTVAL(@"GROUP_SIGNATURE_MAX_LENGTH", 140);
}

+ (NSInteger)getGroupMaxLevel{
    if([[UserManager defaultManager] isVip]){
        return [self getGroupMaxLevelForVIP];
    }
    return GET_UMENG_INTVAL(@"GROUP_MAX_LEVEL", 20);
}

+ (NSInteger)getGroupMaxLevelForVIP{
    return GET_UMENG_INTVAL(@"GROUP_MAX_LEVEL_VIP", 50);
}

+ (NSInteger)getUserMinLevelForCreateGroup{
    return GET_UMENG_INTVAL(@"MIN_LEVEL_FOR_CREATE_GROUP", 5);
}


+ (NSInteger)getUpgradeGroupFeePerLevel{
    return GET_UMENG_INTVAL(@"UPGRADE_FEE_PER_LEVEL", 100);
}

+ (NSInteger)getQuitGroupFee{
    return GET_UMENG_INTVAL(@"FEE_FOR_QUIT_GROUP", 188);
}

+ (BOOL)isGroupVersionInBeta{
    return GET_UMENG_BOOLVALUE(@"IS_BETA_VERSION_GROUP", YES);
}

+ (NSSet *)getSetFromString:(NSString *)string separater:(NSString *)separater
{
    if ([string length] == 0) return nil;
    NSArray *list = [string componentsSeparatedByString:@";"];
    if([list count] == 0)return nil;
    NSSet *set = [NSSet setWithArray:list];
    return set;
}

+ (NSSet *)getGroupTestUserIdSet{
    NSString *idListString = GET_UMENG_STRVALUE(@"GROUP_TEST_USERID_LIST", @"");
    return [self getSetFromString:idListString separater:@";"];
}

+ (int)getGroupContestMinTotalAward{
    
    return GET_UMENG_INTVAL(@"GROUP_CONTEST_MIN_TOTAL_AWARD", 5000);
}

+ (int)getMinGroupContestAward
{
    return GET_UMENG_INTVAL(@"MIN_GROUP_CONTEST_AWARD", 10000);
}

+ (int)getVipMonthFee
{
    return GET_UMENG_INTVAL(@"VIP_MONTH_FEE", 10);
}

+ (int)getVipYearFee
{
    return GET_UMENG_INTVAL(@"VIP_YEAR_FEE", 99);
}

+ (NSString*)getVipYearTaobaoURL
{
    return GET_UMENG_STRVALUE(@"VIP_YEAR_TAOBAO", @"http://a.m.taobao.com/i37241322828.htm");
}

+ (NSString*)getVipMonthTaobaoURL
{
    return GET_UMENG_STRVALUE(@"VIP_MONTH_TAOBAO", @"http://a.m.taobao.com/i37241999720.htm");
}

+ (BOOL)useAlipyaWeb
{
    return GET_UMENG_BOOLVALUE(@"USE_ALIPAY_WEB", YES);
}

+ (BOOL)showLinkInShare
{
    return GET_UMENG_BOOLVALUE(@"SHOW_LINK_IN_SHARE", NO);
}

+ (BOOL)showOpusLinkInShare
{
    return GET_UMENG_BOOLVALUE(@"SHOW_OPUS_LINK_IN_SHARE", YES);
}

+ (NSString*)xiaojiWeb
{
    return GET_UMENG_STRVALUE(@"XIAOJI_WEB", @"http://www.xiaoji.fm");
}

+ (int)boardManagerBlackUserDays
{
    return GET_UMENG_INTVAL(@"BLACK_USER_MAX_DAYS", 7);
}

+ (int)getCheckInAwardFirstDay
{
    return GET_UMENG_INTVAL(@"CHECKIN_FIRST", 100);
}

+ (int)getCheckInAwardAddPerDay
{
    return GET_UMENG_INTVAL(@"CHECKIN_ADD", 100);
}

+ (int)maxCheckInDays
{
    return GET_UMENG_INTVAL(@"CHECKIN_ADD", 5);
}

+ (BOOL)enableComeback
{
    return GET_UMENG_BOOLVALUE(@"COMEBACK", YES);
}

+ (int)comebackDays
{
    return GET_UMENG_INTVAL(@"COMEBACK_DAYS", 3);
}

+ (NSString*)comebackMessage
{
    return GET_UMENG_STRVALUE(@"COMEBACK_DAYS", @"自上次登录后，你已经有好几天没有来小吉，快回来吧，更多精彩等着你 (^v^)");
}

+ (BOOL)enableSplashAd
{
//#ifdef DEBUG
//    return YES;
//#endif
    
    return GET_UMENG_BOOLVALUE(@"SPLASH_AD", NO);
}

+ (BOOL)enableCacheSplash
{
    return GET_UMENG_BOOLVALUE(@"SPLASH_AD_CACHE", NO);
}

+ (NSString*)splashAdPublisherId
{
    return GET_UMENG_STRVALUE(@"SPLASH_AD_PUB_ID", @"56OJz8QIuMyvO2LjPI");
}

+ (NSString*)splashAdPlacementId
{
    return GET_UMENG_STRVALUE(@"SPLASH_AD_ID", @"16TLmCOoAcaIONUEOHEOnqoz");
}

+ (NSString*)defaultDrawWord
{
    if ([LocaleUtils isChina]){
        return GET_UMENG_STRVALUE(@"DRAW_WORD", @"");
    }
    else{
        return @"";
    }
}

+ (int)maxDisplaySpendTime
{
    return GET_UMENG_INTVAL(@"MAX_DIS_SPEND_TIME", 8); // unit is hours
}

+ (int)maxDisplayStrokes
{
    return GET_UMENG_INTVAL(@"MAX_DIS_STROKES", 1000000); // 1,000,000 strokes for max
}

+ (int)maxOpusClassSelectCount
{
    return GET_UMENG_INTVAL(@"MAX_CLASS_PER_OPUS", 2); // 1,000,000 strokes for max
}

+ (NSString*)getTutorialServerURL
{
#ifdef DEBUG
    //    return @"http://192.168.1.12:8100/api/i?";
//    return @"http://58.215.184.18:8699/api/i?";
    //    return @"http://192.168.100.192:8100/api/i?";
//    return @"http://localhost:8100/api/i?";
#endif
    
    return [MobClickUtils getStringValueByKey:@"TUTORIAL_SERVER_URL" defaultValue:@"http://www.place100.com:8300/api/i?"];
}

+(NSInteger)getMinStrokeNum
{
    //限制用户提交时的笔画数量，需要测试
    return GET_UMENG_INTVAL(@"MIN_L_STROKE", 5);
}

+(NSInteger)getMinPointNum
{
    //计算笔画是否过短，需要测试
    return GET_UMENG_INTVAL(@"MIN_L_POINT", 2);
}

+ (NSString*)shareAppName
{
    return GET_UMENG_STRVALUE(@"SHARE_APP_NAME", [UIUtils getAppName]);
}

+ (CGFloat)getGIFDelayTime
{
    return GET_UMENG_INTVAL(@"GIF_DELAY", 38)*1.0f / 100.0f;
}

+ (int)getGIFFrameCount
{
    return GET_UMENG_INTVAL(@"GIF_FRAME", 30);
}

+ (int)maxGIFFrame
{
    return GET_UMENG_INTVAL(@"MAX_GIF_FRAME", 100);
}

+ (CGFloat)getGIFScaleSize
{
    return GET_UMENG_INTVAL(@"GIF_SCALE", 50)*1.0f / 100.0f;
}

+ (int)defaultHomeStyleOldUser
{
    if (isLittleGeeAPP()){
        return GET_UMENG_INTVAL(@"HOMESTYLE_OLD", HOME_STYLE_CLASSICAL);
    }
    else{
        return GET_UMENG_INTVAL(@"HOMESTYLE_OLD", HOME_STYLE_CLASSICAL);
    }
}

+ (int)defaultHomeStyleNewUser
{
    if (isLittleGeeAPP()){
        return GET_UMENG_INTVAL(@"HOMESTYLE_NEW", HOME_STYLE_CLASSICAL);
    }
    else{
        return GET_UMENG_INTVAL(@"HOMESTYLE_NEW", HOME_STYLE_CLASSICAL);
    }
}


+ (NSString*)getDefaultTutorialId
{
    return GET_UMENG_STRVALUE(@"DEFAULT_TUTORIAL", @""); // @"tutorialId-2$$tutorialId-1");
}

@end
