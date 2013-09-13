//
//  GuessManager.h
//  Draw
//
//  Created by 王 小涛 on 13-8-10.
//
//

#import <Foundation/Foundation.h>
#import "Opus.pb.h"

typedef enum{
    GuessStateNotStart,
    GuessStateBeing,
    GuessStateFail,
    GuessStateExpire
}GuessState;

@interface GuessManager : NSObject

+ (int)passCount:(NSArray *)opuses;
//+ (int)guessIndex:(NSArray *)opuses;

+ (BOOL)canAwardNow:(int)passCount mode:(int)mode;
+ (int)awardCoins:(int)passCount mode:(int)mode;
+ (int)predictAwardCoins:(int)passCount mode:(int)mode;
+ (int)countNeedToGuessToAward:(int)count mode:(int)mode;

+ (BOOL)isContestOver:(PBGuessContest *)contest;
+ (BOOL)isContestNotStart:(PBGuessContest *)contest;
+ (BOOL)isContestBeing:(PBGuessContest *)contest;

+ (void)deductCoins:(int)mode
          contestId:(NSString *)contestId
              force:(BOOL)force;

+ (int)getCountHappyModeAwardOnce;
+ (int)getCountGeniusModeAwardOnce;
+ (int)getDeductCoins:(int)mode;

+ (int)getGuessExpireTime:(int)mode;
+ (NSDate *)getLastGuessDate:(int)mode;
+ (void)setLastGuessDateDate:(int)mode;
+ (BOOL)isLastGuessDateExpire:(int)mode;
+ (NSTimeInterval)getTimeIntervalUtilExpire:(int)mode;




+ (NSString *)getTitleWithMode:(int)mode;
+ (NSString *)getRightButtonTitleWithMode:(int)mode;
+ (SEL)getRightButtonSelectorWithMode:(int)mode;
+ (BOOL)isSupportRefreshFooterWithMode:(int)mode;

// 表示当前合法的猜的关卡，仅对天才模式有用，因为天才模式需要一关关闯关，对于其他两种模式，这个值为-1。当这个值为-1时，表示当前合法的猜的关卡是任意的。
+ (int)getGuessIndexWithMode:(int)mode
                   guessList:(NSArray *)guessList;

+ (void)setGuessState:(GuessState)state
                 mode:(int)mode;
+ (GuessState)getGuessStateWithMode:(int)mode;







@end
