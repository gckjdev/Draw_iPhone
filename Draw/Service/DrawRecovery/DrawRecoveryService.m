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
#import "ConfigManager.h"

@implementation DrawRecoveryService

SYNTHESIZE_SINGLETON_FOR_CLASS(DrawRecoveryService)

- (void)test
{
    [DrawRecoveryService defaultService];
}

- (BOOL)supportRecovery
{
    return [ConfigManager supportRecovery];
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
 
    if (![self supportRecovery]){
        PPDebug(@"<start> but recovery is not enable!");
        return;
    }    
    
    @try {
        self.currentPaint = [[MyPaintManager defaultManager] createDraftForRecovery:targetUid
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
    NSString* dataPath = [[MyPaintManager defaultManager] fullDataPath:dataFileName];
    
    dispatch_async(workingQueue, ^{
        PPDebug(@"<backup> file path=%@", dataPath);
        
        // backup data to file
        [data writeToFile:dataPath atomically:YES];
    });
    
    [dataFileName release];
}

- (void)stop
{
    @try {
        
        if (_currentPaint == nil)
            return;
        
        NSString* dataFileName = [_currentPaint.dataFilePath copy];
        NSString* dataPath = [[MyPaintManager defaultManager] fullDataPath:dataFileName];
        PPDebug(@"<stop> file=%@", dataPath);
        
        // delete paint from draft
        [[MyPaintManager defaultManager] completeDeletePaint:_currentPaint];
        
        // clear current paint
        self.currentPaint = nil;
                        
        // delete file
        dispatch_async(workingQueue, ^{
            [FileUtil removeFile:dataPath];
        });
        
        [dataFileName release];
    }
    @catch (NSException *exception) {
        PPDebug(@"<stop> but catch exception=%@", [exception description]);
    }
    @finally {
        
    }

}

- (int)backupInterval
{
    return [ConfigManager recoveryBackupInterval];
}

@end
