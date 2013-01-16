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
#import "Draw.pb.h"

@implementation DrawRecoveryService

SYNTHESIZE_SINGLETON_FOR_CLASS(DrawRecoveryService)

- (void)test
{
    [DrawRecoveryService defaultService];
}

- (int)recoveryDrawCount
{
    @try {
        int count = [[[MyPaintManager defaultManager] findAllDraftForRecovery] count];
        return count;
    }
    @catch (NSException *exception) {
        PPDebug(@"<recoveryDrawCount> but catch exception=%@", [exception description]);        
        return 0;
    }
}

- (void)start:(NSString *)targetUid
    contestId:(NSString *)contestId
       userId:(NSString *)userId
     nickName:(NSString *)nickName
         word:(Word *)word
     language:(NSInteger)language
{
    if (_currentPaint != nil){
        [self stop];
    }
    
    @try {
        _currentPaint = [[MyPaintManager defaultManager] createDraftForRecovery:targetUid
                                                                      contestId:contestId
                                                                         userId:userId
                                                                       nickName:nickName
                                                                           word:word
                                                                       language:language];

        PPDebug(@"<start> file name=%@", _currentPaint.dataFilePath);
    }
    @catch (NSException *exception) {
        PPDebug(@"<start> but catch exception=%@", [exception description]);
    }
    @finally {
    }
    
}

- (void)backup:(PBNoCompressDrawData*)drawData
{
    NSData* data = [drawData data];
    NSString* dataFileName = [_currentPaint.dataFilePath copy];
    
    dispatch_async(workingQueue, ^{
        PPDebug(@"<backup> file name=%@", dataFileName);
        
        // backup data to file
        [data writeToFile:dataFileName atomically:YES];
    });
    
    [dataFileName release];
}

- (void)stop
{
    @try {
        NSString* dataFileName = [_currentPaint.dataFilePath copy];
        PPDebug(@"<stop> file name=%@", dataFileName);
        
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
    @catch (NSException *exception) {
        PPDebug(@"<stop> but catch exception=%@", [exception description]);
    }
    @finally {
        
    }

}

@end
