//
//  GuessService.m
//  Draw
//
//  Created by 王 小涛 on 13-7-16.
//
//

#import "GuessService.h"
#import "PPGameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "UserManager.h"
#import "ConfigManager.h"
#import "SynthesizeSingleton.h"

#define SAFE_STRING(x) ((x == nil) ? @"" : (x))
#define WORD_SPLIT_STRING  @":"

@implementation GuessService

SYNTHESIZE_SINGLETON_FOR_CLASS(GuessService);

- (void)getOpusesWithMode:(PBUserGuessMode)mode
                contestId:(NSString *)contestId
                   offset:(int)offset
                    limit:(int)limit
               isStartNew:(BOOL)isStartNew{
    
    __block typeof(self) bself = self;
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *para = @{
                               PARA_MODE    : @(mode),
                               PARA_CONTESTID : SAFE_STRING(contestId),
                               PARA_OFFSET  : @(offset),
                               PARA_COUNT   : @(limit),
                               PARA_IS_START_NEW : @(isStartNew)
                               };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_USER_GUESS_OPUSES parameters:para];
        int resultCode = output.resultCode;
        NSArray *opuses = nil;
        
        if (resultCode == ERROR_SUCCESS){
            opuses = output.pbResponse.opusListList;
            for (PBOpus *pbOpus in opuses) {
                PPDebug(@"opusId : %@", pbOpus.opusId);
                PPDebug(@"opusDesc : %@", pbOpus.desc);
                PPDebug(@"opusName : %@", pbOpus.name);
                PPDebug(@"opusThumbImage : %@", pbOpus.thumbImage);
                PPDebug(@"opusImage : %@", pbOpus.image);
                PPDebug(@"opus author id = %@", pbOpus.author.userId);
                PPDebug(@"opus guessed: %@", pbOpus.guessInfo.isCorrect ? @"YES": @"NO");
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([bself.delegate respondsToSelector:@selector(didGetOpuses:resultCode:)]) {
                [bself.delegate didGetOpuses:opuses resultCode:resultCode];
            }
        });
    });
}



- (void)guessOpus:(PBOpus *)opus
             mode:(PBUserGuessMode)mode
        contestId:(NSString *)contestId
            words:(NSArray *)words
          correct:(BOOL)correct
        startDate:(NSDate *)startDate
          endDate:(NSDate *)endDate{
    
    if ([words count] == 0) {
        return;
    }
    
    __block typeof(self) bself = self;
    
    NSString *nickName = SAFE_STRING([[UserManager defaultManager] nickName]);
    NSString *avatarUrl = SAFE_STRING([[UserManager defaultManager] avatarURL]);
    NSString *gender = [[UserManager defaultManager] gender];
    NSString *guessWords = [words componentsJoinedByString:WORD_SPLIT_STRING];
    double start = [startDate timeIntervalSince1970];
    double end = [endDate timeIntervalSince1970];
    
    PPDebug(@"<%s> submit words: %@", __FUNCTION__, [words componentsJoinedByString:@","]);
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *para = @{
                               PARA_NICKNAME    : nickName,
                               PARA_AVATAR      : avatarUrl,
                               PARA_GENDER      : gender,
                               
                               PARA_OPUS_ID     : opus.opusId,
                               PARA_OPUS_CREATOR_UID    : opus.author.userId,
                               
                               PARA_MODE        : @(mode),
                               PARA_CONTESTID   : SAFE_STRING(contestId),
                               
                               PARA_WORD_LIST   : guessWords,
                               PARA_CORRECT     : @(correct),
                               
                               PARA_START_DATE  : @(start),
                               PARA_END_DATE    : @(end),
                               };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GUESS_OPUS parameters:para];
        int resultCode = output.resultCode;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([bself.delegate respondsToSelector:@selector(didGuessOpus:resultCode:)]) {
                [bself.delegate didGuessOpus:opus resultCode:resultCode];
            }
        });
    });
}

- (void)getGuessRankWithType:(int)type
                        mode:(PBUserGuessMode)mode
                   contestId:(NSString *)contestId{
    
    __block typeof(self) bself = self;
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *para = @{
                               PARA_TYPE        : @(type),
                               PARA_MODE        : @(mode),
                               PARA_CONTESTID   : SAFE_STRING(contestId),
                               };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_USER_GUESS_RANK parameters:para];
        int resultCode = output.resultCode;
        PBGuessRank *rank = nil;
        if (resultCode == ERROR_SUCCESS){
            rank = output.pbResponse.guessRank;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([bself.delegate respondsToSelector:@selector(didGetGuessRank:resultCode:)]) {
                [bself.delegate didGetGuessRank:rank resultCode:resultCode];
            }
        });
    });
}


- (void)getGuessRankListWithType:(int)type
                            mode:(PBUserGuessMode)mode
                       contestId:(NSString *)contestId
                          offset:(int)offset
                           limit:(int)limit{
    
    __block typeof(self) bself = self;
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *para = @{
                               PARA_TYPE        : @(type),
                               PARA_MODE        : @(mode),
                               PARA_CONTESTID   : SAFE_STRING(contestId),
                               PARA_OFFSET      : @(offset),
                               PARA_COUNT       : @(limit),
                               };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_GUESS_RANK_LIST parameters:para];
        int resultCode = output.resultCode;
        NSArray *rankList = nil;
        if (resultCode == ERROR_SUCCESS){
            rankList = output.pbResponse.guessRankListList;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([bself.delegate respondsToSelector:@selector(didGetGuessRankList:resultCode:)]) {
                [bself.delegate didGetGuessRankList:rankList resultCode:resultCode];
            }
        });
    });
}

- (void)getGuessContestList{
    
    __block typeof(self) bself = self;
    
    dispatch_async(workingQueue, ^{
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_GUESS_CONTEST_LIST parameters:nil];
        int resultCode = output.resultCode;
        NSArray *list = nil;
        if (resultCode == ERROR_SUCCESS){
            list = output.pbResponse.guessContestListList;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([bself.delegate respondsToSelector:@selector(didGetGuessContestList:resultCode:)]) {
                [bself.delegate didGetGuessContestList:list resultCode:resultCode];
            }
        });
    });
}

@end
