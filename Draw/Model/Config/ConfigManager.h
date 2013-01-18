//
//  ConfigManager.h
//  Draw
//
//  Created by  on 12-4-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobClickUtils.h"

typedef enum{
    
    EasyLevel = 1,
    NormalLevel = 2,
    HardLevel = 3
    
}GuessLevel;

typedef enum{
    EnableAlways = 1,
    EnableWifi = 2,
    EnableNot = 3
}ChatVoiceEnable;

typedef enum{
    WallTypeLimei = 1,
    WallTypeWanpu = 2
}WallType;

@interface ConfigManager : NSObject

+ (int)getBalanceDeviation;

//+ (int)getGuessRewardNormal;

+ (NSInteger)historyRankNumber;
+ (NSInteger)drawAutoSavePaintInterval;//DRAFT_PAINT_COUNT
+ (NSInteger)opusDescMaxLength;
+ (NSInteger)maxPenWidth;

+ (NSString*)getChannelId;

+ (NSString*)defaultEnglishServer;
+ (NSString*)defaultChineseServer;
+ (int)defaultEnglishPort;
+ (int)defaultChinesePort;

+ (GuessLevel)guessDifficultLevel;
+ (void)setGuessDifficultLevel:(GuessLevel)level;

+ (ChatVoiceEnable)getChatVoiceEnable;
+ (void)setChatVoiceEnable:(ChatVoiceEnable)enable;

+ (BOOL)enableReview;

+ (NSString*)getAPIServerURL;
+ (NSString*)getTrafficAPIServerURL;
+ (NSString*)getMusicDownloadHomeURL;


+ (BOOL)isInReview;
+ (BOOL)isInReviewVersion;

+ (BOOL)wallEnabled;

+ (BOOL)isLiarDice;
+ (BOOL)isProVersion;
+ (NSString*)appId;

+ (BOOL)removeAdByIAP;
+ (BOOL)useLmWall;

+ (NSString*)gameId;

+ (int)getTomatoAwardExp;
+ (int)getTomatoAwardAmount;
+ (int)getFlowerAwardExp;
+ (int)getFlowerAwardAmount;

+ (int)getShareFriendReward;
+ (int)getShareWeiboReward;
+ (int)getFollowWeiboReward;

+ (int)flowerAwardFordLevelUp;
+ (int)diceCutAwardForLevelUp;

+ (NSString*)getSystemUserId;

+ (int)maxCacheBulletinCount;

/*
+ (NSString*)getRecommendAppLinkZh;
+ (NSString*)getRecommendAppLinkZht;
+ (NSString*)getRecommendAppLinkEn;
+ (NSString*)getRecommendAppLink;
 + (NSString*)getFacetimeServerListString;
*/

+ (BOOL)isShowRecommendApp;
+ (NSString *)currentVersion;

+ (int)getOnLineDrawExp;
+ (int)getOnLineGuessExp;
+ (int)getOffLineDrawExp;
+ (int)getOffLineGuessExp;
+ (int)getLiarDiceExp;
+ (int)getZhajinhuaExp;

+ (int)getDiceFleeCoin;
+ (int)getZJHFleeCoin;

+ (int)getDiceThresholdCoinWithNormalRule;
+ (int)getDiceThresholdCoinWithHightRule;
+ (int)getDiceThresholdCoinWithSuperHightRule;

+ (NSString*)getDiceServerListStringWithNormal;
+ (NSString *)getDiceServerListStringWithHightRule;
+ (NSString *)getDiceServerListStringWithSuperHightRule;

+ (NSString*)getZJHServerListStringWithNormal;
+ (NSString *)getZJHServerListStringWithRich;
+ (NSString *)getZJHServerListStringWithDual;

+ (int)getBetAnteWithNormalRule;
+ (int)getBetAnteWithHighRule;
+ (int)getBetAnteWithSuperHighRule;

+ (int)getDailyGiftCoin;
+ (int)getDailyGiftCoinIncre;

+ (NSString*)getAwardItemImageName:(int)dicePoint;

+ (WallType)wallType;
+ (BOOL)isEnableAd;

+ (int)getPostponeTime;
+ (int)getUrgeTime;

+ (int)getFollowReward;

+ (BOOL)isAutoSave; //default is no
+ (void)setAutoSave:(BOOL)isAutoSave;

+ (int)numberOfItemCanUsedOnNormalOpus;
+ (int)numberOfItemCanUsedOnContestOpus;

+ (int)getZJHTimeInterval;
+ (int)getTreeMatureTime;
+ (int)getTreeGainTime;
+ (int)getTreeCoinVale;

+ (int)getZJHMaxAutoBetCount;


#pragma mark - draw data version
+ (int)currentDrawDataVersion;

#pragma mark - BBS online attributes
+ (int)getBBSCreationFrequency;
//support limit
+ (int)getBBSSupportMaxTimes;
//content
+ (int)getBBSPostMaxLength;
+ (int)getBBSCommentMaxLength;
+ (int)getBBSTextMinLength;

+ (NSString*)getShareImageWaterMark;

+ (int)supportRecovery;
+ (int)recoveryBackupInterval;
+ (NSInteger)drawAutoSavePaintTimeInterval;

+ (int)getMaxCountForFetchFreeCoinsOneDay;
+ (int)getFreeCoinsAward;
+ (int)getFreeFlowersAward;
+ (int)getFreeTipsAward;
+ (int)getFreeCoinsMoneyTreeGrowthTime;
+ (int)getFreeCoinsMoneyTreeGainTime;
+ (BOOL)freeCoinsEnabled;

+ (int)offlineGuessAwardScore;
+ (int)offlineDrawMyWordScore;
+ (int)offlineDrawSystemWordScore;
+ (int)offlineDrawHotWordScore;

@end
