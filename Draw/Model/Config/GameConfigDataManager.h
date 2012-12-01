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

@property (nonatomic, readonly) PBConfig* defaultConfig;

+ (void)createTestConfigData;

@end
