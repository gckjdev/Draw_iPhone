// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

@class PBConfig;
@class PBConfig_Builder;
@class PBDiceConfig;
@class PBDiceConfig_Builder;
@class PBDrawConfig;
@class PBDrawConfig_Builder;
@class PBPrice;
@class PBPrice_Builder;
@class PBZJHConfig;
@class PBZJHConfig_Builder;

@interface ConfigRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface PBPrice : PBGeneratedMessage {
@private
  BOOL hasAmount_:1;
  BOOL hasPrice_:1;
  BOOL hasProductId_:1;
  BOOL hasSavePercent_:1;
  NSString* amount;
  NSString* price;
  NSString* productId;
  NSString* savePercent;
}
- (BOOL) hasAmount;
- (BOOL) hasPrice;
- (BOOL) hasProductId;
- (BOOL) hasSavePercent;
@property (readonly, retain) NSString* amount;
@property (readonly, retain) NSString* price;
@property (readonly, retain) NSString* productId;
@property (readonly, retain) NSString* savePercent;

+ (PBPrice*) defaultInstance;
- (PBPrice*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBPrice_Builder*) builder;
+ (PBPrice_Builder*) builder;
+ (PBPrice_Builder*) builderWithPrototype:(PBPrice*) prototype;

+ (PBPrice*) parseFromData:(NSData*) data;
+ (PBPrice*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBPrice*) parseFromInputStream:(NSInputStream*) input;
+ (PBPrice*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBPrice*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBPrice*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBPrice_Builder : PBGeneratedMessage_Builder {
@private
  PBPrice* result;
}

- (PBPrice*) defaultInstance;

- (PBPrice_Builder*) clear;
- (PBPrice_Builder*) clone;

- (PBPrice*) build;
- (PBPrice*) buildPartial;

- (PBPrice_Builder*) mergeFrom:(PBPrice*) other;
- (PBPrice_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBPrice_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasAmount;
- (NSString*) amount;
- (PBPrice_Builder*) setAmount:(NSString*) value;
- (PBPrice_Builder*) clearAmount;

- (BOOL) hasPrice;
- (NSString*) price;
- (PBPrice_Builder*) setPrice:(NSString*) value;
- (PBPrice_Builder*) clearPrice;

- (BOOL) hasProductId;
- (NSString*) productId;
- (PBPrice_Builder*) setProductId:(NSString*) value;
- (PBPrice_Builder*) clearProductId;

- (BOOL) hasSavePercent;
- (NSString*) savePercent;
- (PBPrice_Builder*) setSavePercent:(NSString*) value;
- (PBPrice_Builder*) clearSavePercent;
@end

@interface PBZJHConfig : PBGeneratedMessage {
@private
  BOOL hasLevelExp_:1;
  BOOL hasRunwayCoin_:1;
  BOOL hasMaxAutoBetCount_:1;
  BOOL hasTreeMatureTime_:1;
  BOOL hasTreeGainTime_:1;
  BOOL hasTreeCoinValue_:1;
  BOOL hasShareReward_:1;
  int32_t levelExp;
  int32_t runwayCoin;
  int32_t maxAutoBetCount;
  int32_t treeMatureTime;
  int32_t treeGainTime;
  int32_t treeCoinValue;
  int32_t shareReward;
}
- (BOOL) hasLevelExp;
- (BOOL) hasRunwayCoin;
- (BOOL) hasMaxAutoBetCount;
- (BOOL) hasTreeMatureTime;
- (BOOL) hasTreeGainTime;
- (BOOL) hasTreeCoinValue;
- (BOOL) hasShareReward;
@property (readonly) int32_t levelExp;
@property (readonly) int32_t runwayCoin;
@property (readonly) int32_t maxAutoBetCount;
@property (readonly) int32_t treeMatureTime;
@property (readonly) int32_t treeGainTime;
@property (readonly) int32_t treeCoinValue;
@property (readonly) int32_t shareReward;

+ (PBZJHConfig*) defaultInstance;
- (PBZJHConfig*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBZJHConfig_Builder*) builder;
+ (PBZJHConfig_Builder*) builder;
+ (PBZJHConfig_Builder*) builderWithPrototype:(PBZJHConfig*) prototype;

+ (PBZJHConfig*) parseFromData:(NSData*) data;
+ (PBZJHConfig*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBZJHConfig*) parseFromInputStream:(NSInputStream*) input;
+ (PBZJHConfig*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBZJHConfig*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBZJHConfig*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBZJHConfig_Builder : PBGeneratedMessage_Builder {
@private
  PBZJHConfig* result;
}

- (PBZJHConfig*) defaultInstance;

- (PBZJHConfig_Builder*) clear;
- (PBZJHConfig_Builder*) clone;

- (PBZJHConfig*) build;
- (PBZJHConfig*) buildPartial;

- (PBZJHConfig_Builder*) mergeFrom:(PBZJHConfig*) other;
- (PBZJHConfig_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBZJHConfig_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasLevelExp;
- (int32_t) levelExp;
- (PBZJHConfig_Builder*) setLevelExp:(int32_t) value;
- (PBZJHConfig_Builder*) clearLevelExp;

- (BOOL) hasRunwayCoin;
- (int32_t) runwayCoin;
- (PBZJHConfig_Builder*) setRunwayCoin:(int32_t) value;
- (PBZJHConfig_Builder*) clearRunwayCoin;

- (BOOL) hasMaxAutoBetCount;
- (int32_t) maxAutoBetCount;
- (PBZJHConfig_Builder*) setMaxAutoBetCount:(int32_t) value;
- (PBZJHConfig_Builder*) clearMaxAutoBetCount;

- (BOOL) hasTreeMatureTime;
- (int32_t) treeMatureTime;
- (PBZJHConfig_Builder*) setTreeMatureTime:(int32_t) value;
- (PBZJHConfig_Builder*) clearTreeMatureTime;

- (BOOL) hasTreeGainTime;
- (int32_t) treeGainTime;
- (PBZJHConfig_Builder*) setTreeGainTime:(int32_t) value;
- (PBZJHConfig_Builder*) clearTreeGainTime;

- (BOOL) hasTreeCoinValue;
- (int32_t) treeCoinValue;
- (PBZJHConfig_Builder*) setTreeCoinValue:(int32_t) value;
- (PBZJHConfig_Builder*) clearTreeCoinValue;

- (BOOL) hasShareReward;
- (int32_t) shareReward;
- (PBZJHConfig_Builder*) setShareReward:(int32_t) value;
- (PBZJHConfig_Builder*) clearShareReward;
@end

@interface PBDiceConfig : PBGeneratedMessage {
@private
  BOOL hasShareReward_:1;
  BOOL hasFollowReward_:1;
  BOOL hasLevelExp_:1;
  BOOL hasLevelUpRewardCut_:1;
  BOOL hasRunwayCoin_:1;
  BOOL hasNormalRoomThreshhold_:1;
  BOOL hasHighRoomThreshhold_:1;
  BOOL hasSuperHighRoomThreshhold_:1;
  BOOL hasBetAnteNormalRoom_:1;
  BOOL hasBetAnteHighRoom_:1;
  BOOL hasBetAnteSuperHighRoom_:1;
  BOOL hasDailyGift_:1;
  BOOL hasDailyGiftIncreament_:1;
  int32_t shareReward;
  int32_t followReward;
  int32_t levelExp;
  int32_t levelUpRewardCut;
  int32_t runwayCoin;
  int32_t normalRoomThreshhold;
  int32_t highRoomThreshhold;
  int32_t superHighRoomThreshhold;
  int32_t betAnteNormalRoom;
  int32_t betAnteHighRoom;
  int32_t betAnteSuperHighRoom;
  int32_t dailyGift;
  int32_t dailyGiftIncreament;
}
- (BOOL) hasShareReward;
- (BOOL) hasFollowReward;
- (BOOL) hasLevelExp;
- (BOOL) hasLevelUpRewardCut;
- (BOOL) hasRunwayCoin;
- (BOOL) hasNormalRoomThreshhold;
- (BOOL) hasHighRoomThreshhold;
- (BOOL) hasSuperHighRoomThreshhold;
- (BOOL) hasBetAnteNormalRoom;
- (BOOL) hasBetAnteHighRoom;
- (BOOL) hasBetAnteSuperHighRoom;
- (BOOL) hasDailyGift;
- (BOOL) hasDailyGiftIncreament;
@property (readonly) int32_t shareReward;
@property (readonly) int32_t followReward;
@property (readonly) int32_t levelExp;
@property (readonly) int32_t levelUpRewardCut;
@property (readonly) int32_t runwayCoin;
@property (readonly) int32_t normalRoomThreshhold;
@property (readonly) int32_t highRoomThreshhold;
@property (readonly) int32_t superHighRoomThreshhold;
@property (readonly) int32_t betAnteNormalRoom;
@property (readonly) int32_t betAnteHighRoom;
@property (readonly) int32_t betAnteSuperHighRoom;
@property (readonly) int32_t dailyGift;
@property (readonly) int32_t dailyGiftIncreament;

+ (PBDiceConfig*) defaultInstance;
- (PBDiceConfig*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBDiceConfig_Builder*) builder;
+ (PBDiceConfig_Builder*) builder;
+ (PBDiceConfig_Builder*) builderWithPrototype:(PBDiceConfig*) prototype;

+ (PBDiceConfig*) parseFromData:(NSData*) data;
+ (PBDiceConfig*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBDiceConfig*) parseFromInputStream:(NSInputStream*) input;
+ (PBDiceConfig*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBDiceConfig*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBDiceConfig*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBDiceConfig_Builder : PBGeneratedMessage_Builder {
@private
  PBDiceConfig* result;
}

- (PBDiceConfig*) defaultInstance;

- (PBDiceConfig_Builder*) clear;
- (PBDiceConfig_Builder*) clone;

- (PBDiceConfig*) build;
- (PBDiceConfig*) buildPartial;

- (PBDiceConfig_Builder*) mergeFrom:(PBDiceConfig*) other;
- (PBDiceConfig_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBDiceConfig_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasShareReward;
- (int32_t) shareReward;
- (PBDiceConfig_Builder*) setShareReward:(int32_t) value;
- (PBDiceConfig_Builder*) clearShareReward;

- (BOOL) hasFollowReward;
- (int32_t) followReward;
- (PBDiceConfig_Builder*) setFollowReward:(int32_t) value;
- (PBDiceConfig_Builder*) clearFollowReward;

- (BOOL) hasLevelExp;
- (int32_t) levelExp;
- (PBDiceConfig_Builder*) setLevelExp:(int32_t) value;
- (PBDiceConfig_Builder*) clearLevelExp;

- (BOOL) hasLevelUpRewardCut;
- (int32_t) levelUpRewardCut;
- (PBDiceConfig_Builder*) setLevelUpRewardCut:(int32_t) value;
- (PBDiceConfig_Builder*) clearLevelUpRewardCut;

- (BOOL) hasRunwayCoin;
- (int32_t) runwayCoin;
- (PBDiceConfig_Builder*) setRunwayCoin:(int32_t) value;
- (PBDiceConfig_Builder*) clearRunwayCoin;

- (BOOL) hasNormalRoomThreshhold;
- (int32_t) normalRoomThreshhold;
- (PBDiceConfig_Builder*) setNormalRoomThreshhold:(int32_t) value;
- (PBDiceConfig_Builder*) clearNormalRoomThreshhold;

- (BOOL) hasHighRoomThreshhold;
- (int32_t) highRoomThreshhold;
- (PBDiceConfig_Builder*) setHighRoomThreshhold:(int32_t) value;
- (PBDiceConfig_Builder*) clearHighRoomThreshhold;

- (BOOL) hasSuperHighRoomThreshhold;
- (int32_t) superHighRoomThreshhold;
- (PBDiceConfig_Builder*) setSuperHighRoomThreshhold:(int32_t) value;
- (PBDiceConfig_Builder*) clearSuperHighRoomThreshhold;

- (BOOL) hasBetAnteNormalRoom;
- (int32_t) betAnteNormalRoom;
- (PBDiceConfig_Builder*) setBetAnteNormalRoom:(int32_t) value;
- (PBDiceConfig_Builder*) clearBetAnteNormalRoom;

- (BOOL) hasBetAnteHighRoom;
- (int32_t) betAnteHighRoom;
- (PBDiceConfig_Builder*) setBetAnteHighRoom:(int32_t) value;
- (PBDiceConfig_Builder*) clearBetAnteHighRoom;

- (BOOL) hasBetAnteSuperHighRoom;
- (int32_t) betAnteSuperHighRoom;
- (PBDiceConfig_Builder*) setBetAnteSuperHighRoom:(int32_t) value;
- (PBDiceConfig_Builder*) clearBetAnteSuperHighRoom;

- (BOOL) hasDailyGift;
- (int32_t) dailyGift;
- (PBDiceConfig_Builder*) setDailyGift:(int32_t) value;
- (PBDiceConfig_Builder*) clearDailyGift;

- (BOOL) hasDailyGiftIncreament;
- (int32_t) dailyGiftIncreament;
- (PBDiceConfig_Builder*) setDailyGiftIncreament:(int32_t) value;
- (PBDiceConfig_Builder*) clearDailyGiftIncreament;
@end

@interface PBDrawConfig : PBGeneratedMessage {
@private
  BOOL hasMaxItemTimesOnContestOpus_:1;
  BOOL hasMaxItemTimesOnNormalOpus_:1;
  BOOL hasOfflineGuessExp_:1;
  BOOL hasOfflineDrawExp_:1;
  BOOL hasOnlineGuessExp_:1;
  BOOL hasOnlineDrawExp_:1;
  BOOL hasLevelUpFlower_:1;
  BOOL hasFollowReward_:1;
  BOOL hasShareReward_:1;
  BOOL hasFlowerExp_:1;
  BOOL hasFlowerReward_:1;
  BOOL hasTomatoExp_:1;
  BOOL hasTomatoReward_:1;
  BOOL hasGuessReward_:1;
  BOOL hasDefaultOnlineCnServerPort_:1;
  BOOL hasDefaultOnlineEnServerPort_:1;
  BOOL hasDefaultOnlineCnServerAddress_:1;
  BOOL hasDefaultOnlineEnServerAddress_:1;
  int32_t maxItemTimesOnContestOpus;
  int32_t maxItemTimesOnNormalOpus;
  int32_t offlineGuessExp;
  int32_t offlineDrawExp;
  int32_t onlineGuessExp;
  int32_t onlineDrawExp;
  int32_t levelUpFlower;
  int32_t followReward;
  int32_t shareReward;
  int32_t flowerExp;
  int32_t flowerReward;
  int32_t tomatoExp;
  int32_t tomatoReward;
  int32_t guessReward;
  int32_t defaultOnlineCnServerPort;
  int32_t defaultOnlineEnServerPort;
  NSString* defaultOnlineCnServerAddress;
  NSString* defaultOnlineEnServerAddress;
}
- (BOOL) hasDefaultOnlineEnServerAddress;
- (BOOL) hasDefaultOnlineEnServerPort;
- (BOOL) hasDefaultOnlineCnServerAddress;
- (BOOL) hasDefaultOnlineCnServerPort;
- (BOOL) hasGuessReward;
- (BOOL) hasTomatoReward;
- (BOOL) hasTomatoExp;
- (BOOL) hasFlowerReward;
- (BOOL) hasFlowerExp;
- (BOOL) hasShareReward;
- (BOOL) hasFollowReward;
- (BOOL) hasLevelUpFlower;
- (BOOL) hasOnlineDrawExp;
- (BOOL) hasOnlineGuessExp;
- (BOOL) hasOfflineDrawExp;
- (BOOL) hasOfflineGuessExp;
- (BOOL) hasMaxItemTimesOnNormalOpus;
- (BOOL) hasMaxItemTimesOnContestOpus;
@property (readonly, retain) NSString* defaultOnlineEnServerAddress;
@property (readonly) int32_t defaultOnlineEnServerPort;
@property (readonly, retain) NSString* defaultOnlineCnServerAddress;
@property (readonly) int32_t defaultOnlineCnServerPort;
@property (readonly) int32_t guessReward;
@property (readonly) int32_t tomatoReward;
@property (readonly) int32_t tomatoExp;
@property (readonly) int32_t flowerReward;
@property (readonly) int32_t flowerExp;
@property (readonly) int32_t shareReward;
@property (readonly) int32_t followReward;
@property (readonly) int32_t levelUpFlower;
@property (readonly) int32_t onlineDrawExp;
@property (readonly) int32_t onlineGuessExp;
@property (readonly) int32_t offlineDrawExp;
@property (readonly) int32_t offlineGuessExp;
@property (readonly) int32_t maxItemTimesOnNormalOpus;
@property (readonly) int32_t maxItemTimesOnContestOpus;

+ (PBDrawConfig*) defaultInstance;
- (PBDrawConfig*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBDrawConfig_Builder*) builder;
+ (PBDrawConfig_Builder*) builder;
+ (PBDrawConfig_Builder*) builderWithPrototype:(PBDrawConfig*) prototype;

+ (PBDrawConfig*) parseFromData:(NSData*) data;
+ (PBDrawConfig*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBDrawConfig*) parseFromInputStream:(NSInputStream*) input;
+ (PBDrawConfig*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBDrawConfig*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBDrawConfig*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBDrawConfig_Builder : PBGeneratedMessage_Builder {
@private
  PBDrawConfig* result;
}

- (PBDrawConfig*) defaultInstance;

- (PBDrawConfig_Builder*) clear;
- (PBDrawConfig_Builder*) clone;

- (PBDrawConfig*) build;
- (PBDrawConfig*) buildPartial;

- (PBDrawConfig_Builder*) mergeFrom:(PBDrawConfig*) other;
- (PBDrawConfig_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBDrawConfig_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasDefaultOnlineEnServerAddress;
- (NSString*) defaultOnlineEnServerAddress;
- (PBDrawConfig_Builder*) setDefaultOnlineEnServerAddress:(NSString*) value;
- (PBDrawConfig_Builder*) clearDefaultOnlineEnServerAddress;

- (BOOL) hasDefaultOnlineEnServerPort;
- (int32_t) defaultOnlineEnServerPort;
- (PBDrawConfig_Builder*) setDefaultOnlineEnServerPort:(int32_t) value;
- (PBDrawConfig_Builder*) clearDefaultOnlineEnServerPort;

- (BOOL) hasDefaultOnlineCnServerAddress;
- (NSString*) defaultOnlineCnServerAddress;
- (PBDrawConfig_Builder*) setDefaultOnlineCnServerAddress:(NSString*) value;
- (PBDrawConfig_Builder*) clearDefaultOnlineCnServerAddress;

- (BOOL) hasDefaultOnlineCnServerPort;
- (int32_t) defaultOnlineCnServerPort;
- (PBDrawConfig_Builder*) setDefaultOnlineCnServerPort:(int32_t) value;
- (PBDrawConfig_Builder*) clearDefaultOnlineCnServerPort;

- (BOOL) hasGuessReward;
- (int32_t) guessReward;
- (PBDrawConfig_Builder*) setGuessReward:(int32_t) value;
- (PBDrawConfig_Builder*) clearGuessReward;

- (BOOL) hasTomatoReward;
- (int32_t) tomatoReward;
- (PBDrawConfig_Builder*) setTomatoReward:(int32_t) value;
- (PBDrawConfig_Builder*) clearTomatoReward;

- (BOOL) hasTomatoExp;
- (int32_t) tomatoExp;
- (PBDrawConfig_Builder*) setTomatoExp:(int32_t) value;
- (PBDrawConfig_Builder*) clearTomatoExp;

- (BOOL) hasFlowerReward;
- (int32_t) flowerReward;
- (PBDrawConfig_Builder*) setFlowerReward:(int32_t) value;
- (PBDrawConfig_Builder*) clearFlowerReward;

- (BOOL) hasFlowerExp;
- (int32_t) flowerExp;
- (PBDrawConfig_Builder*) setFlowerExp:(int32_t) value;
- (PBDrawConfig_Builder*) clearFlowerExp;

- (BOOL) hasShareReward;
- (int32_t) shareReward;
- (PBDrawConfig_Builder*) setShareReward:(int32_t) value;
- (PBDrawConfig_Builder*) clearShareReward;

- (BOOL) hasFollowReward;
- (int32_t) followReward;
- (PBDrawConfig_Builder*) setFollowReward:(int32_t) value;
- (PBDrawConfig_Builder*) clearFollowReward;

- (BOOL) hasLevelUpFlower;
- (int32_t) levelUpFlower;
- (PBDrawConfig_Builder*) setLevelUpFlower:(int32_t) value;
- (PBDrawConfig_Builder*) clearLevelUpFlower;

- (BOOL) hasOnlineDrawExp;
- (int32_t) onlineDrawExp;
- (PBDrawConfig_Builder*) setOnlineDrawExp:(int32_t) value;
- (PBDrawConfig_Builder*) clearOnlineDrawExp;

- (BOOL) hasOnlineGuessExp;
- (int32_t) onlineGuessExp;
- (PBDrawConfig_Builder*) setOnlineGuessExp:(int32_t) value;
- (PBDrawConfig_Builder*) clearOnlineGuessExp;

- (BOOL) hasOfflineDrawExp;
- (int32_t) offlineDrawExp;
- (PBDrawConfig_Builder*) setOfflineDrawExp:(int32_t) value;
- (PBDrawConfig_Builder*) clearOfflineDrawExp;

- (BOOL) hasOfflineGuessExp;
- (int32_t) offlineGuessExp;
- (PBDrawConfig_Builder*) setOfflineGuessExp:(int32_t) value;
- (PBDrawConfig_Builder*) clearOfflineGuessExp;

- (BOOL) hasMaxItemTimesOnNormalOpus;
- (int32_t) maxItemTimesOnNormalOpus;
- (PBDrawConfig_Builder*) setMaxItemTimesOnNormalOpus:(int32_t) value;
- (PBDrawConfig_Builder*) clearMaxItemTimesOnNormalOpus;

- (BOOL) hasMaxItemTimesOnContestOpus;
- (int32_t) maxItemTimesOnContestOpus;
- (PBDrawConfig_Builder*) setMaxItemTimesOnContestOpus:(int32_t) value;
- (PBDrawConfig_Builder*) clearMaxItemTimesOnContestOpus;
@end

@interface PBConfig : PBGeneratedMessage {
@private
  BOOL hasEnableReview_:1;
  BOOL hasInReview_:1;
  BOOL hasEnableAd_:1;
  BOOL hasEnableWall_:1;
  BOOL hasBalanceDeviation_:1;
  BOOL hasPostponeTime_:1;
  BOOL hasUrgeTime_:1;
  BOOL hasWallType_:1;
  BOOL hasTrafficApiserverUrl_:1;
  BOOL hasUserApiserverUrl_:1;
  BOOL hasMusicHomeCnUrl_:1;
  BOOL hasMusicHomeEnUrl_:1;
  BOOL hasInReviewVersion_:1;
  BOOL hasZjhConfig_:1;
  BOOL hasDiceConfig_:1;
  BOOL hasDrawConfig_:1;
  BOOL enableReview_:1;
  BOOL inReview_:1;
  BOOL enableAd_:1;
  BOOL enableWall_:1;
  int32_t balanceDeviation;
  int32_t postponeTime;
  int32_t urgeTime;
  int32_t wallType;
  NSString* trafficApiserverUrl;
  NSString* userApiserverUrl;
  NSString* musicHomeCnUrl;
  NSString* musicHomeEnUrl;
  NSString* inReviewVersion;
  PBZJHConfig* zjhConfig;
  PBDiceConfig* diceConfig;
  PBDrawConfig* drawConfig;
  NSMutableArray* mutableCoinPricesList;
}
- (BOOL) hasBalanceDeviation;
- (BOOL) hasTrafficApiserverUrl;
- (BOOL) hasUserApiserverUrl;
- (BOOL) hasMusicHomeCnUrl;
- (BOOL) hasMusicHomeEnUrl;
- (BOOL) hasEnableReview;
- (BOOL) hasInReview;
- (BOOL) hasInReviewVersion;
- (BOOL) hasPostponeTime;
- (BOOL) hasUrgeTime;
- (BOOL) hasEnableAd;
- (BOOL) hasEnableWall;
- (BOOL) hasWallType;
- (BOOL) hasDrawConfig;
- (BOOL) hasDiceConfig;
- (BOOL) hasZjhConfig;
@property (readonly) int32_t balanceDeviation;
@property (readonly, retain) NSString* trafficApiserverUrl;
@property (readonly, retain) NSString* userApiserverUrl;
@property (readonly, retain) NSString* musicHomeCnUrl;
@property (readonly, retain) NSString* musicHomeEnUrl;
- (BOOL) enableReview;
- (BOOL) inReview;
@property (readonly, retain) NSString* inReviewVersion;
@property (readonly) int32_t postponeTime;
@property (readonly) int32_t urgeTime;
- (BOOL) enableAd;
- (BOOL) enableWall;
@property (readonly) int32_t wallType;
@property (readonly, retain) PBDrawConfig* drawConfig;
@property (readonly, retain) PBDiceConfig* diceConfig;
@property (readonly, retain) PBZJHConfig* zjhConfig;
- (NSArray*) coinPricesList;
- (PBPrice*) coinPricesAtIndex:(int32_t) index;

+ (PBConfig*) defaultInstance;
- (PBConfig*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBConfig_Builder*) builder;
+ (PBConfig_Builder*) builder;
+ (PBConfig_Builder*) builderWithPrototype:(PBConfig*) prototype;

+ (PBConfig*) parseFromData:(NSData*) data;
+ (PBConfig*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBConfig*) parseFromInputStream:(NSInputStream*) input;
+ (PBConfig*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBConfig*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBConfig*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBConfig_Builder : PBGeneratedMessage_Builder {
@private
  PBConfig* result;
}

- (PBConfig*) defaultInstance;

- (PBConfig_Builder*) clear;
- (PBConfig_Builder*) clone;

- (PBConfig*) build;
- (PBConfig*) buildPartial;

- (PBConfig_Builder*) mergeFrom:(PBConfig*) other;
- (PBConfig_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBConfig_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (NSArray*) coinPricesList;
- (PBPrice*) coinPricesAtIndex:(int32_t) index;
- (PBConfig_Builder*) replaceCoinPricesAtIndex:(int32_t) index with:(PBPrice*) value;
- (PBConfig_Builder*) addCoinPrices:(PBPrice*) value;
- (PBConfig_Builder*) addAllCoinPrices:(NSArray*) values;
- (PBConfig_Builder*) clearCoinPricesList;

- (BOOL) hasBalanceDeviation;
- (int32_t) balanceDeviation;
- (PBConfig_Builder*) setBalanceDeviation:(int32_t) value;
- (PBConfig_Builder*) clearBalanceDeviation;

- (BOOL) hasTrafficApiserverUrl;
- (NSString*) trafficApiserverUrl;
- (PBConfig_Builder*) setTrafficApiserverUrl:(NSString*) value;
- (PBConfig_Builder*) clearTrafficApiserverUrl;

- (BOOL) hasUserApiserverUrl;
- (NSString*) userApiserverUrl;
- (PBConfig_Builder*) setUserApiserverUrl:(NSString*) value;
- (PBConfig_Builder*) clearUserApiserverUrl;

- (BOOL) hasMusicHomeCnUrl;
- (NSString*) musicHomeCnUrl;
- (PBConfig_Builder*) setMusicHomeCnUrl:(NSString*) value;
- (PBConfig_Builder*) clearMusicHomeCnUrl;

- (BOOL) hasMusicHomeEnUrl;
- (NSString*) musicHomeEnUrl;
- (PBConfig_Builder*) setMusicHomeEnUrl:(NSString*) value;
- (PBConfig_Builder*) clearMusicHomeEnUrl;

- (BOOL) hasEnableReview;
- (BOOL) enableReview;
- (PBConfig_Builder*) setEnableReview:(BOOL) value;
- (PBConfig_Builder*) clearEnableReview;

- (BOOL) hasInReview;
- (BOOL) inReview;
- (PBConfig_Builder*) setInReview:(BOOL) value;
- (PBConfig_Builder*) clearInReview;

- (BOOL) hasInReviewVersion;
- (NSString*) inReviewVersion;
- (PBConfig_Builder*) setInReviewVersion:(NSString*) value;
- (PBConfig_Builder*) clearInReviewVersion;

- (BOOL) hasPostponeTime;
- (int32_t) postponeTime;
- (PBConfig_Builder*) setPostponeTime:(int32_t) value;
- (PBConfig_Builder*) clearPostponeTime;

- (BOOL) hasUrgeTime;
- (int32_t) urgeTime;
- (PBConfig_Builder*) setUrgeTime:(int32_t) value;
- (PBConfig_Builder*) clearUrgeTime;

- (BOOL) hasEnableAd;
- (BOOL) enableAd;
- (PBConfig_Builder*) setEnableAd:(BOOL) value;
- (PBConfig_Builder*) clearEnableAd;

- (BOOL) hasEnableWall;
- (BOOL) enableWall;
- (PBConfig_Builder*) setEnableWall:(BOOL) value;
- (PBConfig_Builder*) clearEnableWall;

- (BOOL) hasWallType;
- (int32_t) wallType;
- (PBConfig_Builder*) setWallType:(int32_t) value;
- (PBConfig_Builder*) clearWallType;

- (BOOL) hasDrawConfig;
- (PBDrawConfig*) drawConfig;
- (PBConfig_Builder*) setDrawConfig:(PBDrawConfig*) value;
- (PBConfig_Builder*) setDrawConfigBuilder:(PBDrawConfig_Builder*) builderForValue;
- (PBConfig_Builder*) mergeDrawConfig:(PBDrawConfig*) value;
- (PBConfig_Builder*) clearDrawConfig;

- (BOOL) hasDiceConfig;
- (PBDiceConfig*) diceConfig;
- (PBConfig_Builder*) setDiceConfig:(PBDiceConfig*) value;
- (PBConfig_Builder*) setDiceConfigBuilder:(PBDiceConfig_Builder*) builderForValue;
- (PBConfig_Builder*) mergeDiceConfig:(PBDiceConfig*) value;
- (PBConfig_Builder*) clearDiceConfig;

- (BOOL) hasZjhConfig;
- (PBZJHConfig*) zjhConfig;
- (PBConfig_Builder*) setZjhConfig:(PBZJHConfig*) value;
- (PBConfig_Builder*) setZjhConfigBuilder:(PBZJHConfig_Builder*) builderForValue;
- (PBConfig_Builder*) mergeZjhConfig:(PBZJHConfig*) value;
- (PBConfig_Builder*) clearZjhConfig;
@end
