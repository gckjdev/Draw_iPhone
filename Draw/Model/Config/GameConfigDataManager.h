//
//  GameConfigDataManager.h
//  Draw
//
//  Created by qqn_pipi on 12-11-30.
//
//

#import <Foundation/Foundation.h>

@class PBConfig;
@class PBAppReward;
@class PBRewardWall;

@interface GameConfigDataManager : NSObject

+ (GameConfigDataManager*)defaultInstance;
+ (GameConfigDataManager*)defaultManager;

@property (nonatomic, readonly) PBConfig* defaultConfig;

+ (void)createTestConfigData;

+ (NSString*)configFileName;

+ (PBAppReward*)drawAppWithRewardAmount:(int)rewardAmount
                         rewardCurrency:(PBGameCurrency)rewardCurrency;

+ (PBAppReward*)diceAppWithRewardAmount:(int)rewardAmount
                         rewardCurrency:(PBGameCurrency)rewardCurrency;

+ (PBAppReward*)zjhAppWithRewardAmount:(int)rewardAmount
                        rewardCurrency:(PBGameCurrency)rewardCurrency;

+ (PBAppReward*)oldDiceAppWithRewardAmount:(int)rewardAmount
                            rewardCurrency:(PBGameCurrency)rewardCurrency;

+ (PBRewardWall*)limeiWall;
+ (PBRewardWall*)wanpuWall;
+ (PBRewardWall*)youmiWall;
+ (PBRewardWall*)aderWall;
+ (PBRewardWall*)domodWall;
+ (PBRewardWall*)tapjoyWall;

- (NSArray*)appRewardList;
- (NSArray*)rewardWallList;
- (void)syncData;

@end
