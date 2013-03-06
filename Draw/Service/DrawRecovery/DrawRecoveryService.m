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
#import "DrawAction.h"


@interface DrawRecoveryService()
{
    
}
@property(nonatomic, assign)CGSize size;
@property(nonatomic, retain)PBDrawBg *drawBg;

@end

@implementation DrawRecoveryService


- (void)dealloc
{
    PPRelease(_drawBg);
    [super dealloc];
}

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
    
    _newPaintCount = 0;
    _lastBackupTime = time(0);
 
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

- (void)backup:(NSArray*)drawActionList
{    
    NSString* dataFileName = [_currentPaint.dataFilePath copy];
    NSString* dataPath = [[MyPaintManager defaultManager] fullDataPath:dataFileName];
    
    NSMutableArray* arrayList=[[NSMutableArray alloc] initWithArray:drawActionList copyItems:NO];
    
    // remove last paint to make it safe
    if ([arrayList count] > 0){
        [arrayList removeLastObject];
    }
    
    __block DrawRecoveryService *cp = self;
    
    dispatch_async(workingQueue, ^{

        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
        
        PBNoCompressDrawData* drawData = [DrawAction drawActionListToPBNoCompressDrawData:arrayList
                                                                                 pbdrawBg:cp.drawBg
                                                                                     size:CGSizeZero];
        NSData* data = [drawData data];

        PPDebug(@"<backup> file path=%@", dataPath);
        
        // backup data to file
        [data writeToFile:dataPath atomically:YES];

        // release temp objects
        [subPool drain];
    });
    
    [arrayList release];
    [dataFileName release];
    
    _lastBackupTime = time(0);
    _newPaintCount = 0;
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

- (BOOL)needBackup
{
    time_t nowTime = time(0);
    if (_newPaintCount >= [ConfigManager drawAutoSavePaintInterval]){
        PPDebug(@"<needBackup> reach max paint count for save");
        return YES;
    }
    else if (_newPaintCount > 0 && ((nowTime - _lastBackupTime) >= [ConfigManager drawAutoSavePaintTimeInterval]) ){
        PPDebug(@"<needBackup> reach max time interval for save");
        return YES;
    }
    else{
        PPDebug(@"<needBackup> no need to backup");
        return NO;
    }
}

- (void)handleNewPaintDrawed:(NSArray*)drawActionList
{
    PPDebug(@"<handleNewPaintDrawed> accumulate paint count =%d", _newPaintCount+1);
    if ([self needBackup]){
        [self backup:drawActionList];
    }
    else{
        _newPaintCount ++;
    }
}

- (void)handleTimer:(NSArray*)drawActionList
{
    PPDebug(@"<handleTimer> accumulate paint count =%d", _newPaintCount);
    if ([self needBackup]){
        [self backup:drawActionList];
    }
}

- (void)handleChangeDrawBg:(PBDrawBg *)drawBg
{
    self.drawBg = drawBg;
}

@end
