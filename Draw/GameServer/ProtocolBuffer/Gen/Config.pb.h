// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "GameBasic.pb.h"
#import "GameConstants.pb.h"
// @@protoc_insertion_point(imports)

@class PBApp;
@class PBAppBuilder;
@class PBAppReward;
@class PBAppRewardBuilder;
@class PBClass;
@class PBClassBuilder;
@class PBConfig;
@class PBConfigBuilder;
@class PBDiceConfig;
@class PBDiceConfigBuilder;
@class PBDrawAction;
@class PBDrawActionBuilder;
@class PBDrawBg;
@class PBDrawBgBuilder;
@class PBDrawConfig;
@class PBDrawConfigBuilder;
@class PBGameItem;
@class PBGameItemBuilder;
@class PBGameItemList;
@class PBGameItemListBuilder;
@class PBGameSession;
@class PBGameSessionBuilder;
@class PBGameSessionChanged;
@class PBGameSessionChangedBuilder;
@class PBGameUser;
@class PBGameUserBuilder;
@class PBGradient;
@class PBGradientBuilder;
@class PBIAPProduct;
@class PBIAPProductBuilder;
@class PBIAPProductList;
@class PBIAPProductListBuilder;
@class PBIAPProductPrice;
@class PBIAPProductPriceBuilder;
@class PBIntKeyIntValue;
@class PBIntKeyIntValueBuilder;
@class PBIntKeyValue;
@class PBIntKeyValueBuilder;
@class PBItemPriceInfo;
@class PBItemPriceInfoBuilder;
@class PBKeyValue;
@class PBKeyValueBuilder;
@class PBLayer;
@class PBLayerBuilder;
@class PBLocalizeString;
@class PBLocalizeStringBuilder;
@class PBMessage;
@class PBMessageBuilder;
@class PBMessageStat;
@class PBMessageStatBuilder;
@class PBOpusRank;
@class PBOpusRankBuilder;
@class PBPrice;
@class PBPriceBuilder;
@class PBPromotionInfo;
@class PBPromotionInfoBuilder;
@class PBRewardWall;
@class PBRewardWallBuilder;
@class PBSNSUser;
@class PBSNSUserBuilder;
@class PBSNSUserCredential;
@class PBSNSUserCredentialBuilder;
@class PBSimpleGroup;
@class PBSimpleGroupBuilder;
@class PBSize;
@class PBSizeBuilder;
@class PBTask;
@class PBTaskBuilder;
@class PBUserAward;
@class PBUserAwardBuilder;
@class PBUserBasicInfo;
@class PBUserBasicInfoBuilder;
@class PBUserItem;
@class PBUserItemBuilder;
@class PBUserItemList;
@class PBUserItemListBuilder;
@class PBUserLevel;
@class PBUserLevelBuilder;
@class PBUserResult;
@class PBUserResultBuilder;
@class PBZJHConfig;
@class PBZJHConfigBuilder;
#ifndef __has_feature
  #define __has_feature(x) 0 // Compatibility with non-clang compilers.
#endif // __has_feature

#ifndef NS_RETURNS_NOT_RETAINED
  #if __has_feature(attribute_ns_returns_not_retained)
    #define NS_RETURNS_NOT_RETAINED __attribute__((ns_returns_not_retained))
  #else
    #define NS_RETURNS_NOT_RETAINED
  #endif
#endif

typedef NS_ENUM(SInt32, PBRewardWallType) {
  PBRewardWallTypeLimei = 1,
  PBRewardWallTypeWanpu = 2,
  PBRewardWallTypeAder = 3,
  PBRewardWallTypeYoumi = 4,
  PBRewardWallTypeTapjoy = 5,
  PBRewardWallTypeDomod = 6,
};

BOOL PBRewardWallTypeIsValidValue(PBRewardWallType value);
NSString *NSStringFromPBRewardWallType(PBRewardWallType value);


@interface ConfigRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface PBPrice : PBGeneratedMessage<GeneratedMessageProtocol> {
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
@property (readonly, strong) NSString* amount;
@property (readonly, strong) NSString* price;
@property (readonly, strong) NSString* productId;
@property (readonly, strong) NSString* savePercent;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBPriceBuilder*) builder;
+ (PBPriceBuilder*) builder;
+ (PBPriceBuilder*) builderWithPrototype:(PBPrice*) prototype;
- (PBPriceBuilder*) toBuilder;

