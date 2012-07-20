//
//  LevelService.h
//  Draw
//
//  Created by Orange on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"

enum {
    SYNC = 0,
    UPDATE = 1,
    AWARD = 2
};

#define OFFLINE_DRAW_EXP    1000
#define NORMAL_EXP          1000
#define DRAWER_EXP          1500

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

- (void)setLevel:(NSInteger)level;
- (void)setExperience:(long)experience;
- (int)level;
- (long)experience;

- (void)addExp:(long)exp 
      delegate:(id<LevelServiceDelegate>)delegate;

- (void)minusExp:(long)exp 
        delegate:(id<LevelServiceDelegate>)delegate;

- (void)awardExp:(long)exp
        delegate:(id<LevelServiceDelegate>)delegate;

- (long)expRequiredForNextLevel;

- (void)syncExpAndLevel:(PPViewController*)viewController 
                   type:(int)type;
- (void)syncExpAndLevel:(int)type;
- (void)syncExpAndLevel:(int)type awardExp:(long)awardExp;

- (void)initLevelDict;

@end
