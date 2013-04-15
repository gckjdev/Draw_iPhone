//
//  GameConfigDataManager.h
//  Draw
//
//  Created by qqn_pipi on 12-11-30.
//
//

#import <Foundation/Foundation.h>

@class PBConfig;

@interface GameConfigDataManager : NSObject

+ (GameConfigDataManager*)defaultInstance;
+ (GameConfigDataManager*)defaultManager;

@property (nonatomic, readonly) PBConfig* defaultConfig;

+ (void)createTestConfigData;
+ (void)createLearnDrawTestConfigData;

- (NSArray*)appRewardList;
- (NSArray*)rewardWallList;
- (void)syncData;

@end
