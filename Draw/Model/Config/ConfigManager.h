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


@interface ConfigManager : NSObject

+ (int)getBalanceDeviation;

+ (int)getGuessRewardNormal;
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

+ (int)flowerAwardFordLevelUp;

@end
