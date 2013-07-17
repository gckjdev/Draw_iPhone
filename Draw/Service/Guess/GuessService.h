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

@protocol GusessServiceDelegate <NSObject>

@optional
- (void)didGetOpuses:(NSArray *)opuses resultCode:(int)resultCode;
- (void)didGuessOpus:(PBOpus *)opus resultCode:(int)resultCode;
- (void)didGetGuessRank:(PBGuessRank *)rank resultCode:(int)resultCode;
- (void)didGetGuessRankList:(NSArray *)list resultCode:(int)resultCode;

@end

@interface GuessService : CommonService

@property (assign, nonatomic) id<GusessServiceDelegate> delegate;

+ (GuessService *)defaultService;

- (void)getOpusesWithMode:(PBUserGuessMode)mode
                   offset:(int)offset
                    count:(int)count
               isStartNew:(BOOL)isStartNew;

- (void)guessOpus:(PBOpus *)opus
             mode:(PBUserGuessMode)mode
        contestId:(NSString *)contestId
            words:(NSArray *)words
          correct:(BOOL)correct
        startDate:(NSDate *)startDate
          endDate:(NSDate *)endDate;

- (void)getGuessRankWithMode:(PBUserGuessMode)mode
                   contestId:(NSString *)contestId;

- (void)getGuessRankListWithMode:(PBUserGuessMode)mode
                       contestId:(NSString *)contestId;

@end
