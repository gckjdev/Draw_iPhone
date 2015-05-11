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
#import "PPConfigManager.h"
#import "DrawAction.h"
#import "CoreDataUtil.h"
#import "DrawConstants.h"

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
    PPRelease(_desc);
    [super dealloc];
}

SYNTHESIZE_SINGLETON_FOR_CLASS(DrawRecoveryService)

- (void)test
{
    [DrawRecoveryService defaultService];
}

- (BOOL)supportRecovery
{
    return [PPConfigManager supportRecovery];
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

- (void)start:(NSArray*)drawActionList
    targetUid:(NSString*)targetUid
         word:(Word*)word
         desc:(NSString*)desc
   canvasSize:(CGSize)canvasSize
  bgImageName:(NSString*)bgImageName
      bgImage:(UIImage*)bgImage
    contestId:(NSString*)contestId
      strokes:(int64_t)strokes
    spendTime:(int)spendTime
 completeDate:(int)completeDate
       layers:(NSArray *)layers
   targetType:(TargetType)targetType
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
        
        // init basic info
        self.nickName = [[UserManager defaultManager] nickName];
        self.userId = [[UserManager defaultManager] userId];
        self.contestId = contestId;
        self.word = word;
        self.targetUid = targetUid;
        self.bgImageName = bgImageName;
        self.language = ChineseType;
        
        self.currentPaint = [[MyPaintManager defaultManager] createDraftForRecovery:self.targetUid
                                                                      contestId:self.contestId
                                                                         userId:self.userId
                                                                       nickName:self.nickName
                                                                           word:self.word
                                                                       language:self.language
                                                                    bgImageName:self.bgImageName
                                                                           desc:desc strokes:strokes
                                                                      spendTime:spendTime
                                                                   completeDate:completeDate
                                                                         targetType:targetType];

        PPDebug(@"<start> file name=%@ size=%@", _currentPaint.dataFilePath, NSStringFromCGSize(_canvasSize));
        
        [self backup:drawActionList
           targetUid:targetUid
                word:word
                desc:desc
          canvasSize:canvasSize
         bgImageName:bgImageName
             bgImage:bgImage
           contestId:contestId
             strokes:strokes
           spendTime:spendTime
        completeDate:completeDate
              layers:layers];
        
        [[MyPaintManager defaultManager] saveBgImage:_bgImage
                                                name:_currentPaint.bgImageName];
    }
    @catch (NSException *exception) {
        PPDebug(@"<start> but catch exception=%@", [exception description]);
    }
    @finally {
    }
    
}