+ (PBPrice*) parseFromData:(NSData*) data;
+ (PBPrice*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBPrice*) parseFromInputStream:(NSInputStream*) input;
+ (PBPrice*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBPrice*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBPrice*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBPriceBuilder : PBGeneratedMessageBuilder {
@private
  PBPrice* resultPbprice;
}

- (PBPrice*) defaultInstance;

- (PBPriceBuilder*) clear;
- (PBPriceBuilder*) clone;

- (PBPrice*) build;
- (PBPrice*) buildPartial;

- (PBPriceBuilder*) mergeFrom:(PBPrice*) other;
- (PBPriceBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBPriceBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasAmount;
- (NSString*) amount;
- (PBPriceBuilder*) setAmount:(NSString*) value;
- (PBPriceBuilder*) clearAmount;

- (BOOL) hasPrice;
- (NSString*) price;
- (PBPriceBuilder*) setPrice:(NSString*) value;
- (PBPriceBuilder*) clearPrice;

- (BOOL) hasProductId;
- (NSString*) productId;
- (PBPriceBuilder*) setProductId:(NSString*) value;
- (PBPriceBuilder*) clearProductId;

- (BOOL) hasSavePercent;
- (NSString*) savePercent;
- (PBPriceBuilder*) setSavePercent:(NSString*) value;
- (PBPriceBuilder*) clearSavePercent;
@end

@interface PBZJHConfig : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasLevelExp_:1;
  BOOL hasRunwayCoin_:1;
  BOOL hasMaxAutoBetCount_:1;
  BOOL hasTreeMatureTime_:1;
  BOOL hasTreeGainTime_:1;
  BOOL hasTreeCoinValue_:1;
  BOOL hasShareReward_:1;
  SInt32 levelExp;
  SInt32 runwayCoin;
  SInt32 maxAutoBetCount;
  SInt32 treeMatureTime;
  SInt32 treeGainTime;
  SInt32 treeCoinValue;
  SInt32 shareReward;
}
- (BOOL) hasLevelExp;
- (BOOL) hasRunwayCoin;
- (BOOL) hasMaxAutoBetCount;
- (BOOL) hasTreeMatureTime;
- (BOOL) hasTreeGainTime;
- (BOOL) hasTreeCoinValue;
- (BOOL) hasShareReward;
@property (readonly) SInt32 levelExp;
@property (readonly) SInt32 runwayCoin;
@property (readonly) SInt32 maxAutoBetCount;
@property (readonly) SInt32 treeMatureTime;
@property (readonly) SInt32 treeGainTime;
@property (readonly) SInt32 treeCoinValue;
@property (readonly) SInt32 shareReward;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBZJHConfigBuilder*) builder;
+ (PBZJHConfigBuilder*) builder;
+ (PBZJHConfigBuilder*) builderWithPrototype:(PBZJHConfig*) prototype;
- (PBZJHConfigBuilder*) toBuilder;

