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
#import "CoreDataUtil.h"

@interface DrawRecoveryService()

//@property (retain, nonatomic) UIImage *bgImage;

@end

@implementation DrawRecoveryService

- (void)dealloc
{

    PPRelease(_currentPaint);
    PPRelease(_drawToUser);
    PPRelease(_layers);
    PPRelease(_targetUid);
    PPRelease(_contestId);
    PPRelease(_userId);
    PPRelease(_nickName);
    PPRelease(_word);
    PPRelease(_drawActionList);
    PPRelease(_bgImage);
    PPRelease(_bgImageName);
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

- (void)start
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
        self.currentPaint = [[MyPaintManager defaultManager] createDraftForRecovery:self.targetUid
                                                                      contestId:self.contestId
                                                                         userId:self.userId
                                                                       nickName:self.nickName
                                                                           word:self.word
                                                                       language:self.language
                                                                        bgImageName:self.bgImageName];

        PPDebug(@"<start> file name=%@ size=%@", _currentPaint.dataFilePath, NSStringFromCGSize(_canvasSize));
        [self backup];        
        [[MyPaintManager defaultManager] saveBgImage:_bgImage name:_currentPaint.bgImageName];
    }
    @catch (NSException *exception) {
        PPDebug(@"<start> but catch exception=%@", [exception description]);
    }
    @finally {
    }
    
}

- (void)backup
{    
    NSString* dataFileName = [_currentPaint.dataFilePath copy];
    NSString* dataPath = [[[MyPaintManager defaultManager] fullDataPath:dataFileName] copy];
   
    NSMutableArray *snapshotList = nil;
    if ([self.drawActionList count] == 0){
        snapshotList = [[NSMutableArray alloc] init]; 
    }else{
        snapshotList = [[NSMutableArray alloc] initWithArray:_drawActionList copyItems:NO];
    // remove last paint to make it safe
        [snapshotList removeLastObject];
    }
    __block DrawRecoveryService *cp = self;
    
    dispatch_async(workingQueue, ^{

        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
        
        
        // TODO check difference of two methods
        NSData* data = [DrawAction pbNoCompressDrawDataCFromDrawActionList:snapshotList
                                                                      size:cp.canvasSize
                                                                  opusDesc:nil
                                                                drawToUser:cp.drawToUser
                                                           bgImageFileName:cp.currentPaint.bgImageName
                                                                    layers:cp.layers];

        PPDebug(@"<backup> file path=%@", dataPath);
        
        // backup data to file
        if ([data length] > 0){
            [data writeToFile:dataPath atomically:YES];
        }

        // release temp objects
        [subPool drain];
    });
    
    [dataPath release];
    [snapshotList release];
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
        self.canvasSize = CGSizeZero;
        
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
//        PPDebug(@"<needBackup> no need to backup");
        return NO;
    }
}

- (void)handleNewPaintDrawed:(NSArray*)drawActionList
{
//    PPDebug(@"<handleNewPaintDrawed> accumulate paint count =%d", _newPaintCount+1);
    self.drawActionList = drawActionList;
    if ([self needBackup]){
        [self backup];
    }
    else{
        _newPaintCount ++;
    }
}

- (void)handleTimer:(NSArray*)drawActionList
{
//    PPDebug(@"<handleTimer> accumulate paint count =%d", _newPaintCount);
    if ([self needBackup]){
        [self backup];
    }
}

-(void)setTargetUid:(NSString *)targetUid
{
    if(targetUid != _targetUid){
        PPRelease(_targetUid);
        _targetUid = targetUid;
        [_targetUid retain];

        if (self.currentPaint) {
            CoreDataManager* dataManager = GlobalGetCoreDataManager();
            [self.currentPaint setTargetUserId:targetUid];
            [dataManager save];
        }
    }
}

- (void)setCanvasSize:(CGSize)canvasSize
{
    if (CGSizeEqualToSize(_canvasSize, canvasSize)) {
        return;
    }
    _canvasSize = canvasSize;
    [self backup];
}


@end
