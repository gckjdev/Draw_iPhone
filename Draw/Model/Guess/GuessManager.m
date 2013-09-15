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
#import "UserManager.h"

#define NUM_COUNT_AWARD_ONCE 10
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

+ (int)guessIndexInGeniusMode:(NSArray *)opuses{

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
            award = (passCount - NUM_COUNT_AWARD_ONCE) / NUM_COUNT_AWARD_ONCE * [ConfigManager getDeltaAwardInGeniusMode] + [ConfigManager getAwardInGeniusMode];
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
#define DEDUCT_COINS_IN_GENIUS_MODE 20
#define DEDUCT_COINS_IN_CONTEST_MODE 100

+ (int)getDeductCoins:(int)mode{
    
    if (mode == PBUserGuessModeGuessModeHappy) {
        return [ConfigManager getDeductCoinsInHappyMode];
    }else if(mode == PBUserGuessModeGuessModeGenius){
        return [ConfigManager getDeductCoinsInGeniusMode];
    }else{
        return [ConfigManager getDeductCoinsInContestMode];
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
    if ([contestId length] == 0) {
        return YES;
    }
    if (mode == PBUserGuessModeGuessModeContest) {
        
        BOOL deduct = [[[UserManager defaultManager] userDefaults] boolForKey:contestId];
        
        return deduct;
    }else if(mode == PBUserGuessModeGuessModeHappy){
        
        BOOL deduct = [[[UserManager defaultManager] userDefaults] boolForKey:KEY_GUESS_HAPPY_DEDUCT_COINS];
        
        return deduct;
    }else{
        
        BOOL deduct = [[[UserManager defaultManager] userDefaults] boolForKey:KEY_GUESS_GENIUS_DEDUCT_COINS];
        
        return deduct;
    }
    
}

+ (void)setHadAlreadDeduct:(int)mode
                 contestId:(NSString *)contestId{
    
    if (mode == PBUserGuessModeGuessModeContest) {
        
        [[[UserManager defaultManager] userDefaults] setBool:YES forKey:contestId];
        
    }else if(mode == PBUserGuessModeGuessModeHappy){
        
        [[[UserManager defaultManager] userDefaults] setBool:YES forKey:KEY_GUESS_HAPPY_DEDUCT_COINS];

    }else{
        
        [[[UserManager defaultManager] userDefaults] setBool:YES forKey:KEY_GUESS_GENIUS_DEDUCT_COINS];
    }
    
    [[[UserManager defaultManager] userDefaults] synchronize];
}

+ (void)deductCoins:(int)mode
          contestId:(NSString *)contestId{
        
    [[AccountService defaultService] deductCoin:[self getDeductCoins:mode] source:[self getBalanceSourceType:mode]];
}

+ (int)getCountHappyModeAwardOnce{
    
    return NUM_COUNT_AWARD_ONCE;
}

+ (int)getCountGeniusModeAwardOnce{
    
    return NUM_COUNT_AWARD_ONCE;
}

#define KEY_LAST_HAPPY_GUESS_DATE @"KEY_LAST_HAPPY_GUESS_DATE"
#define KEY_LAST_GENIUS_GUESS_DATE @"KEY_LAST_GENIUS_GUESS_DATE"

+ (NSString *)getGuessDateKey:(int)mode{
    
    NSString *key = @"";
    
    if (mode == PBUserGuessModeGuessModeHappy) {
        key = KEY_LAST_HAPPY_GUESS_DATE;
    }
    if (mode == PBUserGuessModeGuessModeGenius) {
        key = KEY_LAST_GENIUS_GUESS_DATE;
    }
    
    return key;
}

+ (int)getGuessExpireTime:(int)mode{
    
    if (mode == PBUserGuessModeGuessModeHappy) {
        return [ConfigManager getHappyGuessExpireTime];
    }else if(mode == PBUserGuessModeGuessModeGenius){
        return [ConfigManager getGeniusGuessExpireTime];
    }else{
        return INT32_MAX;
    }
}

+ (NSDate *)getLastGuessDate:(int)mode{
    NSString *key = [self getGuessDateKey:mode];
    NSDate *date = [[[UserManager defaultManager] userDefaults] objectForKey:key];
    return date;
}

+ (void)setLastGuessDateDate:(int)mode{
    
    NSString *key = [self getGuessDateKey:mode];
    
    [[[UserManager defaultManager] userDefaults] setObject:[NSDate date] forKey:key];
    [[[UserManager defaultManager] userDefaults] synchronize];
}

+ (NSTimeInterval)getTimeIntervalUtilExpire:(int)mode contest:(PBGuessContest *)contest{
    
    NSTimeInterval interval = 0;

    if (mode == PBUserGuessModeGuessModeContest) {

        interval = [[NSDate dateWithTimeIntervalSince1970:contest.endTime] timeIntervalSinceNow];
        return interval;
    }
    
    NSString *key = [self getGuessDateKey:mode];
    NSDate *date = [[[UserManager defaultManager] userDefaults] objectForKey:key];
    
    if (date != nil){
        interval = [[NSDate date] timeIntervalSinceDate:date];
    }
    
    NSTimeInterval left = [self getGuessExpireTime:mode] * 3600 - interval;

    return left;
}

+ (BOOL)isLastGuessDateExpire:(int)mode{
    
    NSString *key = [self getGuessDateKey:mode];
    
    NSDate *date = [[[UserManager defaultManager] userDefaults] objectForKey:key];
    
    if (date == nil) {
        return NO;
    }
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
    if (interval > [self getGuessExpireTime:mode] * 3600) {
        return YES;
    }else{
        return NO;
    }
}


+ (NSString *)getTitleWithMode:(int)mode{
    
    switch (mode) {
        case PBUserGuessModeGuessModeHappy:
            return NSLS(@"kHappGuessMode");
            break;
            
        case PBUserGuessModeGuessModeGenius:
            return NSLS(@"kGeniusGuessMode");
            break;
            
        case PBUserGuessModeGuessModeContest:
            return NSLS(@"kContestGuessMode");
            break;
            
        default:
            return @"";
            break;
    }
}

+ (NSString *)getRightButtonTitleWithMode:(int)mode{
    
    switch (mode) {
        case PBUserGuessModeGuessModeHappy:
            return NSLS(@"kRestart");
            break;
            
        case PBUserGuessModeGuessModeGenius:
            return NSLS(@"kRestart");
            break;
            
        case PBUserGuessModeGuessModeContest:
            return NSLS(@"kRanking");
            break;
            
        default:
            return @"";
            break;
    }
}

+ (SEL)getRightButtonSelectorWithMode:(int)mode{
    
    switch (mode) {
        case PBUserGuessModeGuessModeHappy:
            return @selector(clickRestartButton:);
            break;
            
        case PBUserGuessModeGuessModeGenius:
            return @selector(clickRestartButton:);
            break;
            
        case PBUserGuessModeGuessModeContest:
            return @selector(clickRankingButton:);
            break;
            
        default:
            return nil;
            break;
    }
}

+ (BOOL)isSupportRefreshFooterWithMode:(int)mode{
    
    if (mode == PBUserGuessModeGuessModeGenius) {
        return YES;
    }
    
    return NO;
}

// 表示当前合法的猜的关卡，仅对天才模式有用，因为天才模式需要一关关闯关，对于其他两种模式，这个值为-1。当这个值为-1时，表示当前合法的猜的关卡是任意的。
+ (int)getGuessIndexWithMode:(int)mode
                   guessList:(NSArray *)guessList{
    
    switch (mode) {
        case PBUserGuessModeGuessModeGenius:
            return [self guessIndexInGeniusMode:guessList];
            break;
            
        default:
            return -1;
            break;
    }
}

+ (NSString *)getGuessStateKeyWithMode:(int)mode
                             contestId:(NSString *)contestId{
    
    switch (mode) {
        case PBUserGuessModeGuessModeHappy:
            return @"KEY_HAPPY_GUESS_STATE";
            break;
            
        case PBUserGuessModeGuessModeGenius:
            return @"KEY_GENIUS_GUESS_STATE";
            break;
            
        default:
            return [[@"KEY_CONTEST_GUESS_STATE_" stringByAppendingString:contestId] uppercaseString];
            break;
    }
}

+ (void)setGuessState:(GuessState)state
                 mode:(int)mode
            contestId:(NSString *)contestId{
    
    NSString *key = [self getGuessStateKeyWithMode:mode contestId:contestId];
    
    if (mode == PBUserGuessModeGuessModeContest &&
        (state == GuessStateBeing || state == GuessStateExpire)) {
        
        [[[UserManager defaultManager] userDefaults] setInteger:state forKey:key];
    }
    
    if (mode == PBUserGuessModeGuessModeHappy && (state == GuessStateNotStart || state == GuessStateBeing || state == GuessStateExpire)
        ) {
        
        [[[UserManager defaultManager] userDefaults] setInteger:state forKey:key];
    }
    
    if (mode == PBUserGuessModeGuessModeHappy && (state == GuessStateNotStart || state == GuessStateBeing || state == GuessStateExpire || state == GuessStateFail)
        ) {
        [[[UserManager defaultManager] userDefaults] setInteger:state forKey:key];

    }
}

+ (GuessState)getGuessStateWithMode:(int)mode contestId:(NSString *)contestId{
    
    if (mode == PBUserGuessModeGuessModeContest) {
        return GuessStateBeing;
    }
    
    NSString *key = [self getGuessStateKeyWithMode:mode contestId:contestId];
    NSInteger state = [[[UserManager defaultManager] userDefaults] integerForKey:key];
    
    return state;
}

+ (NSString *)getGuessRulesWithModex:(int)mode{
    
    switch (mode) {
        case PBUserGuessModeGuessModeHappy:
            return  [self getGuessRulesWithHappyMode];
            break;
            
        case PBUserGuessModeGuessModeGenius:
            return  [self getGuessRulesWithGeniusMode];
            break;
            
        case PBUserGuessModeGuessModeContest:
            return  [self getGuessRulesWithContestMode];
            break;
            
        default:
            break;
    }
    
    return nil;
}

+ (NSString *)getGuessRulesWithHappyMode{
    
    NSString *message = [NSString stringWithFormat:NSLS(@"kHappyGuessRulesDetil"),
                         [GuessManager getDeductCoins:PBUserGuessModeGuessModeHappy],
                         [GuessManager awardCoins:[GuessManager getCountHappyModeAwardOnce] mode:PBUserGuessModeGuessModeHappy],
                         [GuessManager getCountHappyModeAwardOnce],
                         [GuessManager getGuessExpireTime:PBUserGuessModeGuessModeHappy]];

    return message;
}

+ (NSString *)getGuessRulesWithGeniusMode{
    
    NSString *message = [NSString stringWithFormat:NSLS(@"kGeniusGuessRulesDetil"),
               [GuessManager getDeductCoins:PBUserGuessModeGuessModeGenius],
               [GuessManager getCountGeniusModeAwardOnce],
               [GuessManager awardCoins:[GuessManager getCountHappyModeAwardOnce] mode:PBUserGuessModeGuessModeGenius],

               [GuessManager getCountGeniusModeAwardOnce] * 2,
               [GuessManager awardCoins:[GuessManager getCountHappyModeAwardOnce] * 2 mode:PBUserGuessModeGuessModeGenius],

               [GuessManager getCountGeniusModeAwardOnce] * 3,
               [GuessManager awardCoins:[GuessManager getCountHappyModeAwardOnce] * 3 mode:PBUserGuessModeGuessModeGenius],

               [GuessManager getGuessExpireTime:PBUserGuessModeGuessModeGenius]];
    
    return message;
}

+ (NSString *)getGuessRulesWithContestMode{
    
    NSString *message = [NSString stringWithFormat:NSLS(@"kContestGuessRulesDetil"),
               [GuessManager getDeductCoins:PBUserGuessModeGuessModeContest]];
    
    return message;
}

+ (NSString *)getGuessRulesTitleWithModex:(int)mode{
    
    switch (mode) {
        case PBUserGuessModeGuessModeHappy:
            return  [self getGuessRulesTitleWithHappyMode];
            break;
            
        case PBUserGuessModeGuessModeGenius:
            return  [self getGuessRulesTitleWithGeniusMode];
            break;
            
        case PBUserGuessModeGuessModeContest:
            return  [self getGuessRulesTitleWithContestMode];
            break;
            
        default:
            break;
    }
    
    return nil;
}

+ (NSString *)getGuessRulesTitleWithHappyMode{
    
    return NSLS(@"kHappyGuessRules");
}

+ (NSString *)getGuessRulesTitleWithGeniusMode{
    
    return NSLS(@"kGeniusGuessRules");
}

+ (NSString *)getGuessRulesTitleWithContestMode{
    
    return NSLS(@"kContestGuessRules");
}

+ (NSString *)getExpireTitleWithMode:(int)mode{
    
    switch (mode) {
        case PBUserGuessModeGuessModeHappy:
            return NSLS(@"kHappyModeExpireTitle");
            break;
            
        case PBUserGuessModeGuessModeGenius:
            return NSLS(@"kGeniusModeExpireTitle");
            break;
            
        case PBUserGuessModeGuessModeContest:
            return NSLS(@"kContestModeExpireTitle");
            break;
            
        default:
            break;
    }
    
    return nil;
}

//+ (NSString *)getExpireMessageWithMode:(int)mode{
//    
//    switch (mode) {
//        case PBUserGuessModeGuessModeHappy:
//            return [NSString stringWithFormat:NSLS(@"kHappyModeExpireMessage"), [GuessManager getDeductCoins:mode]] ;
//            break;
//            
//        case PBUserGuessModeGuessModeGenius:
//            return [NSString stringWithFormat:NSLS(@"kGeniusModeExpireMessage"), [GuessManager getDeductCoins:mode]] ;
//            break;
//            
//        case PBUserGuessModeGuessModeContest:
//            return [NSString stringWithFormat:NSLS(@"kContestModeExpireMessage"), [GuessManager getDeductCoins:mode]] ;
//            break;
//            
//        default:
//            break;
//    }
//}

+ (NSString *)getExpireMessageWithMode:(int)mode{
    
    switch (mode) {
        case PBUserGuessModeGuessModeHappy:
            return NSLS(@"kHappyModeExpireMessage");
            break;
            
        case PBUserGuessModeGuessModeGenius:
            return NSLS(@"kGeniusModeExpireMessage");
            break;
            
        case PBUserGuessModeGuessModeContest:
            return NSLS(@"kContestModeExpireMessage");
            break;
            
        default:
            break;
    }
    
    return nil;
}

+ (NSString *)getDeductCoinsPopMessageWithMode:(int)mode{
    
    switch (mode) {
        case PBUserGuessModeGuessModeHappy:
            return [NSString stringWithFormat:NSLS(@"kHappyModeDeductConisMessage"), [self getDeductCoins:mode]];
            break;
            
        case PBUserGuessModeGuessModeGenius:
            return [NSString stringWithFormat:NSLS(@"kGeniusModeDeductConisMessage"), [self getDeductCoins:mode]];
            break;
            
        case PBUserGuessModeGuessModeContest:
            return [NSString stringWithFormat:NSLS(@"kContestModeDeductConisMessage"), [self getDeductCoins:mode]];
            break;
            
        default:
            break;
    }
    
    return nil;
}





@end
