//
//  GuessManager.m
//  Draw
//
//  Created by 王 小涛 on 13-8-10.
//
//

#import "GuessManager.h"
#import "SynthesizeSingleton.h"
#import "Opus.pb.h"
#import "ConfigManager.h"

#define NUM_COUNT_AWARD_ONCE 10
#define DELTA_AWARD_COIN 500
#define CONTEST_COUNT 20

@implementation GuessManager

SYNTHESIZE_SINGLETON_FOR_CLASS(GuessManager);

- (void)dealloc{
    
    [super dealloc];
}


- (int)passCount:(NSArray *)opuses{

    int count = 0;
    for (int index = 0; index < [opuses count]; index++) {
        PBOpus *pbOpus = [opuses objectAtIndex:index];
        if (pbOpus.guessInfo.isCorrect) {
            count++;
        }
    }
    return count;
}

- (int)guessIndex:(NSArray *)opuses{

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

- (BOOL)canAwardNow:(int)passCount mode:(int)mode{

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

- (int)awardCoins:(int)passCount mode:(int)mode{

    int award = 0;
    
    switch (mode) {
        case PBUserGuessModeGuessModeHappy:
            award = [ConfigManager getAwardInHappyMode];
            break;
            
        case PBUserGuessModeGuessModeGenius:
            award = (passCount - NUM_COUNT_AWARD_ONCE) / NUM_COUNT_AWARD_ONCE * DELTA_AWARD_COIN + [ConfigManager getAwardInHappyMode];
            break;
            
        default:
            break;
    }
    
    return award;
}

- (int)predictAwardCoins:(int)passCount mode:(int)mode{
    
    int count = 0;
    if (passCount % NUM_COUNT_AWARD_ONCE == 0) {
        count = passCount;
    }else{
        count = passCount / NUM_COUNT_AWARD_ONCE * NUM_COUNT_AWARD_ONCE + NUM_COUNT_AWARD_ONCE;
    }
    
    return [self awardCoins:count mode:mode];
}

- (int)countNeedToGuessToAward:(int)count mode:(int)mode{
    
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


@end
