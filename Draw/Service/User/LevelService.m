//
//  LevelService.m
//  Draw
//
//  Created by Orange on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LevelService.h"
#import "PPViewController.h"
#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "UserManager.h"
#import "ConfigManager.h"

#define KEY_LEVEL           @"USER_KEY_LEVEL"
#define KEY_EXP             @"USER_KEY_EXPERIENCE"
#define MAX_LEVEL           50
#define FIRST_LEVEL_EXP     60
#define EXP_INC_RATE        1.08

//const static long levelExpMap[MAX_LEVEL] = {0,60, 180, 360, 600, 900, 1224, 1573, 1950, 2356, 2795, 3269, 3779, 4331, 4925, 5567, 6259, 7007, 7813, 8683, 9621, 10634, 11726, 12905, 14177, 15550, 17031, 18629, 20354, 22214, 24222, 26388, 28725, 31247, 33968, 36904, 40072, 43490, 47178, 51158, 55452, 60086, 65085, 70479, 76300, 82580, 89356, 96668, 104558, 113070};

static LevelService* _defaultLevelService;



@implementation LevelService
@synthesize delegate = _delegate;
@synthesize levelMap = _levelMap;

+ (LevelService*)defaultService
{
    if (_defaultLevelService == nil) {
        _defaultLevelService = [[LevelService alloc] init];
        [_defaultLevelService initLevelDict];
    }
    
    return _defaultLevelService;
}

- (id)init
{
    self = [super init];
    if (self) {
        _levelMap = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)initLevelDict
{
    int exp = 0;
    //int baseExp = self.level1Exp.text.intValue;
    int lastLevelUpExp = 0.0;
    
    for (int i = 0; i <= MAX_LEVEL; i++) {
        if (i <= 5) {            
            lastLevelUpExp = FIRST_LEVEL_EXP*i;
            exp = exp+lastLevelUpExp;
        } else {
            lastLevelUpExp = (int)lastLevelUpExp*EXP_INC_RATE;
            exp = exp+lastLevelUpExp;
        }
        [self.levelMap addObject:[NSNumber numberWithLong:exp]];
        
    }
}

- (int)level
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* value = [userDefaults objectForKey:KEY_LEVEL];
    if (value) {
        return value.intValue;
    }
    return 1;
}

- (long)experience
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* value = [userDefaults objectForKey:KEY_EXP];
    if (value) {
        return value.longValue;
    }
    return 0;
}

- (void)setLevel:(NSInteger)level
{
    if (level <= 0)
        return;
    
    PPDebug(@"<setLevel> level=%d", level);
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithLong:level] forKey:KEY_LEVEL];    
    [userDefaults synchronize];
}
- (void)setExperience:(long)experience
{
    if (experience < 0)
        return;
    
    PPDebug(@"<setExperience> experience=%ld", experience);
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithLong:experience] forKey:KEY_EXP];    
    [userDefaults synchronize];
}

- (int)getLevelByExp:(long)exp
{
    long maxExp = ((NSNumber*)[self.levelMap objectAtIndex:MAX_LEVEL]).longValue;
    if (exp >= maxExp) {
        return MAX_LEVEL;
    }
    for (int i = 1; i < MAX_LEVEL; i ++) {
        NSNumber* low = (NSNumber*)[self.levelMap objectAtIndex:i-1];
        NSNumber* high = (NSNumber*)[self.levelMap objectAtIndex:i];
        if (exp >= low.longValue && exp <high.longValue) {
            return i;
        }
    }
    return 1;
}


- (void)addExp:(long)exp 
      delegate:(id<LevelServiceDelegate>)delegate
{
    long currentExp = [self experience] + exp ;
    int newLevel = [self getLevelByExp:(currentExp)];
    [self setExperience:(currentExp)];
    if ([self level] != newLevel) {
        [self setLevel:newLevel];
        if (delegate && [delegate respondsToSelector:@selector(levelUp:)]) {
            [delegate levelUp:newLevel];
        }
    }
    [self syncExpAndLevel:UPDATE];
}

