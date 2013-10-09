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
#import "TimeUtils.h"

#define SAFE_STRING(x) ((x == nil) ? @"" : (x))
#define WORD_SPLIT_STRING  @":"

@interface GuessService ()
@property (retain, nonatomic) PBContest *contest;


@end

@implementation GuessService

SYNTHESIZE_SINGLETON_FOR_CLASS(GuessService);

- (void)getOpusesWithMode:(PBUserGuessMode)mode
                contestId:(NSString *)contestId
                   offset:(int)offset
                    limit:(int)limit
               isStartNew:(BOOL)isStartNew
                 delegate:(id<GuessServiceDelegate>)delegate{
    
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
            
            if ([delegate respondsToSelector:@selector(didGetOpuses:resultCode:isStartNew:)]) {
                [delegate didGetOpuses:opuses resultCode:resultCode isStartNew:isStartNew];
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
          endDate:(NSDate *)endDate
         delegate:(id<GuessServiceDelegate>)delegate{
    
    if ([words count] == 0) {
        return;
    }
        
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
            
            if ([delegate respondsToSelector:@selector(didGuessOpus:resultCode:)]) {
                [delegate didGuessOpus:opus resultCode:resultCode];
            }
        });
    });
}

- (void)getGuessRankWithType:(int)type
                        mode:(PBUserGuessMode)mode
                   contestId:(NSString *)contestId
                    delegate:(id<GuessServiceDelegate>)delegate{
        
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
            
            if ([delegate respondsToSelector:@selector(didGetGuessRank:resultCode:)]) {
                [delegate didGetGuessRank:rank resultCode:resultCode];
            }
        });
    });
}


- (void)getGuessRankListWithType:(int)type
                            mode:(PBUserGuessMode)mode
                       contestId:(NSString *)contestId
                          offset:(int)offset
                           limit:(int)limit
                        delegate:(id<GuessServiceDelegate>)delegate{
        
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
        int totalCount = 0;
        NSArray *rankList = nil;
        if (resultCode == ERROR_SUCCESS){
            totalCount = output.pbResponse.totalCount;
            rankList = output.pbResponse.guessRankListList;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([delegate respondsToSelector:@selector(didGetGuessRankList:totalCount:mode:resultCode:)]) {
                [delegate didGetGuessRankList:rankList
                                   totalCount:totalCount
                                         mode:mode
                                   resultCode:resultCode];
            }
        });
    });
}

- (void)getGuessContestListWithDelegate:(id<GuessServiceDelegate>)delegate{
    
    if (self.contest != nil) {
        
        if ([delegate respondsToSelector:@selector(didGetGuessContestList:resultCode:)]) {
            [delegate didGetGuessContestList:@[self.contest] resultCode:0];
        }
        
        return;
    }
    
    __block typeof (self) bself = self;
    dispatch_async(workingQueue, ^{
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_GUESS_CONTEST_LIST parameters:nil];
        int resultCode = output.resultCode;
        NSArray *list = nil;
        if (resultCode == ERROR_SUCCESS){
            list = output.pbResponse.guessContestListList;
            
            if ([list count] > 0) {
                bself.contest = [list objectAtIndex:0];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([delegate respondsToSelector:@selector(didGetGuessContestList:resultCode:)]) {
                [delegate didGetGuessContestList:list resultCode:resultCode];
            }
        });
    });
}

- (void)getRecentGuessContestListWithDelegate:(id<GuessServiceDelegate>)delegate;{
    
    dispatch_async(workingQueue, ^{
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_RECENT_GUESS_CONTEST_LIST parameters:nil];
        int resultCode = output.resultCode;
        NSArray *list = nil;
        if (resultCode == ERROR_SUCCESS){
            list = output.pbResponse.guessContestListList;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([delegate respondsToSelector:@selector(didGetGuessContestList:resultCode:)]) {
                [delegate didGetGuessContestList:list resultCode:resultCode];
            }
        });
    });
}



static NSMutableDictionary* TITLE_DICT;

+ (NSString*)geniusTitle:(int)correctCount
{
//    NSArray* COUNT_ARRAY = @[@(0), @(10), @(20), @(30), @(40), @(50), @(60), @(70), @(80), @(90)];
//    NSArray* TITLE_ARRAY = @[NSLS(@"kLevel0"), NSLS(@"kLevel1"), NSLS(@"kLevel2"), NSLS(@"kLevel3"), NSLS(@"kLevel4"), NSLS(@"kLevel5"), NSLS(@"kLevel6"), NSLS(@"kLevel7"), NSLS(@"kLevel8"), NSLS(@"kLevel9")];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TITLE_DICT = [[NSMutableDictionary dictionary] retain];
        
        
        TITLE_DICT[@(0)] = NSLS(@"kLevelNameFirst");
        
        int MAX_TITLE_PER_SEGMENT = 13;
        int SEGMENT_COUNT = 5;
        
        int i=1;
        for (int segment = 0; segment < SEGMENT_COUNT; segment++){
            
            NSString* levelNameKey = [NSString stringWithFormat:@"kLevelName%d", segment];
            NSString* levelName = NSLS(levelNameKey);
            
            for (int titleInSegment = 0; titleInSegment < MAX_TITLE_PER_SEGMENT; titleInSegment++){
                
                NSString* key = [NSString stringWithFormat:@"kLevel%d", titleInSegment+1];
                
                NSString* desc = [NSString stringWithFormat:NSLS(key), levelName];
                TITLE_DICT[@(i)] = desc;
                i++;
            }
        }
        
        TITLE_DICT[@(i)] = NSLS(@"kLevelNameLast");        
        
        int levelCount = [[TITLE_DICT allKeys] count];
        for (int i=0; i<levelCount; i++){
            PPDebug(@"level[%d]=%@", i, TITLE_DICT[@(i)]);
        }
        
//        PPDebug(@"TITLE_DICT=%@", [TITLE_DICT allValues]);
//        POSTMSG(TITLE_DICT[@(16)]);
    });
    
    int levelCount = [[TITLE_DICT allKeys] count];
    int level = (correctCount / 10);
    if (level > levelCount){
        level = levelCount;
    }
    else if (level < 0){
        level = 0;
    }

    NSString* title = TITLE_DICT[@(level)];
    if (title == nil)
        return @"";
    else
        return title;
    
//    int totalCount = [COUNT_ARRAY count];
//    int level = -1;
//    if (correctCount >= [COUNT_ARRAY[totalCount-1] intValue]){
//        level = totalCount-1;
//    }
//    else if (correctCount >= [COUNT_ARRAY[0] intValue]){
//        for (int i=0; i<totalCount-2; i++){
//            
//            int from = [COUNT_ARRAY[i] intValue];
//            int to = [COUNT_ARRAY[i+1] intValue];
//            
//            if (correctCount >= from && correctCount < to){
//                level = i;
//                break;
//            }
//        }
//    }
//    
//    if (level == -1 || level >= totalCount){
//        return @"";
//    }
//    else{
//        return TITLE_ARRAY[level];
//    }        
}

@end
