//
//  GuessManager.h
//  Draw
//
//  Created by 王 小涛 on 13-8-10.
//
//

#import <Foundation/Foundation.h>
#import "Opus.pb.h"

@interface GuessManager : NSObject

+ (int)passCount:(NSArray *)opuses;
+ (int)guessIndex:(NSArray *)opuses;

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

@end