- (void)awardExp:(long)awardExp
        delegate:(id<LevelServiceDelegate>)delegate
{
    if (awardExp > 0){
        long exp = abs(awardExp);
        long currentExp = [self experience] + exp ;
        int newLevel = [self getLevelByExp:(currentExp)];
        [self setExperience:(currentExp)];
        if ([self level] != newLevel) {
            [self setLevel:newLevel];
            if (delegate && [delegate respondsToSelector:@selector(levelUp:)]) {
                [delegate levelUp:newLevel];
            }
        }
    }
    else{
        long exp = abs(awardExp);
        long currentExp = [self experience]-exp;
        [self setExperience:(currentExp)];
        int newLevel = [self getLevelByExp:(currentExp)];
        if ([self level] != newLevel) {
            [self setLevel:newLevel];
            if (delegate && [delegate respondsToSelector:@selector(levelDown:)]) {
                [delegate levelDown:newLevel];
            }
        }        
    }
    [self syncExpAndLevel:AWARD awardExp:awardExp];
}

- (void)minusExp:(long)exp 
        delegate:(id<LevelServiceDelegate>)delegate
{
    long currentExp = [self experience]-exp;
    [self setExperience:(currentExp)];
    int newLevel = [self getLevelByExp:(currentExp)];
    if ([self level] != newLevel) {
        [self setLevel:newLevel];
        if (delegate && [delegate respondsToSelector:@selector(levelDown:)]) {
            [delegate levelDown:newLevel];
        }
    }
    [self syncExpAndLevel:UPDATE];
}

- (long)expRequiredForNextLevel
{
    int level = [self level];
    NSNumber* num = (NSNumber*)[self.levelMap objectAtIndex:level];
    return num.longValue;
}



- (void)syncExpAndLevel:(PPViewController*)viewController 
                   type:(int)type
{
    if ([[UserManager defaultManager] hasUser] == NO){
        PPDebug(@"<syncExpAndLevel> but user not found yet.");
        return;
    }
    
    //[viewController showActivityWithText:NSLS(@"kRegisteringUser")];    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = nil;        
        output = [GameNetworkRequest syncExpAndLevel:SERVER_URL 
                                               appId:[ConfigManager appId] 
                                              gameId:[ConfigManager gameId]
                                              userId:[UserManager defaultManager].userId 
                                               level:[self level] 
                                                 exp:[self experience] 
                                                type:type
                                            awardExp:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS) {
                if (type == SYNC) {
                    NSString* level = [output.jsonDataDict objectForKey:PARA_LEVEL]; 
                    NSString* exp = [output.jsonDataDict objectForKey:PARA_EXP];
                    if (level) {
                        [self setLevel:level.intValue];
                    }
                    if (exp) {
                        [self setExperience:exp.intValue];
                    }
                    
                }                  
            }
            else if (output.resultCode == ERROR_NETWORK) {
                // TODO, add log here
//                [viewController popupUnhappyMessage:NSLS(@"kSystemFailure") title:nil];
            }
            else if (output.resultCode == ERROR_USERID_NOT_FOUND) {
                // TODO, add log here                
            }
            else {
                // TODO, add log here                
            }
        });
        
    });
}


- (void)syncExpAndLevel:(int)type awardExp:(long)awardExp
{    
    if ([[UserManager defaultManager] hasUser] == NO){
        PPDebug(@"<syncExpAndLevel> but user not found yet.");
        return;
    }
    
    //[viewController showActivityWithText:NSLS(@"kRegisteringUser")];    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = nil;        
        output = [GameNetworkRequest syncExpAndLevel:SERVER_URL 
                                               appId:[ConfigManager appId] 
                                              gameId:[ConfigManager gameId]
                                              userId:[UserManager defaultManager].userId 
                                               level:[self level] 
                                                 exp:[self experience] 
                                                type:type
                                            awardExp:awardExp];
        
        dispatch_async(dispatch_get_main_queue(), ^{
           // [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS) {
                if (type == SYNC) {
                    NSString* level = [output.jsonDataDict objectForKey:PARA_LEVEL]; 
                    NSString* exp = [output.jsonDataDict objectForKey:PARA_EXP];
                    [self setExperience:exp.intValue];
                    [self setLevel:level.intValue];
                }  
                
            }
            else if (output.resultCode == ERROR_NETWORK) {
                // TODO, add log here                
            }
            else if (output.resultCode == ERROR_USERID_NOT_FOUND) {
                // TODO, add log here                                
            }
            else {
                // TODO, add log here                
            }
        });
        
    });
}

- (void)syncExpAndLevel:(int)type
{
    [self syncExpAndLevel:type awardExp:0];
}


@end
