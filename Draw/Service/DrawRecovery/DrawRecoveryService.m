//
//  DrawRecoveryService.m
//  Draw
//
//  Created by qqn_pipi on 13-1-16.
//
//

#import "DrawRecoveryService.h"
#import "SynthesizeSingleton.h"
#import "MyPaintManager.h"
#import "FileUtil.h"

@implementation DrawRecoveryService

SYNTHESIZE_SINGLETON_FOR_CLASS(DrawRecoveryService)

- (void)test
{
    [DrawRecoveryService defaultService];
}

- (int)recoveryDrawCount
{
    return [[[MyPaintManager defaultManager] findAllDraftForRecovery] count];
}

- (void)start:(NSString *)targetUid
    contestId:(NSString *)contestId
       userId:(NSString *)userId
     nickName:(NSString *)nickName
         word:(Word *)word
     language:(NSInteger)language
{
    _currentPaint = [[MyPaintManager defaultManager] createDraftForRecovery:targetUid
                                                                  contestId:contestId
                                                                     userId:userId
                                                                   nickName:nickName
                                                                       word:word
                                                                   language:language];
}

- (void)backup:(NSData*)drawData
{
    
}

- (void)stop
{
    NSString* dataFileName = [_currentPaint.dataFilePath copy];

    // delete paint from draft
    [[MyPaintManager defaultManager] deleteMyPaint:_currentPaint];
    
    // clear current paint
    _currentPaint = nil;    
    
    // delete file
    dispatch_async(workingQueue, ^{
        [FileUtil removeFile:dataFileName];
    });
    
    [dataFileName release];
}

@end