- (void)backup:(NSArray*)drawActionList
     targetUid:(NSString*)targetUid
          word:(Word*)word
          desc:(NSString*)desc
    canvasSize:(CGSize)canvasSize
   bgImageName:(NSString*)bgImageName
       bgImage:(UIImage*)bgImage
     contestId:(NSString*)contestId
       strokes:(int64_t)strokes
     spendTime:(int)spendTime
  completeDate:(int)completeDate
        layers:(NSArray *)layers
{
    // add by Benson 2013-08-20 for protection
    if (self.currentPaint == nil){
        PPDebug(@"<backup> but current paint is nil");
        return;
    }
    
    // set and check canvas size
    self.canvasSize = canvasSize;
    if (CGSizeEqualToSize(self.canvasSize, CGSizeZero)){
        PPDebug(@"<backup> but canvas size is zero");
        return;
    }
    
    // set draw action list
    self.drawActionList = drawActionList;
    
    // set basic data
    BOOL hasChangeOnPaint = [self setDataWithTargetUid:targetUid
                                                  word:word
                                                  desc:desc
                                            canvasSize:canvasSize
                                           bgImageName:bgImageName
                                               bgImage:bgImage
                                             contestId:contestId
                                               strokes:strokes
                                             spendTime:spendTime
                                          completeDate:completeDate
                                                layers:layers];
    [self saveData:hasChangeOnPaint];
    
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
        
        int backupCount = [snapshotList count];
        NSArray* copyLayers = [cp.layers mutableCopy];
        
        int64_t outputStrokes = 0;
        
        // TODO check difference of two methods
        NSData* data = [DrawAction pbNoCompressDrawDataCFromDrawActionList:snapshotList
                                                                      size:cp.canvasSize
                                                                  opusDesc:cp.desc
                                                                drawToUser:cp.drawToUser
                                                           bgImageFileName:cp.currentPaint.bgImageName
                                                                    layers:copyLayers
                                                                   strokes:&outputStrokes
                                                                 spendTime:spendTime
                                                              completeDate:completeDate];
        [copyLayers release];
        
        // backup data to file
        if ([data length] > 0){
            PPDebug(@"<backup> total %d actions backup, file path=%@", backupCount, dataPath);
            [data writeToFile:dataPath atomically:YES];
        }
        else{
            PPDebug(@"<backup> no data for backup, total %d actions", backupCount);
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
        self.layers = nil;
        self.drawActionList = nil;
        self.drawToUser = nil;
        self.bgImage = nil;
        
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
    return [PPConfigManager recoveryBackupInterval];
}

- (BOOL)needBackup
{
    time_t nowTime = time(0);
    if (_newPaintCount >= [PPConfigManager drawAutoSavePaintInterval]){
        PPDebug(@"<needBackup> reach max paint count for save");
        return YES;
    }
    else if (_newPaintCount > 0 && ((nowTime - _lastBackupTime) >= [PPConfigManager drawAutoSavePaintTimeInterval]) ){
        PPDebug(@"<needBackup> reach max time interval for save");
        return YES;
    }
    else{
//        PPDebug(@"<needBackup> no need to backup");
        return NO;
    }
}

- (BOOL)setDataWithTargetUid:(NSString*)targetUid
                        word:(Word*)word
                        desc:(NSString*)desc
                  canvasSize:(CGSize)canvasSize
                 bgImageName:(NSString*)bgImageName
                     bgImage:(UIImage*)bgImage
                   contestId:(NSString*)contestId
                     strokes:(int64_t)strokes
                   spendTime:(int)spendTime
                completeDate:(int)completeDate
                      layers:(NSArray *)layers
{
    self.canvasSize = canvasSize;
    self.word = word;
    self.desc = desc;
    self.bgImage = bgImage;
    
    if (bgImageName){
        self.bgImageName = bgImageName;
    }
    
    if (layers){
        self.layers = [[[NSMutableArray arrayWithArray:layers] mutableCopy] autorelease];
    }
    
    BOOL hasChangeOnPaint = NO;
    
    if (targetUid && [self.currentPaint.targetUserId isEqualToString:targetUid] == NO){
        hasChangeOnPaint = YES;
    }
    if (contestId && [self.currentPaint.contestId isEqualToString:contestId] == NO){
        hasChangeOnPaint = YES;
    }
//    if (self.currentPaint.strokes != strokes){
//        hasChangeOnPaint = YES;
//    }
//    if (self.currentPaint.spendTime != spendTime){
//        hasChangeOnPaint = YES;
//    }
//    if (self.currentPaint.completeDate != completeDate){
//        hasChangeOnPaint = YES;
//    }
    
    self.currentPaint.targetUserId = targetUid;
    self.currentPaint.contestId = contestId;
    [self.currentPaint setTotalStrokes:@(strokes)];
    [self.currentPaint setOpusSpendTime:@(spendTime)];
    [self.currentPaint setOpusCompleteDate:[NSDate dateWithTimeIntervalSince1970:completeDate]];
    
    return hasChangeOnPaint;
}

- (void)saveData:(BOOL)needSave
{
    if (needSave){
        PPDebug(@"<hasChangeOnPaint> yes, save paint data");
        CoreDataManager* dataManager = GlobalGetCoreDataManager();
        [dataManager save];
    }
}

- (void)handleNewPaintDrawed:(NSArray*)drawActionList
                   targetUid:(NSString*)targetUid
                        word:(Word*)word
                        desc:(NSString*)desc
                  canvasSize:(CGSize)canvasSize
                 bgImageName:(NSString*)bgImageName
                     bgImage:(UIImage*)bgImage
                   contestId:(NSString*)contestId
                     strokes:(int64_t)strokes
                   spendTime:(int)spendTime
                completeDate:(int)completeDate
                      layers:(NSArray *)layers
{
//    PPDebug(@"<handleNewPaintDrawed> accumulate paint count =%d", _newPaintCount+1);
    
    self.drawActionList = drawActionList;
    
    
    if ([self needBackup]){
        
        [self backup:drawActionList
           targetUid:targetUid
                word:word
                desc:desc
          canvasSize:canvasSize
         bgImageName:bgImageName
             bgImage:bgImage
           contestId:contestId
             strokes:strokes
           spendTime:spendTime
        completeDate:completeDate
              layers:layers];
    }
    else{
        _newPaintCount ++;
    }
}

- (void)handleTimer:(NSArray*)drawActionList
          targetUid:(NSString*)targetUid
               word:(Word*)word
               desc:(NSString*)desc
         canvasSize:(CGSize)canvasSize
        bgImageName:(NSString*)bgImageName
            bgImage:(UIImage*)bgImage
          contestId:(NSString*)contestId
            strokes:(int64_t)strokes
          spendTime:(int)spendTime
       completeDate:(int)completeDate
             layers:(NSArray *)layers

{
//    PPDebug(@"<handleTimer> accumulate paint count =%d", _newPaintCount);
    if ([self needBackup]){
        
        [self backup:drawActionList
           targetUid:targetUid
                word:word
                desc:desc
          canvasSize:canvasSize
         bgImageName:bgImageName
             bgImage:bgImage
           contestId:contestId
             strokes:strokes
           spendTime:spendTime
        completeDate:completeDate
              layers:layers];
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
//    [self backup];
}

- (void)setDesc:(NSString *)desc
{
    if (_desc != desc) {
        PPRelease(_desc);
        _desc = desc;
        [_desc retain];
//        [self backup];
    }
}


@end
