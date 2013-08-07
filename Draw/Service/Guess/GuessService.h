//
//  GuessService.h
//  Draw
//
//  Created by 王 小涛 on 13-7-16.
//
//

#import <Foundation/Foundation.h>
#import "Opus.pb.h"
#import "CommonService.h"

#define HOT_RANK 0
#define ALL_TIME_RANK 1

@protocol GuessServiceDelegate <NSObject>

@optional
- (void)didGetOpuses:(NSArray *)opuses resultCode:(int)resultCode;
- (void)didGuessOpus:(PBOpus *)opus resultCode:(int)resultCode;
- (void)didGetGuessRank:(PBGuessRank *)rank resultCode:(int)resultCode;
- (void)didGetGuessRankList:(NSArray *)list resultCode:(int)resultCode;
- (void)didGetGuessContestList:(NSArray *)list resultCode:(int)resultCode;

@end

@interface GuessService : CommonService

@property (assign, nonatomic) id<GuessServiceDelegate> delegate;

+ (GuessService *)defaultService;
+ (NSString *)contestId:(NSDate *)date;

- (void)getOpusesWithMode:(PBUserGuessMode)mode
                contestId:(NSString *)contestId
                   offset:(int)offset
                    limit:(int)limit
               isStartNew:(BOOL)isStartNew;

- (void)guessOpus:(PBOpus *)opus
             mode:(PBUserGuessMode)mode
        contestId:(NSString *)contestId
            words:(NSArray *)words
          correct:(BOOL)correct
        startDate:(NSDate *)startDate
          endDate:(NSDate *)endDate;


- (void)getGuessRankWithType:(int)type
                        mode:(PBUserGuessMode)mode
                   contestId:(NSString *)contestId;

- (void)getGuessRankListWithType:(int)type
                            mode:(PBUserGuessMode)mode
                       contestId:(NSString *)contestId
                          offset:(int)offset
                           limit:(int)limit;



// Get today contest list
- (void)getGuessContestList;

// Get recent contest list
- (void)getRecentGuessContestList;

@end
