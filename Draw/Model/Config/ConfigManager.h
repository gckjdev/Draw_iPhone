//
//  ConfigManager.h
//  Draw
//
//  Created by  on 12-4-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobClickUtils.h"

@interface ConfigManager : NSObject

+ (int)getGuessRewardNormal;
+ (NSString*)getChannelId;

+ (NSString*)defaultEnglishServer;
+ (NSString*)defaultChineseServer;
+ (int)defaultEnglishPort;
+ (int)defaultChinesePort;

+ (int)guessDifficultLevel;
+ (void)setGuessDifficultLevel:(int)level;

@end
