//
//  GuessManager.m
//  Draw
//
//  Created by 王 小涛 on 13-8-10.
//
//

#import "GuessManager.h"
#import "ConfigManager.h"
#import "AccountService.h"

#define NUM_COUNT_AWARD_ONCE 10
#define DELTA_AWARD_COIN 100
#define CONTEST_COUNT 20

@implementation GuessManager

- (void)dealloc{
    
    [super dealloc];
}


+ (int)passCount:(NSArray *)opuses{

    int count = 0;
    for (int index = 0; index < [opuses count]; index++) {
        PBOpus *pbOpus = [opuses objectAtIndex:index];
        if (pbOpus.guessInfo.isCorrect) {
            count++;
        }
    }
    return count;
}

+ (int)guessIndex:(NSArray *)opuses{

    int index = 0;
    for (; index < [opuses count]; index ++) {
        PBOpus *pbOpus = [opuses objectAtIndex:index];
        if (pbOpus.guessInfo.isCorrect) {
            continue;
        }else{
            break;
        }
    }
    return index;
}

+ (BOOL)canAwardNow:(int)passCount mode:(int)mode{

    if (mode == PBUserGuessModeGuessModeHappy
        || mode == PBUserGuessModeGuessModeGenius) {
        
        if (passCount == 0) {
            return NO;
        }else if ((passCount % NUM_COUNT_AWARD_ONCE) == 0){
            return YES;
        }else{
            return NO;
        }
    }
    
    return NO;
}

+ (int)awardCoins:(int)passCount mode:(int)mode{

    int award = 0;
    
    switch (mode) {
        case PBUserGuessModeGuessModeHappy:
            award = [ConfigManager getAwardInHappyMode];
            break;
            
        case PBUserGuessModeGuessModeGenius:
            award = (passCount - NUM_COUNT_AWARD_ONCE) / NUM_COUNT_AWARD_ONCE * DELTA_AWARD_COIN + 1000;
            break;
            
        default:
            break;
    }
    
    return award;
}

+ (int)predictAwardCoins:(int)passCount mode:(int)mode{
    
    int count = 0;
    if (passCount % NUM_COUNT_AWARD_ONCE == 0) {
        count = passCount;
    }else{
        count = passCount / NUM_COUNT_AWARD_ONCE * NUM_COUNT_AWARD_ONCE + NUM_COUNT_AWARD_ONCE;
    }
    
    return [self awardCoins:count mode:mode];
}

+ (int)countNeedToGuessToAward:(int)count mode:(int)mode{
    
    switch (mode) {
        case PBUserGuessModeGuessModeHappy:
        case PBUserGuessModeGuessModeGenius:
            
            return NUM_COUNT_AWARD_ONCE - count % NUM_COUNT_AWARD_ONCE;
            break;
            
        case PBUserGuessModeGuessModeContest:
            return CONTEST_COUNT - count;
            break;
            
        default:
            return 99999999;
            break;
    }
}

+ (BOOL)isContestOver:(PBGuessContest *)contest{

    int time = [[NSDate date] timeIntervalSince1970];
    if (time > contest.endTime){
        return YES;
    }
    return NO;
}

+ (BOOL)isContestNotStart:(PBGuessContest *)contest{
    
    int time = [[NSDate date] timeIntervalSince1970];
    if (time < contest.startTime) {
        return YES;
    }
    return NO;
}

+ (BOOL)isContestBeing:(PBGuessContest *)contest{
    
    int time = [[NSDate date] timeIntervalSince1970];
    if (time >= contest.startTime && time <= contest.endTime) {
        return YES;
    }
    return NO;
}

#define KEY_GUESS_HAPPY_DEDUCT_COINS @"KEY_GUESS_HAPPY_DEDUCT_COINS"
#define KEY_GUESS_GENIUS_DEDUCT_COINS @"KEY_GUESS_GENIUS_DEDUCT_COINS"

#define DEDUCT_COINS_IN_HAPPY_MODE 20
#define DEDUCT_COINS_IN_GENIUS_MODE 100
#define DEDUCT_COINS_IN_CONTEST_MODE 100

+ (int)getDeductCoins:(int)mode{
    
    if (mode == PBUserGuessModeGuessModeHappy) {
        return DEDUCT_COINS_IN_HAPPY_MODE;
    }else if(mode == PBUserGuessModeGuessModeGenius){
        return DEDUCT_COINS_IN_GENIUS_MODE;
    }else{
        return DEDUCT_COINS_IN_CONTEST_MODE;
    }
}

+ (BalanceSourceType)getBalanceSourceType:(int)mode{
    
    if (mode == PBUserGuessModeGuessModeHappy) {
        return DeductInHappyGuessMode;
    }else if(mode == PBUserGuessModeGuessModeGenius){
        return DeductInGeniusGuessMode;
    }else{
        return DeductInContestGuessMode;
    }
}

+ (BOOL)hadAlreadDeduct:(int)mode
              contestId:(NSString *)contestId
{
    if (mode == PBUserGuessModeGuessModeContest) {
        
        BOOL deduct = [[NSUserDefaults standardUserDefaults] boolForKey:contestId];
        
        return deduct;
    }else if(mode == PBUserGuessModeGuessModeHappy){
        
        BOOL deduct = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_GUESS_HAPPY_DEDUCT_COINS];
        
        return deduct;
    }else{
        
        BOOL deduct = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_GUESS_GENIUS_DEDUCT_COINS];
        
        return deduct;
    }
    
}

+ (void)setHadAlreadDeduct:(int)mode
                 contestId:(NSString *)contestId{
    
    if (mode == PBUserGuessModeGuessModeContest) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:contestId];
        
    }else if(mode == PBUserGuessModeGuessModeHappy){
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_GUESS_HAPPY_DEDUCT_COINS];

    }else{
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_GUESS_GENIUS_DEDUCT_COINS];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)deductCoins:(int)mode
          contestId:(NSString *)contestId
              force:(BOOL)force{
    
    if (force) {
        
        [[AccountService defaultService] deductCoin:[self getDeductCoins:mode] source:[self getBalanceSourceType:mode]];
        [self setHadAlreadDeduct:mode contestId:contestId];
        return;
    }
    
    if (![self hadAlreadDeduct:mode contestId:contestId]) {
        
        [[AccountService defaultService] deductCoin:[self getDeductCoins:mode] source:[self getBalanceSourceType:mode]];
        [self setHadAlreadDeduct:mode contestId:contestId];
    }
}

@end
