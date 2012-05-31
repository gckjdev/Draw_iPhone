//
//  LevelService.h
//  Draw
//
//  Created by Orange on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LevelServiceDelegate <NSObject>
@optional
- (void)levelUp:(int)level;

@end

@interface LevelService : NSObject

- (void)setLevel:(NSInteger)level;
//- (void)setExperience:(float)experience;
- (NSNumber*)level;
- (NSNumber*)experience;

- (void)addExp:(float)exp;
- (void)minusExp:(float)exp;
- (float)expRequiredForNextLevel;

@end
