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
#import "AccountService.h"
#import "ItemType.h"
#import "CommonMessageCenter.h"
#import "UserGameItemService.h"
#import "GameMessage.pb.h"

#define KEY_LEVEL           @"USER_KEY_LEVEL"
#define KEY_EXP             @"USER_KEY_EXPERIENCE"
#define KEY_LEVEL_DIC       @"USER_KEY_LEVEL_DIC"
#define KEY_EXP_DIC         @"USER_KEY_EXP_DIC"

#define MAX_LEVEL           99
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
    double exp = 0;
    //int baseExp = self.level1Exp.text.intValue;
    double lastLevelUpExp = 0.0;
    
    for (int i = 0; i <= MAX_LEVEL; i++) {
        if (i <= 5) {            
            lastLevelUpExp = FIRST_LEVEL_EXP*i;
            exp = exp+lastLevelUpExp;
        } else if (i > 90) {
            lastLevelUpExp = lastLevelUpExp*2;
            exp = exp+lastLevelUpExp;
        } else {
            lastLevelUpExp = lastLevelUpExp*EXP_INC_RATE;
            exp = exp+lastLevelUpExp;
        }
//        PPDebug(@"current level--%d, level up need %f day，totally has play %f day", i, lastLevelUpExp/(LIAR_DICE_EXP*2*120.0), exp/(LIAR_DICE_EXP*2*120.0));
        [self.levelMap addObject:[NSNumber numberWithLong:exp]];
        
    }
}

- (NSString*)upgradeMessage:(int)newLevel
{
    return [GameApp upgradeMessage:newLevel];
}

- (NSString*)degradeMessage:(int)newLevel
{
    return [GameApp degradeMessage:newLevel];
}

- (int)level
{
    return [[UserManager defaultManager] level];
    
//    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
//    NSNumber* value = [userDefaults objectForKey:KEY_LEVEL];
//    if (value) {
//        return value.intValue;
//    }
//    return 1;
}

- (long)experience
{
    return [[UserManager defaultManager] experience];
    
//    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
//    NSNumber* value = [userDefaults objectForKey:KEY_EXP];
//    if (value) {
//        return value.longValue;
//    }
//    return 0;
}

- (void)setLevel:(NSInteger)level
{
    if (level <= 0)
        return;
    
    PPDebug(@"<setLevel> level=%d", level);
//    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:[NSNumber numberWithLong:level] forKey:KEY_LEVEL];    
//    [userDefaults synchronize];
    
//    PPDebug(@"<setExperience> experience=%ld", experience);
    [[UserManager defaultManager] setLevel:level];
    
}
- (void)setExperience:(long)experience
{
    if (experience < 0)
        return;
    
    PPDebug(@"<setExperience> experience=%ld", experience);
    [[UserManager defaultManager] setExperience:experience];

    /*
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithLong:experience] forKey:KEY_EXP];    
    [userDefaults synchronize];
    */
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

- (void)awardForLevelUp
{
    [[UserGameItemService defaultService] awardItem:ItemTypeFlower count:[ConfigManager flowerAwardFordLevelUp] handler:NULL];
}

// new user level and exp implementation
- (void)incExpToServer:(long)addExp
{
    if ([[UserManager defaultManager] hasUser] == NO){
        PPDebug(@"<incExpToServer> but user not found yet.");
        return;
    }
    
    //[viewController showActivityWithText:NSLS(@"kRegisteringUser")];
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = nil;
        output = [GameNetworkRequest increaseExp:SERVER_URL
                                           appId:[ConfigManager appId]
                                          gameId:[ConfigManager gameId]
                                          userId:[UserManager defaultManager].userId
                                             exp:addExp];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            PPDebug(@"<incExpToServer> add exp(%ld) resultCode(%d)", addExp, output.resultCode);
            if (output.resultCode == ERROR_SUCCESS && output.responseData != nil) {
                
                @try {
                    // update level and exp from server
                    DataQueryResponse *res = [DataQueryResponse parseFromData:output.responseData];
                    PBGameUser *user = res.user;
                    
                    if (user != nil && [user hasLevel] && [user hasExperience]){
                        [self setLevel:user.level];
                        [self setExperience:user.experience];
                    }

                }
                @catch (NSException *exception) {
                    PPDebug(@"<incExpToServer> catch exception=%@", [exception description]);
                }
                @finally {
                    
                }
                
            }
        });
        
    });
    
}


