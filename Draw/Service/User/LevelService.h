//
//  LevelService.h
//  Draw
//
//  Created by Orange on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"
#import "ConfigManager.h"

enum {
    SYNC = 0,
    UPDATE = 1,
    AWARD = 2
};

typedef enum {
    LevelSourceDraw = 0,
    LevelSourceDice,
    LevelSourceZhajinhua,
    LevelSourceCount
}LevelSource;

#define OFFLINE_DRAW_EXP    ([ConfigManager getOffLineDrawExp])
#define OFFLINE_GUESS_EXP   ([ConfigManager getOffLineGuessExp])
#define NORMAL_EXP          ([ConfigManager getOnLineGuessExp])
#define DRAWER_EXP          ([ConfigManager getOnLineDrawExp])
#define LIAR_DICE_EXP       ([ConfigManager getLiarDiceExp])
#define ZHAJINHUA_EXP       ([ConfigManager getZhajinhuaExp])

//#define REWARD_EXP  5

@class PPViewController;

@protocol LevelServiceDelegate <NSObject>
@optional
- (void)levelUp:(int)level;
- (void)levelDown:(int)level;

@end

@interface LevelService : CommonService
@property (assign, nonatomic) id<LevelServiceDelegate> delegate;
@property (retain, nonatomic) NSMutableArray* levelMap;

+ (LevelService*)defaultService;

//- (void)setLevel:(NSInteger)level;
//- (void)setExperience:(long)experience;
- (int)level;
- (long)experience;

- (void)addExp:(long)exp 
      delegate:(id<LevelServiceDelegate>)delegate;

- (void)minusExp:(long)exp 
        delegate:(id<LevelServiceDelegate>)delegate;

- (void)awardExp:(long)exp
        delegate:(id<LevelServiceDelegate>)delegate;

- (long)expRequiredForNextLevel;

- (long)getExpByLevel:(int)level;

//- (void)syncExpAndLevel:(PPViewController*)viewController 
//                   type:(int)type;
//- (void)syncExpAndLevel:(int)type;
//- (void)syncExpAndLevel:(int)type awardExp:(long)awardExp;

//- (void)initLevelDict;
//methods below for the one
/*
- (int)levelForSource:(LevelSource)source;
- (long)experienceForSource:(LevelSource)source;

- (void)addExp:(long)exp
      delegate:(id<LevelServiceDelegate>)delegate
     forSource:(LevelSource)source;

- (void)minusExp:(long)exp
        delegate:(id<LevelServiceDelegate>)delegate
       forSource:(LevelSource)source;

- (void)awardExp:(long)exp
        delegate:(id<LevelServiceDelegate>)delegate
       forSource:(LevelSource)source;

- (void)syncExpAndLevel:(int)type
              forSource:(LevelSource)source;
- (void)syncExpAndLevel:(int)type awardExp:(long)awardExp
              forSource:(LevelSource)source;
*/

- (void)setExperience:(long)experience;
- (void)setLevel:(NSInteger)level;

@end
