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
    UPDATE = 1
};

@class PPViewController;

@protocol LevelServiceDelegate <NSObject>
@optional
- (void)levelUp:(int)level;
- (void)levelDown:(int)level;

@end

@interface LevelService : CommonService
@property (assign, nonatomic) id<LevelServiceDelegate> delegate;

+ (LevelService*)defaultService;

- (void)setLevel:(NSInteger)level;
- (void)setExperience:(long)experience;
- (int)level;
- (long)experience;

- (void)addExp:(long)exp;
- (void)minusExp:(long)exp;
- (long)expRequiredForNextLevel;
- (void)syncExpAndLevel:(PPViewController*)viewController 
                   type:(int)type;
- (void)syncExpAndLevel:(int)type;

@end