+ (PBZJHConfig*) parseFromData:(NSData*) data;
+ (PBZJHConfig*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBZJHConfig*) parseFromInputStream:(NSInputStream*) input;
+ (PBZJHConfig*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBZJHConfig*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBZJHConfig*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBZJHConfigBuilder : PBGeneratedMessageBuilder {
@private
  PBZJHConfig* resultPbzjhconfig;
}

- (PBZJHConfig*) defaultInstance;

- (PBZJHConfigBuilder*) clear;
- (PBZJHConfigBuilder*) clone;

- (PBZJHConfig*) build;
- (PBZJHConfig*) buildPartial;

- (PBZJHConfigBuilder*) mergeFrom:(PBZJHConfig*) other;
- (PBZJHConfigBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBZJHConfigBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasLevelExp;
- (SInt32) levelExp;
- (PBZJHConfigBuilder*) setLevelExp:(SInt32) value;
- (PBZJHConfigBuilder*) clearLevelExp;

- (BOOL) hasRunwayCoin;
- (SInt32) runwayCoin;
- (PBZJHConfigBuilder*) setRunwayCoin:(SInt32) value;
- (PBZJHConfigBuilder*) clearRunwayCoin;

- (BOOL) hasMaxAutoBetCount;
- (SInt32) maxAutoBetCount;
- (PBZJHConfigBuilder*) setMaxAutoBetCount:(SInt32) value;
- (PBZJHConfigBuilder*) clearMaxAutoBetCount;

- (BOOL) hasTreeMatureTime;
- (SInt32) treeMatureTime;
- (PBZJHConfigBuilder*) setTreeMatureTime:(SInt32) value;
- (PBZJHConfigBuilder*) clearTreeMatureTime;

- (BOOL) hasTreeGainTime;
- (SInt32) treeGainTime;
- (PBZJHConfigBuilder*) setTreeGainTime:(SInt32) value;
- (PBZJHConfigBuilder*) clearTreeGainTime;

- (BOOL) hasTreeCoinValue;
- (SInt32) treeCoinValue;
- (PBZJHConfigBuilder*) setTreeCoinValue:(SInt32) value;
- (PBZJHConfigBuilder*) clearTreeCoinValue;

- (BOOL) hasShareReward;
- (SInt32) shareReward;
- (PBZJHConfigBuilder*) setShareReward:(SInt32) value;
- (PBZJHConfigBuilder*) clearShareReward;
@end

@interface PBDiceConfig : PBGeneratedMessage<GeneratedMessageProtocol> {
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
  SInt32 shareReward;
  SInt32 followReward;
  SInt32 levelExp;
  SInt32 levelUpRewardCut;
  SInt32 runwayCoin;
  SInt32 normalRoomThreshhold;
  SInt32 highRoomThreshhold;
  SInt32 superHighRoomThreshhold;
  SInt32 betAnteNormalRoom;
  SInt32 betAnteHighRoom;
  SInt32 betAnteSuperHighRoom;
  SInt32 dailyGift;
  SInt32 dailyGiftIncreament;
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
@property (readonly) SInt32 shareReward;
@property (readonly) SInt32 followReward;
@property (readonly) SInt32 levelExp;
@property (readonly) SInt32 levelUpRewardCut;
@property (readonly) SInt32 runwayCoin;
@property (readonly) SInt32 normalRoomThreshhold;
@property (readonly) SInt32 highRoomThreshhold;
@property (readonly) SInt32 superHighRoomThreshhold;
@property (readonly) SInt32 betAnteNormalRoom;
@property (readonly) SInt32 betAnteHighRoom;
@property (readonly) SInt32 betAnteSuperHighRoom;
@property (readonly) SInt32 dailyGift;
@property (readonly) SInt32 dailyGiftIncreament;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBDiceConfigBuilder*) builder;
+ (PBDiceConfigBuilder*) builder;
+ (PBDiceConfigBuilder*) builderWithPrototype:(PBDiceConfig*) prototype;
- (PBDiceConfigBuilder*) toBuilder;

+ (PBDiceConfig*) parseFromData:(NSData*) data;
+ (PBDiceConfig*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBDiceConfig*) parseFromInputStream:(NSInputStream*) input;
+ (PBDiceConfig*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBDiceConfig*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBDiceConfig*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBDiceConfigBuilder : PBGeneratedMessageBuilder {
@private
  PBDiceConfig* resultPbdiceConfig;
}

- (PBDiceConfig*) defaultInstance;

- (PBDiceConfigBuilder*) clear;
- (PBDiceConfigBuilder*) clone;

- (PBDiceConfig*) build;
- (PBDiceConfig*) buildPartial;

- (PBDiceConfigBuilder*) mergeFrom:(PBDiceConfig*) other;
- (PBDiceConfigBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBDiceConfigBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasShareReward;
- (SInt32) shareReward;
- (PBDiceConfigBuilder*) setShareReward:(SInt32) value;
- (PBDiceConfigBuilder*) clearShareReward;

- (BOOL) hasFollowReward;
- (SInt32) followReward;
- (PBDiceConfigBuilder*) setFollowReward:(SInt32) value;
- (PBDiceConfigBuilder*) clearFollowReward;

- (BOOL) hasLevelExp;
- (SInt32) levelExp;
- (PBDiceConfigBuilder*) setLevelExp:(SInt32) value;
- (PBDiceConfigBuilder*) clearLevelExp;

- (BOOL) hasLevelUpRewardCut;
- (SInt32) levelUpRewardCut;
- (PBDiceConfigBuilder*) setLevelUpRewardCut:(SInt32) value;
- (PBDiceConfigBuilder*) clearLevelUpRewardCut;

- (BOOL) hasRunwayCoin;
- (SInt32) runwayCoin;
- (PBDiceConfigBuilder*) setRunwayCoin:(SInt32) value;
- (PBDiceConfigBuilder*) clearRunwayCoin;

- (BOOL) hasNormalRoomThreshhold;
- (SInt32) normalRoomThreshhold;
- (PBDiceConfigBuilder*) setNormalRoomThreshhold:(SInt32) value;
- (PBDiceConfigBuilder*) clearNormalRoomThreshhold;

- (BOOL) hasHighRoomThreshhold;
- (SInt32) highRoomThreshhold;
- (PBDiceConfigBuilder*) setHighRoomThreshhold:(SInt32) value;
- (PBDiceConfigBuilder*) clearHighRoomThreshhold;

- (BOOL) hasSuperHighRoomThreshhold;
- (SInt32) superHighRoomThreshhold;
- (PBDiceConfigBuilder*) setSuperHighRoomThreshhold:(SInt32) value;
- (PBDiceConfigBuilder*) clearSuperHighRoomThreshhold;

- (BOOL) hasBetAnteNormalRoom;
- (SInt32) betAnteNormalRoom;
- (PBDiceConfigBuilder*) setBetAnteNormalRoom:(SInt32) value;
- (PBDiceConfigBuilder*) clearBetAnteNormalRoom;

- (BOOL) hasBetAnteHighRoom;
- (SInt32) betAnteHighRoom;
- (PBDiceConfigBuilder*) setBetAnteHighRoom:(SInt32) value;
- (PBDiceConfigBuilder*) clearBetAnteHighRoom;

- (BOOL) hasBetAnteSuperHighRoom;
- (SInt32) betAnteSuperHighRoom;
- (PBDiceConfigBuilder*) setBetAnteSuperHighRoom:(SInt32) value;
- (PBDiceConfigBuilder*) clearBetAnteSuperHighRoom;

- (BOOL) hasDailyGift;
- (SInt32) dailyGift;
- (PBDiceConfigBuilder*) setDailyGift:(SInt32) value;
- (PBDiceConfigBuilder*) clearDailyGift;

- (BOOL) hasDailyGiftIncreament;
- (SInt32) dailyGiftIncreament;
- (PBDiceConfigBuilder*) setDailyGiftIncreament:(SInt32) value;
- (PBDiceConfigBuilder*) clearDailyGiftIncreament;
@end

@interface PBDrawConfig : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasDefaultOnlineEnServerPort_:1;
  BOOL hasDefaultOnlineCnServerPort_:1;
  BOOL hasGuessReward_:1;
  BOOL hasTomatoReward_:1;
  BOOL hasTomatoExp_:1;
  BOOL hasFlowerReward_:1;
  BOOL hasFlowerExp_:1;
  BOOL hasShareReward_:1;
  BOOL hasFollowReward_:1;
  BOOL hasLevelUpFlower_:1;
  BOOL hasOnlineDrawExp_:1;
  BOOL hasOnlineGuessExp_:1;
  BOOL hasOfflineDrawExp_:1;
  BOOL hasOfflineGuessExp_:1;
  BOOL hasMaxItemTimesOnNormalOpus_:1;
  BOOL hasMaxItemTimesOnContestOpus_:1;
  BOOL hasDefaultOnlineEnServerAddress_:1;
  BOOL hasDefaultOnlineCnServerAddress_:1;
  SInt32 defaultOnlineEnServerPort;
  SInt32 defaultOnlineCnServerPort;
  SInt32 guessReward;
  SInt32 tomatoReward;
  SInt32 tomatoExp;
  SInt32 flowerReward;
  SInt32 flowerExp;
  SInt32 shareReward;
  SInt32 followReward;
  SInt32 levelUpFlower;
  SInt32 onlineDrawExp;
  SInt32 onlineGuessExp;
  SInt32 offlineDrawExp;
  SInt32 offlineGuessExp;
  SInt32 maxItemTimesOnNormalOpus;
  SInt32 maxItemTimesOnContestOpus;
  NSString* defaultOnlineEnServerAddress;
  NSString* defaultOnlineCnServerAddress;
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
@property (readonly, strong) NSString* defaultOnlineEnServerAddress;
@property (readonly) SInt32 defaultOnlineEnServerPort;
@property (readonly, strong) NSString* defaultOnlineCnServerAddress;
@property (readonly) SInt32 defaultOnlineCnServerPort;
@property (readonly) SInt32 guessReward;
@property (readonly) SInt32 tomatoReward;
@property (readonly) SInt32 tomatoExp;
@property (readonly) SInt32 flowerReward;
@property (readonly) SInt32 flowerExp;
@property (readonly) SInt32 shareReward;
@property (readonly) SInt32 followReward;
@property (readonly) SInt32 levelUpFlower;
@property (readonly) SInt32 onlineDrawExp;
@property (readonly) SInt32 onlineGuessExp;
@property (readonly) SInt32 offlineDrawExp;
@property (readonly) SInt32 offlineGuessExp;
@property (readonly) SInt32 maxItemTimesOnNormalOpus;
@property (readonly) SInt32 maxItemTimesOnContestOpus;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBDrawConfigBuilder*) builder;
+ (PBDrawConfigBuilder*) builder;
+ (PBDrawConfigBuilder*) builderWithPrototype:(PBDrawConfig*) prototype;
- (PBDrawConfigBuilder*) toBuilder;

+ (PBDrawConfig*) parseFromData:(NSData*) data;
+ (PBDrawConfig*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBDrawConfig*) parseFromInputStream:(NSInputStream*) input;
+ (PBDrawConfig*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBDrawConfig*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBDrawConfig*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBDrawConfigBuilder : PBGeneratedMessageBuilder {
@private
  PBDrawConfig* resultPbdrawConfig;
}

- (PBDrawConfig*) defaultInstance;

- (PBDrawConfigBuilder*) clear;
- (PBDrawConfigBuilder*) clone;

- (PBDrawConfig*) build;
- (PBDrawConfig*) buildPartial;

- (PBDrawConfigBuilder*) mergeFrom:(PBDrawConfig*) other;
- (PBDrawConfigBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBDrawConfigBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasDefaultOnlineEnServerAddress;
- (NSString*) defaultOnlineEnServerAddress;
- (PBDrawConfigBuilder*) setDefaultOnlineEnServerAddress:(NSString*) value;
- (PBDrawConfigBuilder*) clearDefaultOnlineEnServerAddress;

- (BOOL) hasDefaultOnlineEnServerPort;
- (SInt32) defaultOnlineEnServerPort;
- (PBDrawConfigBuilder*) setDefaultOnlineEnServerPort:(SInt32) value;
- (PBDrawConfigBuilder*) clearDefaultOnlineEnServerPort;

- (BOOL) hasDefaultOnlineCnServerAddress;
- (NSString*) defaultOnlineCnServerAddress;
- (PBDrawConfigBuilder*) setDefaultOnlineCnServerAddress:(NSString*) value;
- (PBDrawConfigBuilder*) clearDefaultOnlineCnServerAddress;

- (BOOL) hasDefaultOnlineCnServerPort;
- (SInt32) defaultOnlineCnServerPort;
- (PBDrawConfigBuilder*) setDefaultOnlineCnServerPort:(SInt32) value;
- (PBDrawConfigBuilder*) clearDefaultOnlineCnServerPort;

- (BOOL) hasGuessReward;
- (SInt32) guessReward;
- (PBDrawConfigBuilder*) setGuessReward:(SInt32) value;
- (PBDrawConfigBuilder*) clearGuessReward;

- (BOOL) hasTomatoReward;
- (SInt32) tomatoReward;
- (PBDrawConfigBuilder*) setTomatoReward:(SInt32) value;
- (PBDrawConfigBuilder*) clearTomatoReward;

- (BOOL) hasTomatoExp;
- (SInt32) tomatoExp;
- (PBDrawConfigBuilder*) setTomatoExp:(SInt32) value;
- (PBDrawConfigBuilder*) clearTomatoExp;

- (BOOL) hasFlowerReward;
- (SInt32) flowerReward;
- (PBDrawConfigBuilder*) setFlowerReward:(SInt32) value;
- (PBDrawConfigBuilder*) clearFlowerReward;

- (BOOL) hasFlowerExp;
- (SInt32) flowerExp;
- (PBDrawConfigBuilder*) setFlowerExp:(SInt32) value;
- (PBDrawConfigBuilder*) clearFlowerExp;

- (BOOL) hasShareReward;
- (SInt32) shareReward;
- (PBDrawConfigBuilder*) setShareReward:(SInt32) value;
- (PBDrawConfigBuilder*) clearShareReward;

- (BOOL) hasFollowReward;
- (SInt32) followReward;
- (PBDrawConfigBuilder*) setFollowReward:(SInt32) value;
- (PBDrawConfigBuilder*) clearFollowReward;

- (BOOL) hasLevelUpFlower;
- (SInt32) levelUpFlower;
- (PBDrawConfigBuilder*) setLevelUpFlower:(SInt32) value;
- (PBDrawConfigBuilder*) clearLevelUpFlower;

- (BOOL) hasOnlineDrawExp;
- (SInt32) onlineDrawExp;
- (PBDrawConfigBuilder*) setOnlineDrawExp:(SInt32) value;
- (PBDrawConfigBuilder*) clearOnlineDrawExp;

- (BOOL) hasOnlineGuessExp;
- (SInt32) onlineGuessExp;
- (PBDrawConfigBuilder*) setOnlineGuessExp:(SInt32) value;
- (PBDrawConfigBuilder*) clearOnlineGuessExp;

- (BOOL) hasOfflineDrawExp;
- (SInt32) offlineDrawExp;
- (PBDrawConfigBuilder*) setOfflineDrawExp:(SInt32) value;
- (PBDrawConfigBuilder*) clearOfflineDrawExp;

- (BOOL) hasOfflineGuessExp;
- (SInt32) offlineGuessExp;
- (PBDrawConfigBuilder*) setOfflineGuessExp:(SInt32) value;
- (PBDrawConfigBuilder*) clearOfflineGuessExp;

- (BOOL) hasMaxItemTimesOnNormalOpus;
- (SInt32) maxItemTimesOnNormalOpus;
- (PBDrawConfigBuilder*) setMaxItemTimesOnNormalOpus:(SInt32) value;
- (PBDrawConfigBuilder*) clearMaxItemTimesOnNormalOpus;

- (BOOL) hasMaxItemTimesOnContestOpus;
- (SInt32) maxItemTimesOnContestOpus;
- (PBDrawConfigBuilder*) setMaxItemTimesOnContestOpus:(SInt32) value;
- (PBDrawConfigBuilder*) clearMaxItemTimesOnContestOpus;
@end

@interface PBAppReward : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasRewardAmount_:1;
  BOOL hasApp_:1;
  BOOL hasRewardCurrency_:1;
  SInt32 rewardAmount;
  PBApp* app;
  PBGameCurrency rewardCurrency;
}
- (BOOL) hasApp;
- (BOOL) hasRewardAmount;
- (BOOL) hasRewardCurrency;
@property (readonly, strong) PBApp* app;
@property (readonly) SInt32 rewardAmount;
@property (readonly) PBGameCurrency rewardCurrency;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBAppRewardBuilder*) builder;
+ (PBAppRewardBuilder*) builder;
+ (PBAppRewardBuilder*) builderWithPrototype:(PBAppReward*) prototype;
- (PBAppRewardBuilder*) toBuilder;

+ (PBAppReward*) parseFromData:(NSData*) data;
+ (PBAppReward*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBAppReward*) parseFromInputStream:(NSInputStream*) input;
+ (PBAppReward*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBAppReward*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBAppReward*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBAppRewardBuilder : PBGeneratedMessageBuilder {
@private
  PBAppReward* resultPbappReward;
}

- (PBAppReward*) defaultInstance;

- (PBAppRewardBuilder*) clear;
- (PBAppRewardBuilder*) clone;

- (PBAppReward*) build;
- (PBAppReward*) buildPartial;

- (PBAppRewardBuilder*) mergeFrom:(PBAppReward*) other;
- (PBAppRewardBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBAppRewardBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasApp;
- (PBApp*) app;
- (PBAppRewardBuilder*) setApp:(PBApp*) value;
- (PBAppRewardBuilder*) setAppBuilder:(PBAppBuilder*) builderForValue;
- (PBAppRewardBuilder*) mergeApp:(PBApp*) value;
- (PBAppRewardBuilder*) clearApp;

- (BOOL) hasRewardAmount;
- (SInt32) rewardAmount;
- (PBAppRewardBuilder*) setRewardAmount:(SInt32) value;
- (PBAppRewardBuilder*) clearRewardAmount;

- (BOOL) hasRewardCurrency;
- (PBGameCurrency) rewardCurrency;
- (PBAppRewardBuilder*) setRewardCurrency:(PBGameCurrency) value;
- (PBAppRewardBuilder*) clearRewardCurrency;
@end

@interface PBRewardWall : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasType_:1;
  BOOL hasLogo_:1;
  SInt32 type;
  NSString* logo;
  NSMutableArray * nameArray;
}
- (BOOL) hasType;
- (BOOL) hasLogo;
@property (readonly) SInt32 type;
@property (readonly, strong) NSString* logo;
@property (readonly, strong) NSArray * name;
- (PBLocalizeString*)nameAtIndex:(NSUInteger)index;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBRewardWallBuilder*) builder;
+ (PBRewardWallBuilder*) builder;
+ (PBRewardWallBuilder*) builderWithPrototype:(PBRewardWall*) prototype;
- (PBRewardWallBuilder*) toBuilder;

+ (PBRewardWall*) parseFromData:(NSData*) data;
+ (PBRewardWall*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBRewardWall*) parseFromInputStream:(NSInputStream*) input;
+ (PBRewardWall*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBRewardWall*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBRewardWall*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBRewardWallBuilder : PBGeneratedMessageBuilder {
@private
  PBRewardWall* resultPbrewardWall;
}

- (PBRewardWall*) defaultInstance;

- (PBRewardWallBuilder*) clear;
- (PBRewardWallBuilder*) clone;

- (PBRewardWall*) build;
- (PBRewardWall*) buildPartial;

- (PBRewardWallBuilder*) mergeFrom:(PBRewardWall*) other;
- (PBRewardWallBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBRewardWallBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasType;
- (SInt32) type;
- (PBRewardWallBuilder*) setType:(SInt32) value;
- (PBRewardWallBuilder*) clearType;

- (BOOL) hasLogo;
- (NSString*) logo;
- (PBRewardWallBuilder*) setLogo:(NSString*) value;
- (PBRewardWallBuilder*) clearLogo;

- (NSMutableArray *)name;
- (PBLocalizeString*)nameAtIndex:(NSUInteger)index;
- (PBRewardWallBuilder *)addName:(PBLocalizeString*)value;
- (PBRewardWallBuilder *)setNameArray:(NSArray *)array;
- (PBRewardWallBuilder *)clearName;
@end

@interface PBConfig : PBGeneratedMessage<GeneratedMessageProtocol> {
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
  BOOL hasDrawConfig_:1;
  BOOL hasDiceConfig_:1;
  BOOL hasZjhConfig_:1;
  BOOL enableReview_:1;
  BOOL inReview_:1;
  BOOL enableAd_:1;
  BOOL enableWall_:1;
  SInt32 balanceDeviation;
  SInt32 postponeTime;
  SInt32 urgeTime;
  SInt32 wallType;
  NSString* trafficApiserverUrl;
  NSString* userApiserverUrl;
  NSString* musicHomeCnUrl;
  NSString* musicHomeEnUrl;
  NSString* inReviewVersion;
  PBDrawConfig* drawConfig;
  PBDiceConfig* diceConfig;
  PBZJHConfig* zjhConfig;
  NSMutableArray * coinPricesArray;
  NSMutableArray * rewardWallsArray;
  NSMutableArray * appRewardsArray;
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
@property (readonly, strong) NSArray * coinPrices;
@property (readonly) SInt32 balanceDeviation;
@property (readonly, strong) NSString* trafficApiserverUrl;
@property (readonly, strong) NSString* userApiserverUrl;
@property (readonly, strong) NSString* musicHomeCnUrl;
@property (readonly, strong) NSString* musicHomeEnUrl;
- (BOOL) enableReview;
- (BOOL) inReview;
@property (readonly, strong) NSString* inReviewVersion;
@property (readonly) SInt32 postponeTime;
@property (readonly) SInt32 urgeTime;
- (BOOL) enableAd;
- (BOOL) enableWall;
@property (readonly) SInt32 wallType;
@property (readonly, strong) NSArray * rewardWalls;
@property (readonly, strong) NSArray * appRewards;
@property (readonly, strong) PBDrawConfig* drawConfig;
@property (readonly, strong) PBDiceConfig* diceConfig;
@property (readonly, strong) PBZJHConfig* zjhConfig;
- (PBPrice*)coinPricesAtIndex:(NSUInteger)index;
- (PBRewardWall*)rewardWallsAtIndex:(NSUInteger)index;
- (PBAppReward*)appRewardsAtIndex:(NSUInteger)index;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBConfigBuilder*) builder;
+ (PBConfigBuilder*) builder;
+ (PBConfigBuilder*) builderWithPrototype:(PBConfig*) prototype;
- (PBConfigBuilder*) toBuilder;

+ (PBConfig*) parseFromData:(NSData*) data;
+ (PBConfig*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBConfig*) parseFromInputStream:(NSInputStream*) input;
+ (PBConfig*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBConfig*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBConfig*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBConfigBuilder : PBGeneratedMessageBuilder {
@private
  PBConfig* resultPbconfig;
}

- (PBConfig*) defaultInstance;

- (PBConfigBuilder*) clear;
- (PBConfigBuilder*) clone;

- (PBConfig*) build;
- (PBConfig*) buildPartial;

- (PBConfigBuilder*) mergeFrom:(PBConfig*) other;
- (PBConfigBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBConfigBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (NSMutableArray *)coinPrices;
- (PBPrice*)coinPricesAtIndex:(NSUInteger)index;
- (PBConfigBuilder *)addCoinPrices:(PBPrice*)value;
- (PBConfigBuilder *)setCoinPricesArray:(NSArray *)array;
- (PBConfigBuilder *)clearCoinPrices;

- (BOOL) hasBalanceDeviation;
- (SInt32) balanceDeviation;
- (PBConfigBuilder*) setBalanceDeviation:(SInt32) value;
- (PBConfigBuilder*) clearBalanceDeviation;

- (BOOL) hasTrafficApiserverUrl;
- (NSString*) trafficApiserverUrl;
- (PBConfigBuilder*) setTrafficApiserverUrl:(NSString*) value;
- (PBConfigBuilder*) clearTrafficApiserverUrl;

- (BOOL) hasUserApiserverUrl;
- (NSString*) userApiserverUrl;
- (PBConfigBuilder*) setUserApiserverUrl:(NSString*) value;
- (PBConfigBuilder*) clearUserApiserverUrl;

- (BOOL) hasMusicHomeCnUrl;
- (NSString*) musicHomeCnUrl;
- (PBConfigBuilder*) setMusicHomeCnUrl:(NSString*) value;
- (PBConfigBuilder*) clearMusicHomeCnUrl;

- (BOOL) hasMusicHomeEnUrl;
- (NSString*) musicHomeEnUrl;
- (PBConfigBuilder*) setMusicHomeEnUrl:(NSString*) value;
- (PBConfigBuilder*) clearMusicHomeEnUrl;

- (BOOL) hasEnableReview;
- (BOOL) enableReview;
- (PBConfigBuilder*) setEnableReview:(BOOL) value;
- (PBConfigBuilder*) clearEnableReview;

- (BOOL) hasInReview;
- (BOOL) inReview;
- (PBConfigBuilder*) setInReview:(BOOL) value;
- (PBConfigBuilder*) clearInReview;

- (BOOL) hasInReviewVersion;
- (NSString*) inReviewVersion;
- (PBConfigBuilder*) setInReviewVersion:(NSString*) value;
- (PBConfigBuilder*) clearInReviewVersion;

- (BOOL) hasPostponeTime;
- (SInt32) postponeTime;
- (PBConfigBuilder*) setPostponeTime:(SInt32) value;
- (PBConfigBuilder*) clearPostponeTime;

- (BOOL) hasUrgeTime;
- (SInt32) urgeTime;
- (PBConfigBuilder*) setUrgeTime:(SInt32) value;
- (PBConfigBuilder*) clearUrgeTime;

- (BOOL) hasEnableAd;
- (BOOL) enableAd;
- (PBConfigBuilder*) setEnableAd:(BOOL) value;
- (PBConfigBuilder*) clearEnableAd;

- (BOOL) hasEnableWall;
- (BOOL) enableWall;
- (PBConfigBuilder*) setEnableWall:(BOOL) value;
- (PBConfigBuilder*) clearEnableWall;

- (BOOL) hasWallType;
- (SInt32) wallType;
- (PBConfigBuilder*) setWallType:(SInt32) value;
- (PBConfigBuilder*) clearWallType;

- (NSMutableArray *)rewardWalls;
- (PBRewardWall*)rewardWallsAtIndex:(NSUInteger)index;
- (PBConfigBuilder *)addRewardWalls:(PBRewardWall*)value;
- (PBConfigBuilder *)setRewardWallsArray:(NSArray *)array;
- (PBConfigBuilder *)clearRewardWalls;

- (NSMutableArray *)appRewards;
- (PBAppReward*)appRewardsAtIndex:(NSUInteger)index;
- (PBConfigBuilder *)addAppRewards:(PBAppReward*)value;
- (PBConfigBuilder *)setAppRewardsArray:(NSArray *)array;
- (PBConfigBuilder *)clearAppRewards;

- (BOOL) hasDrawConfig;
- (PBDrawConfig*) drawConfig;
- (PBConfigBuilder*) setDrawConfig:(PBDrawConfig*) value;
- (PBConfigBuilder*) setDrawConfigBuilder:(PBDrawConfigBuilder*) builderForValue;
- (PBConfigBuilder*) mergeDrawConfig:(PBDrawConfig*) value;
- (PBConfigBuilder*) clearDrawConfig;

- (BOOL) hasDiceConfig;
- (PBDiceConfig*) diceConfig;
- (PBConfigBuilder*) setDiceConfig:(PBDiceConfig*) value;
- (PBConfigBuilder*) setDiceConfigBuilder:(PBDiceConfigBuilder*) builderForValue;
- (PBConfigBuilder*) mergeDiceConfig:(PBDiceConfig*) value;
- (PBConfigBuilder*) clearDiceConfig;

- (BOOL) hasZjhConfig;
- (PBZJHConfig*) zjhConfig;
- (PBConfigBuilder*) setZjhConfig:(PBZJHConfig*) value;
- (PBConfigBuilder*) setZjhConfigBuilder:(PBZJHConfigBuilder*) builderForValue;
- (PBConfigBuilder*) mergeZjhConfig:(PBZJHConfig*) value;
- (PBConfigBuilder*) clearZjhConfig;
@end


// @@protoc_insertion_point(global_scope)
