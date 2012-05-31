//
//  LevelService.m
//  Draw
//
//  Created by Orange on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LevelService.h"

#define KEY_LEVEL           @"USER_KEY_LEVEL"
#define KEY_EXP             @"USER_KEY_EXPERIENCE"

@implementation LevelService

- (NSNumber*)level
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* value = [userDefaults objectForKey:KEY_LEVEL];
    return value;
}

- (NSNumber*)experience
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* value = [userDefaults objectForKey:KEY_EXP];
    return value;
}

- (void)setLevel:(NSInteger)level
{
    if (level <= 0)
        return;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithInt:level] forKey:KEY_LEVEL];    
    [userDefaults synchronize];
}
- (void)setExperience:(float)experience
{
    if (experience <= 0)
        return;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithFloat:experience] forKey:KEY_EXP];    
    [userDefaults synchronize];
}

@end
