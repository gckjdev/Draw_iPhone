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


@implementation GuessService

SYNTHESIZE_SINGLETON_FOR_CLASS(GuessService);

- (void)getOpusesWithMode:(PBUserGuessMode)mode
                   offset:(int)offset
                    count:(int)count
               isStartNew:(BOOL)isStartNew{
    
    __block typeof(self) bself = self;
    dispatch_async(workingQueue, ^{
        
        NSDictionary *para = @{PARA_USERID  : [[UserManager defaultManager] userId],
                               PARA_APPID   : [ConfigManager appId],
                               PARA_MODE    : @(mode),
                               PARA_OFFSET  : @(offset),
                               PARA_COUNT   : @(count),
                               PARA_IS_START_NEW : @(isStartNew)
                               };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_USER_GUESS_OPUSES parameters:para];
        int resultCode = output.resultCode;
        NSArray *opuses = nil;
        
        if (resultCode == ERROR_SUCCESS){
            resultCode = output.pbResponse.resultCode;
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

#define SAFE_STRING(x) ((x == nil) ? @"" : (x))
#define WORD_SPLIT_STRING  @":"

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
    
    NSString *userId = SAFE_STRING([[UserManager defaultManager] userId]);
    NSString *nickName = SAFE_STRING([[UserManager defaultManager] nickName]);
    NSString *avatarUrl = SAFE_STRING([[UserManager defaultManager] avatarURL]);
    NSString *gender = [[UserManager defaultManager] gender];
    NSString *guessWords = [words componentsJoinedByString:WORD_SPLIT_STRING];
    double start = [startDate timeIntervalSince1970];
    double end = [endDate timeIntervalSince1970];
    
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *para = @{PARA_APPID       : [ConfigManager appId],
                               PARA_USERID      : userId,
                               PARA_NICKNAME    : nickName,
                               PARA_AVATAR      : avatarUrl,
                               PARA_GENDER      : gender,
                               
//                               PARA_OPUS_ID     : opus.opusId,
                               PARA_OPUS_ID     : @"51e5084a03648b38d2d61de5",
//                               PARA_OPUS_CREATOR_UID    : opus.author.userId,
                               PARA_OPUS_CREATOR_UID    : @"51e507ff036498e676b37fed",
                               
                               PARA_MODE        : @(mode),
                               PARA_CONTESTID   : SAFE_STRING(contestId),
                               
                               PARA_WORD_LIST   : guessWords,
                               PARA_CORRECT     : @(correct),
                               
                               PARA_START_DATE  : @(start),
                               PARA_END_DATE    : @(end),
                               };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GUESS_OPUS parameters:para];
        int resultCode = output.resultCode;
        if (resultCode == ERROR_SUCCESS){
            resultCode = output.pbResponse.resultCode;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([bself.delegate respondsToSelector:@selector(didGuessOpus:resultCode:)]) {
                [bself.delegate didGuessOpus:opus resultCode:resultCode];
            }
        });
    });
}

- (void)getGuessRankWithMode:(PBUserGuessMode)mode
                   contestId:(NSString *)contestId{
    
    __block typeof(self) bself = self;
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *para = @{PARA_APPID       : [ConfigManager appId],
//                               PARA_USERID      : SAFE_STRING(userId),
                               PARA_USERID      : @"51e4f554036498e676b37fe7",
                               PARA_MODE        : @(mode),
                               PARA_CONTESTID   : SAFE_STRING(contestId),
                               };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_USER_GUESS_RANK parameters:para];
        int resultCode = output.resultCode;
        PBGuessRank *rank = nil;
        if (resultCode == ERROR_SUCCESS){
            resultCode = output.pbResponse.resultCode;
            rank = output.pbResponse.guessRank;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([bself.delegate respondsToSelector:@selector(didGetGuessRank:resultCode:)]) {
                [bself.delegate didGetGuessRank:rank resultCode:resultCode];
            }
        });
    });
}


- (void)getGuessRankListWithMode:(PBUserGuessMode)mode
                       contestId:(NSString *)contestId{
    
    __block typeof(self) bself = self;
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *para = @{PARA_APPID       : [ConfigManager appId],
                               PARA_MODE        : @(mode),
                               PARA_CONTESTID   : SAFE_STRING(contestId),
                               };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_GUESS_RANK_LIST parameters:para];
        int resultCode = output.resultCode;
        NSArray *rankList = nil;
        if (resultCode == ERROR_SUCCESS){
            resultCode = output.pbResponse.resultCode;
            rankList = output.pbResponse.guessRankListList;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([bself.delegate respondsToSelector:@selector(didGetGuessRankList:resultCode:)]) {
                [bself.delegate didGetGuessRankList:rankList resultCode:resultCode];
            }
        });
    });
}

@end
