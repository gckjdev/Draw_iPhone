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

@interface PPConfigManager : NSObject

+ (int)getHomeDisplayOpusNumber;
+ (int)getHomeSwitchOpusInterval;
+ (int)getBalanceDeviation;
+ (int)getPreviewActionCount;

+ (NSArray *)getLearnDrawFeedbackEmailList;

//+ (int)getGuessRewardNormal;

+ (NSInteger)historyRankNumber;
+ (NSInteger)drawAutoSavePaintInterval;//DRAFT_PAINT_COUNT
+ (NSInteger)opusDescMaxLength;
+ (NSInteger)maxPenWidth;
+ (CGFloat)minPenWidth;
+ (double)minAlpha;

+ (NSInteger)getMessageStatMaxCount; //MESSAGE_STAT_MAX_COUNT

+ (NSInteger)defaultPenWidth;
+ (NSInteger *)penWidthList;

+ (NSString*)getChannelId;

+ (NSString*)defaultEnglishServer;
+ (NSString*)defaultChineseServer;
+ (int)defaultEnglishPort;
+ (int)defaultChinesePort;
+ (NSString*)getDrawServerString;

+ (GuessLevel)guessDifficultLevel;
+ (void)setGuessDifficultLevel:(GuessLevel)level;

+ (ChatVoiceEnable)getChatVoiceEnable;
+ (void)setChatVoiceEnable:(ChatVoiceEnable)enable;

+ (BOOL)enableReview;

+ (NSString*)getAPIServerURL;
+ (NSString*)getTrafficAPIServerURL;
+ (NSString*)getBBSServerURL;
+ (NSString*)getMessageServerURL;
+ (NSString*)getMusicDownloadHomeURL;


+ (NSInteger)getHotOpusCountOnce;
+ (NSInteger)getTimelineCountOnce;
+ (BOOL)showOpusCount;

//+ (BOOL)isInReview;
+ (BOOL)isInReviewVersion;

+ (BOOL)wallEnabled;

+ (BOOL)isLiarDice;
+ (BOOL)isProVersion;
+ (NSString*)appId;

+ (BOOL)useLmWall;

+ (NSString*)gameId;

+ (NSInteger)getDrawGridLineSpace;

+ (int)getAwardInHappyMode;
+ (int)getAwardInGeniusMode;
+ (int)getDeltaAwardInGeniusMode;
+ (int)getDeductCoinsInHappyMode;
+ (int)getDeductCoinsInGeniusMode;
+ (int)getDeductCoinsInContestMode;

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

+ (BOOL)isShowRecommendApp;
+ (NSString *)currentVersion;

+ (double)getOnlinePlayDrawSpeed;
+ (double)getMaxPlayDrawSpeed;
+ (double)getMinPlayDrawSpeed;
+ (double)getDefaultPlayDrawSpeed;

+ (int)getOnLineDrawExp;
+ (int)getOnLineGuessExp;
+ (int)getOffLineDrawExp;
+ (int)getOffLineGuessExp;
+ (int)getLiarDiceExp;
+ (int)getZhajinhuaExp;

+ (int)getDiceFleeCoin;
+ (int)getZJHFleeCoin;
+ (int)getOnlineDrawFleeCoin;

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
+ (BOOL)useSpeedLevel;

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
+ (int *)getBBSRewardBounsList;

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

+ (int)getLevelUpAward;

+ (int)onlineRoomCountPerPage;
+ (int)maxWeixinImageWidth;

+ (NSString*)getAdMobId;

+ (int)maxTotalBetWithNormalRule;
+ (int)maxTotalBetWithDualRule;
+ (int)maxTotalBetWithRichRule;
+ (BOOL)showBetViewEnabled;

+ (NSString *)currentDrawBgVersion;
+ (NSString *)currentImageShapeVersion;

+ (BOOL)isEnableLimeiWall;
+ (BOOL)isEnableWanpuWall;
+ (BOOL)isEnableAderWall;
+ (BOOL)isEnableTapjoyWall;
+ (BOOL)isEnableYoumiWall;
+ (BOOL)isEnableDomodWall;
+ (NSInteger)getDefaultDetailOpusCount;

+ (NSString*)getFreeIngotPostId;
+ (NSString*)getBugReportPostId;
+ (NSString*)getFeedbackPostId;

+ (int)getCoinsIngotRate;

+ (int)getSignatureMaxLen;
+ (int)getNicknameMaxLen;

+ (NSString *)getTaobaoHomeUrl;

+ (NSString *)getAlipayPartner;
+ (NSString *)getAlipaySeller;
+ (NSString *)getAlipayRSAPrivateKey;
+ (NSString *)getAlipayAlipayPublicKey;
+ (NSString *)getAlipayNotifyUrl;
+ (NSString *)getAlipayWebUrl;

+ (NSString *)getLastAppVersion;
+ (NSString *)getLastAppVersionUpdateLog;

+ (NSString*)getSNSShareSubject;
+ (NSString*)getDrawAppLink;

+ (int)getBuyAnswerPrice;
+ (double)getBGMVolume;

+ (BOOL)showRestoreButton;
+ (NSString*)getFeedbackBody;

+ (float)littleGeeFirstShowOptionsDuration;
+ (float)littleGeeShowOptionsDuration;

+ (NSString*)getAppItuneLink;
+ (int)maxDrawChineseTitleLen;
+ (int)maxDrawEnglishTitleLen;


+ (int)maxShadowDistance;
+ (int)maxShadowBlur;
+ (int)cachedActionCount;
+ (int)minUndoActionCount;

+ (NSString*)getLimeiWallId;
+ (BOOL)enableWordFilter;

+ (int)getMaxLengthOfDrawDesc;
+ (int)getMaxLayerNumber;

+ (NSString *)getContestBeginTimeString;
+ (int)getHotWordAwardCoins;

+ (int)maxTakeNumberCount;
+ (int)getFeedCarouselType;
+ (BOOL)getGuessContestLocalNotificationEnabled;

+ (int)getHappyGuessExpireTime;
+ (int)getGeniusGuessExpireTime;

+ (NSString*)guessContestShareText;
+ (NSString*)guessContestShareTitleText;
+ (int)maxWeiboShareLength;

+ (int)getGuessRankListCountLoadedAtOnce;
+ (BOOL)showAuthorOnOpus;

+ (int)getTipUseTimesLimitInGeniusMode;
+ (int)getHomeHotOpusCount;

+ (BOOL)showAllPainterTags;

+ (NSString *)getSingTagList;
+ (int)getRecordLimitTime;

+ (NSString*)getShareSDKAppId;
+ (int)getCreateOpusWeiboReward;

@end