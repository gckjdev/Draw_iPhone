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

typedef void (^GetRankListCompletedBlock)(int resultCode, int totalCount, NSArray *list);

@protocol GuessServiceDelegate <NSObject>

@optional
- (void)didGetOpuses:(NSArray *)opuses resultCode:(int)resultCode isStartNew:(BOOL)isStartNew;
- (void)didGuessOpus:(PBOpus *)opus resultCode:(int)resultCode;
- (void)didGetGuessRank:(PBGuessRank *)rank resultCode:(int)resultCode;

- (void)didGetGuessRankList:(NSArray *)list
                 totalCount:(int)totalCount
                       mode:(int)mode
                 resultCode:(int)resultCode;

- (void)didGetGuessContestList:(NSArray *)list resultCode:(int)resultCode;
- (void)didGetGuessContest:(PBGuessContest *)contest resultCode:(int)resultCode;


@end

@interface GuessService : CommonService


+ (GuessService *)defaultService;

- (void)getOpusesWithMode:(PBUserGuessMode)mode
                contestId:(NSString *)contestId
                   offset:(int)offset
                    limit:(int)limit
               isStartNew:(BOOL)isStartNew
                 delegate:(id<GuessServiceDelegate>)delegate;

- (void)guessOpus:(PBOpus *)opus
             mode:(PBUserGuessMode)mode
        contestId:(NSString *)contestId
            words:(NSArray *)words
          correct:(BOOL)correct
        startDate:(NSDate *)startDate
          endDate:(NSDate *)endDate
         delegate:(id<GuessServiceDelegate>)delegate;


- (void)getGuessRankWithType:(int)type
                        mode:(PBUserGuessMode)mode
                   contestId:(NSString *)contestId
                    delegate:(id<GuessServiceDelegate>)delegate;


//- (void)getGuessRankListWithType:(int)type
//                            mode:(PBUserGuessMode)mode
//                       contestId:(NSString *)contestId
//                          offset:(int)offset
//                           limit:(int)limit
//                        delegate:(id<GuessServiceDelegate>)delegate;



- (void)getGuessRankListWithType:(int)type
                            mode:(PBUserGuessMode)mode
                       contestId:(NSString *)contestId
                          offset:(int)offset
                           limit:(int)limit
                       completed:(GetRankListCompletedBlock)completed;



// Get today contest info
- (void)getTodayGuessContestInfoWithDelegate:(id<GuessServiceDelegate>)delegate;


// Get recent contest list
- (void)getRecentGuessContestListWithDelegate:(id<GuessServiceDelegate>)delegate;

+ (NSString*)geniusTitle:(int)correctCount;

@end