- (void)addExp:(long)exp 
      delegate:(id<LevelServiceDelegate>)delegate
{
//    exp = 100;
    
    long currentExp = [self experience] + exp ;
    int newLevel = [self getLevelByExp:(currentExp)];
    [self setExperience:(currentExp)];
    if ([self level] != newLevel) {
        [self setLevel:newLevel];
        [self awardForLevelUp];
        if (delegate && [delegate respondsToSelector:@selector(levelUp:)]) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:[self upgradeMessage:newLevel] delayTime:1.5 isHappy:YES];
            [delegate levelUp:newLevel];
        }
    }
    
    [self incExpToServer:exp];
    
//    [self syncExpAndLevel:UPDATE];
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
                [[CommonMessageCenter defaultCenter] postMessageWithText:[self upgradeMessage:newLevel] delayTime:1.5 isHappy:YES];
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
                [[CommonMessageCenter defaultCenter] postMessageWithText:[self degradeMessage:newLevel] delayTime:2 isHappy:NO];
                [delegate levelDown:newLevel];
            }
        }        
    }
    
    [self incExpToServer:awardExp];
    
//    
//    [self syncExpAndLevel:AWARD awardExp:awardExp];
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
            [[CommonMessageCenter defaultCenter] postMessageWithText:[self degradeMessage:newLevel] delayTime:2 isHappy:NO];
            [delegate levelDown:newLevel];
        }
    }
    
    [self incExpToServer:exp];
    
//    [self syncExpAndLevel:UPDATE];
}

- (long)expRequiredForNextLevel
{
    int level = [self level];
    NSNumber* num = (NSNumber*)[self.levelMap objectAtIndex:level];
    return num.longValue;
}

- (long)getExpByLevel:(int)level
{
    NSNumber* val = [self.levelMap objectAtIndex:(level)];
    return val.longValue;
}


/*
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
*/

