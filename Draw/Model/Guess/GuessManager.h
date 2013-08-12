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
    
@end