/*
- (int)levelForSource:(LevelSource)source
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* levelDic = [userDefaults objectForKey:KEY_LEVEL_DIC];
    if (levelDic) {
        return ((NSNumber*)[levelDic objectForKey:[self getGameIdBySource:source]]).intValue;
    }
    return 1;
}
- (long)experienceForSource:(LevelSource)source
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* levelDic = [userDefaults objectForKey:KEY_EXP_DIC];
    if (levelDic) {
        return ((NSNumber*)[levelDic objectForKey:[self getGameIdBySource:source]]).longValue;
    }
    return 0;
}

- (void)setLevel:(NSInteger)level
       forSource:(LevelSource)source
{
    if (level <= 0)
        return;
    
    PPDebug(@"<setLevel> level=%d", level);
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* levelDic = (NSMutableDictionary*)[[userDefaults objectForKey:KEY_LEVEL_DIC] mutableCopy];
    if (!levelDic) {
        levelDic = [[NSMutableDictionary alloc] initWithCapacity:LevelSourceCount];
    }
    [levelDic setObject:[NSNumber numberWithInt:level] forKey:[self getGameIdBySource:source]];
    [userDefaults setObject:levelDic forKey:KEY_LEVEL_DIC];
    [userDefaults synchronize];
    [levelDic release];
}
- (void)setExperience:(long)experience
            forSource:(LevelSource)source
{
    if (experience < 0)
        return;
    
    PPDebug(@"<setExperience> experience=%ld", experience);
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* expDic = (NSMutableDictionary*)[[userDefaults objectForKey:KEY_EXP_DIC] mutableCopy];
    if (!expDic) {
        expDic = [[NSMutableDictionary alloc] initWithCapacity:LevelSourceCount];
    }
    [expDic setObject:[NSNumber numberWithLong:experience] forKey:[self getGameIdBySource:source]];
    [userDefaults setObject:expDic forKey:KEY_EXP_DIC];
    [userDefaults synchronize];
    [expDic release];
}

- (void)addExp:(long)exp
      delegate:(id<LevelServiceDelegate>)delegate
     forSource:(LevelSource)source
{
    long currentExp = [self experienceForSource:source] + exp ;
    int newLevel = [self getLevelByExp:(currentExp)];
    [self setExperience:(currentExp) forSource:source];
    if ([self levelForSource:source] != newLevel) {
        [self setLevel:newLevel forSource:source];
        [self awardForLevelUp];
        if (delegate && [delegate respondsToSelector:@selector(levelUp:)]) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:[self upgradeMessage:newLevel] delayTime:1.5 isHappy:YES];
            [delegate levelUp:newLevel];
        }
    }
    [self syncExpAndLevel:UPDATE forSource:source];
}

- (void)minusExp:(long)exp
        delegate:(id<LevelServiceDelegate>)delegate
       forSource:(LevelSource)source
{
    long currentExp = [self experienceForSource:source] - abs(exp) ;
    int newLevel = [self getLevelByExp:(currentExp)];
    [self setExperience:(currentExp) forSource:source];
    if ([self levelForSource:source] != newLevel) {
        [self setLevel:newLevel forSource:source];
//        [self awardForLevelUp];
        if (delegate && [delegate respondsToSelector:@selector(levelDown:)]) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:[self upgradeMessage:newLevel] delayTime:1.5 isHappy:YES];
            [delegate levelDown:newLevel];
        }
    }
    [self syncExpAndLevel:UPDATE forSource:source];
}

- (void)awardExp:(long)exp
        delegate:(id<LevelServiceDelegate>)delegate
       forSource:(LevelSource)source
{
    
}

- (void)syncExpAndLevel:(int)type
              forSource:(LevelSource)source
{
    [self syncExpAndLevel:type awardExp:0 forSource:source];
}
- (void)syncExpAndLevel:(int)type awardExp:(long)awardExp
              forSource:(LevelSource)source
{
    if ([[UserManager defaultManager] hasUser] == NO){
        PPDebug(@"<syncExpAndLevel> but user not found yet.");
        return;
    }
    
    //[viewController showActivityWithText:NSLS(@"kRegisteringUser")];
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = nil;
        output = [GameNetworkRequest syncExpAndLevel:SERVER_URL
                                               appId:@"555555555"
                                              gameId:[self getGameIdBySource:source]
                                              userId:[UserManager defaultManager].userId
                                               level:[self levelForSource:source]
                                                 exp:[self experienceForSource:source]
                                                type:type
                                            awardExp:awardExp];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS) {
                if (type == SYNC) {
                    NSString* level = [output.jsonDataDict objectForKey:PARA_LEVEL];
                    NSString* exp = [output.jsonDataDict objectForKey:PARA_EXP];
                    [self setExperience:exp.intValue forSource:source];
                    [self setLevel:level.intValue forSource:source];
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

 - (NSString*)stringByInteger:(NSInteger)integer
 {
 return [NSString stringWithFormat:@"%d",integer];
 }

- (NSString*)getGameIdBySource:(LevelSource)source
{
    switch (source) {
            case LevelSourceDraw:
                return DRAW_GAME_ID;
            case LevelSourceDice:
                return DICE_GAME_ID;
            case LevelSourceZhajinhua:
                return ZHAJINHUA_GAME_ID;
            default:
                break;
    }
    return nil;
}
*/
 
@end
