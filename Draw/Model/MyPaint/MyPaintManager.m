//
//  MyPaintManager.m
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyPaintManager.h"
#import "CoreDataUtil.h"
#import "UIImageExt.h"
#import "PPDebug.h"
#import "FileUtil.h"
#import "UserManager.h"
#import "StringUtil.h"
#import "GameMessage.pb.h"
#import "Draw.h"
#include <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>
#import "Draw.pb.h"
#import "DrawAction.h"
#import "DrawFeed.h"
#import "CanvasRect.h"
#import "TimeUtils.h"
#import "Draw.pb-c.h"


#define SUFFIX_NUMBER 100
@interface MyPaintManager()
{
    id<MyPaintManagerDelegate> _savePhotoToAlbumDelegate;
}
//- (void)deletePaintImage:(NSString *)paintImage sync:(BOOL)sync;
- (void)deletePaintData:(NSString *)path;
- (void)transferDrawDataToPath:(NSArray *)paints;
@end


@implementation MyPaintManager

static MyPaintManager* _defaultManager;
#define PIANT_IMAGE_DIR @"Paints"
#define PIANT_DATA_DIR @"PaintData"
#define PAINT_BG_IMAGE_DIR  @"PaintBgs"

#define DRAW_ACTION_DATA_SUFFIX @".dat"
#define PBDRAW_DATA_SUFFIX @"_pb.dat"
#define PBNOCOMPRESS_DRAWDATA_SUFFIX @"_npb.dat"
#define IMAGE_SUFFIX @".png"

- (BOOL)saveDataAsPBDraw:(MyPaint *)paint
{
    NSRange range = [paint.dataFilePath rangeOfString:PBDRAW_DATA_SUFFIX];
    return range.length != 0;
}

- (BOOL)saveDataAsPBNOCompressDrawData:(MyPaint *)paint
{
    NSRange range = [paint.dataFilePath rangeOfString:PBNOCOMPRESS_DRAWDATA_SUFFIX];
    return range.length != 0;
}

- (NSString *)drawActionFileName
{
    NSString* fileName = [NSString stringWithFormat:@"%@%@", [NSString GetUUID],
                          DRAW_ACTION_DATA_SUFFIX];
    return fileName;
}

- (NSString *)pbDataFileName
{
    NSString* fileName = [NSString stringWithFormat:@"%@%@", [NSString GetUUID],
                          PBDRAW_DATA_SUFFIX];
    return fileName;

}

- (NSString *)pbNoCompressDrawDataFileName
{
    NSString* fileName = [NSString stringWithFormat:@"%@%@", [NSString GetUUID],
                          PBNOCOMPRESS_DRAWDATA_SUFFIX];
    return fileName;
    
}

- (NSString *)imageFileName
{
    NSString* fileName = [NSString stringWithFormat:@"%@%@", [NSString GetUUID],
                          IMAGE_SUFFIX];
    return fileName;    
}


- (id)init
{
    self = [super init];
    if (self) {
        _imageManager = [[StorageManager alloc] initWithStoreType:StorageTypePersistent directoryName:PIANT_IMAGE_DIR];
        _drawDataManager = [[StorageManager alloc] initWithStoreType:StorageTypePersistent directoryName:PIANT_DATA_DIR];
        _bgImgeManager = [[StorageManager alloc] initWithStoreType:StorageTypePersistent directoryName:PAINT_BG_IMAGE_DIR];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_imageManager);
    PPRelease(_drawDataManager);
    PPRelease(_bgImgeManager);
    [super dealloc];
}

+ (MyPaintManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[MyPaintManager alloc] init];
    }
    
    return _defaultManager;
}



- (void)transferDrawDataToPath:(NSArray *)paints
{
    PPDebug(@"<transferDrawDataToPath> start");
    BOOL needSave = NO;
    for (MyPaint *paint in paints) {
        if (paint.data) {
            NSString *key = [self drawActionFileName];
            [_drawDataManager saveData:paint.data forKey:key];
            paint.dataFilePath = key;
            paint.data = nil;
            needSave = YES;
        }
    }
    if (needSave) {
        PPDebug(@"<transferDrawDataToPath> save data.");
        [[CoreDataManager defaultManager] save];        
    }
    PPDebug(@"<transferDrawDataToPath> end");
}

- (void)findMyPaintsFrom:(NSInteger)offset 
                       limit:(NSInteger)limit 
                    delegate:(id<MyPaintManagerDelegate>)delegate
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    NSArray *array = [dataManager execute:@"findOnlyMyPaints" sortBy:@"createDate" returnFields:nil ascending:NO offset:offset limit:limit];
    [self transferDrawDataToPath:array];
    if (delegate && [delegate respondsToSelector:@selector(didGetMyPaints:)]) {
        [delegate didGetMyPaints:array];
    }
}

//- (void)countMyPaints:(id<MyPaintManagerDelegate>)delegate
//{
//    CoreDataManager* dataManager = GlobalGetCoreDataManager();
//    NSArray *array = [dataManager execute:@"findOnlyMyPaints" sortBy:@"createDate" returnFields:nil ascending:NO offset:0 limit:HUGE_VAL];
//
//    if (delegate && [delegate respondsToSelector:@selector(didCountMyPaints::)]) {
//        [delegate didCountMyPaints:[array count]];
//    }
//}

- (NSArray*)findAllDraftForRecovery
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    NSArray *array = [dataManager execute:@"findAllRecoveryPaints" sortBy:@"createDate" ascending:NO];
    return array;
}


- (void)findAllPaintsFrom:(NSInteger)offset 
                        limit:(NSInteger)limit 
                     delegate:(id<MyPaintManagerDelegate>)delegate
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    NSArray *array = [dataManager execute:@"findAllMyPaints" sortBy:@"createDate" returnFields:nil ascending:NO offset:offset limit:limit];
    [self transferDrawDataToPath:array];

    if (delegate && [delegate respondsToSelector:@selector(didGetAllPaints:)]) {
        [delegate didGetAllPaints:array];
    }
}

//- (void)countAllPaints:(id<MyPaintManagerDelegate>)delegate
//{
//    CoreDataManager* dataManager = GlobalGetCoreDataManager();
//    NSArray *array = [dataManager execute:@"findAllMyPaints" sortBy:@"createDate" returnFields:nil ascending:NO offset:0 limit:HUGE_VAL];
//    
//    if (delegate && [delegate respondsToSelector:@selector(didCountAllPaints:)]) {
//        [delegate didCountAllPaints:[array count]];
//    }
//}

- (void)findAllDraftsFrom:(NSInteger)offset 
                    limit:(NSInteger)limit 
                 delegate:(id<MyPaintManagerDelegate>)delegate
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    NSArray *array = [dataManager execute:@"findAllDrafts" sortBy:@"createDate" returnFields:nil ascending:NO offset:offset limit:limit];
    [self transferDrawDataToPath:array];

    if (delegate && [delegate respondsToSelector:@selector(didGetAllDrafts:)]) {
        [delegate didGetAllDrafts:array];
    } 
}

//- (void)countAllDrafts:(id<MyPaintManagerDelegate>)delegate
//{
//    CoreDataManager* dataManager = GlobalGetCoreDataManager();
//    NSArray *array = [dataManager execute:@"findAllDrafts" sortBy:@"createDate" returnFields:nil ascending:NO offset:0 limit:HUGE_VAL];
//    if (delegate && [delegate respondsToSelector:@selector(didCountAllDrafts:)]) {
//        [delegate didCountAllDrafts:[array count]];
//    }
//}

- (void)countAllPaintsAndDrafts:(id<MyPaintManagerDelegate>)delegate
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    NSArray *draftArray = [dataManager execute:@"findAllDrafts" sortBy:@"createDate" returnFields:nil ascending:NO offset:0 limit:HUGE_VAL];
    NSArray *allArray = [dataManager execute:@"findAllMyPaints" sortBy:@"createDate" returnFields:nil ascending:NO offset:0 limit:HUGE_VAL];
    NSArray *myArray = [dataManager execute:@"findOnlyMyPaints" sortBy:@"createDate" returnFields:nil ascending:NO offset:0 limit:HUGE_VAL];
    
    if (delegate && [delegate respondsToSelector:@selector(didGetAllPaintCount:myPaintCount:draftCount:)]) {
        [delegate didGetAllPaintCount:allArray.count myPaintCount:myArray.count draftCount:draftArray.count];
    }
}


- (void)removeAlldeletedPaints
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    NSArray* array = [dataManager execute:@"findAllDeletedPaints"];
    
    PPDebug(@"<removeAlldeletedPaints> count = %d", [array count]);
    
    @try {
        for (MyPaint* paint in array){
            [paint setDeleteFlag:[NSNumber numberWithBool:YES]];
            
            //delete image
            [FileUtil removeFile:paint.imageFilePath];
            
            //delete data        
            [self deletePaintData:paint.dataFilePath];
            
            [dataManager del:paint];
        }
        [dataManager save];    

    }
    @catch (NSException *exception) {
        NSLog(@"exception: %@, reason: %@",[exception description], [exception reason]);
    }
    @finally {
        
    }
    
}

- (BOOL)deletePaintsByRquestName:(NSString *)requestName
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    NSArray* array = [dataManager execute:requestName];
    for (MyPaint* paint in array){
        [paint setDeleteFlag:[NSNumber numberWithBool:YES]];
        [self deleteBgImage:paint.bgImageName];
    }
    [dataManager save];    
    return YES;

}

- (BOOL)deleteAllPaints:(BOOL)onlyDrawnByMe
{
    if (onlyDrawnByMe) {
        return [self deletePaintsByRquestName:@"findOnlyMyPaints"];
    } else {
        return [self deletePaintsByRquestName:@"findAllMyPaints"];
    }
}

- (BOOL)deleteAllDrafts
{
       return [self deletePaintsByRquestName:@"findAllDrafts"];
}

- (void)deletePaintData:(NSString *)path
{
    [_drawDataManager removeDataForKey:path];
}

- (void)deleteBgImage:(NSString *)imageName
{
    if (imageName) {
        [_bgImgeManager removeDataForKey:imageName];
    }
}

- (BOOL)deleteMyPaint:(MyPaint*)paint
{
    [self deleteBgImage:paint.bgImageName];
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    [paint setDeleteFlag:[NSNumber numberWithBool:YES]];
    BOOL result = [dataManager save];
    
    return result;
}

- (BOOL)completeDeletePaint:(MyPaint*)paint
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    [dataManager del:paint];
    BOOL result = [dataManager save];
    
    return result;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    PPDebug(@"Save Photo, Result=%@", [error description]);
    if (_savePhotoToAlbumDelegate && [_savePhotoToAlbumDelegate respondsToSelector:@selector(didSaveToAlbumSuccess:)]) {
        [_savePhotoToAlbumDelegate didSaveToAlbumSuccess:YES];
    }
}

- (void)savePhoto:(NSString*)filePath delegate:(id<MyPaintManagerDelegate>)delegate
{
    PPDebug(@"Save Photo, File=%@", filePath);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    if (queue == NULL){
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    }
    
    dispatch_async(queue, ^{
        UIImage* image = [[UIImage alloc] initWithContentsOfFile:filePath];
        
        UIImageWriteToSavedPhotosAlbum(image,
                                       self, 
                                       @selector(image:didFinishSavingWithError:contextInfo:),
                                       nil);
        _savePhotoToAlbumDelegate = delegate;
        [image release];    
    });
}

- (BOOL)save
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    return [dataManager save];    
}


#pragma mark new methods.

- (void)initMyPaint:(MyPaint *)newMyPaint
              image:(UIImage*)image
         pbDrawData:(NSData*)pbDrawData
               feed:(DrawFeed*)feed

//             userId:(NSString*)userId
//           nickName:(NSString*)nickName
//               word:(NSString*)word
//           language:(int)language
//              level:(int)level
{
    NSString *imageFileName = [self imageFileName];
    NSString *pbDataFileName = [self pbDataFileName];
    
    [_imageManager saveImage:image forKey:imageFileName];
    [_drawDataManager saveData:pbDrawData forKey:pbDataFileName];
    //    [_drawDataManager saveData:[pbDrawData data] forKey:pbDataFileName];
    
    
    [newMyPaint setDataFilePath:pbDataFileName];
    [newMyPaint setImage:imageFileName];
    
    BOOL drawByMe = [[UserManager defaultManager] isMe:feed.feedUser.userId];
    
    [newMyPaint setDrawByMe:[NSNumber numberWithBool:drawByMe]];
    [newMyPaint setDrawUserId:feed.feedUser.userId];
    [newMyPaint setDrawUserNickName:feed.feedUser.nickName];
    [newMyPaint setCreateDate:[NSDate date]];
    
    if (isLearnDrawApp()) {
        NSString *word = dateToLocaleStringWithFormat([NSDate date], DATE_FORMAT);
        [newMyPaint setDrawWord:word];
    }else{
        [newMyPaint setDrawWord:feed.wordText];
    }
    [newMyPaint setLanguage:[NSNumber numberWithInt:ChineseType]];      // hard code here, some risk?
    [newMyPaint setLevel:[NSNumber numberWithInt:1]];                   // hard code here, some risk?

}

- (void)initMyPaint:(MyPaint *)newMyPaint
              image:(UIImage*)image
             pbDraw:(PBDraw*)pbDraw
{
    NSString *imageFileName = [self imageFileName];
    NSString *pbDataFileName = [self pbDataFileName];
    
    [_imageManager saveImage:image forKey:imageFileName];
    [_drawDataManager saveData:[pbDraw data] forKey:pbDataFileName];
    //    [_drawDataManager saveData:[pbDrawData data] forKey:pbDataFileName];
    
    
    [newMyPaint setDataFilePath:pbDataFileName];
    [newMyPaint setImage:imageFileName];
    
    BOOL drawByMe = [[UserManager defaultManager] isMe:pbDraw.userId];
    
    [newMyPaint setDrawByMe:[NSNumber numberWithBool:drawByMe]];
    [newMyPaint setDrawUserId:pbDraw.userId];
    [newMyPaint setDrawUserNickName:pbDraw.nickName];
    [newMyPaint setCreateDate:[NSDate date]];
    [newMyPaint setDrawWord:pbDraw.word];
    
    // hard code here, some risk?
    [newMyPaint setLanguage:[NSNumber numberWithInt:pbDraw.language]];
    
    // hard code here, some risk?
    [newMyPaint setLevel:[NSNumber numberWithInt:pbDraw.level]];
    
    
}

- (void)initMyPaint:(MyPaint *)newMyPaint
              image:(UIImage*)image
           drawData:(NSData*)drawData
             userId:(NSString *)userId
           nickName:(NSString *)nickName
               word:(Word *)word
           language:(NSInteger)language
            bgImage:(UIImage *)bgImage
        bgImageName:(NSString *)bgImageName
{
    NSString *imageFileName = [self imageFileName];
    NSString *pbDataFileName = [self pbNoCompressDrawDataFileName];
    
    if (image != nil){
        [_imageManager saveImage:image forKey:imageFileName];
    }
    
    if (drawData != nil){
        [_drawDataManager saveData:drawData forKey:pbDataFileName];
    }
    
    if (bgImage != nil) {
        //        [_bgImgeManager saveData:[bgImage data] forKey:pbNoCompressDrawData.bgImageName];
        [_bgImgeManager saveImage:bgImage forKey:bgImageName];
    }
    
    [newMyPaint setDataFilePath:pbDataFileName];
    [newMyPaint setImage:imageFileName];
    
    BOOL drawByMe = [[UserManager defaultManager] isMe:userId];
    
    [newMyPaint setDrawByMe:[NSNumber numberWithBool:drawByMe]];
    [newMyPaint setDrawUserId:userId];
    [newMyPaint setDrawUserNickName:nickName];
    [newMyPaint setCreateDate:[NSDate date]];
    [newMyPaint setDrawWord:word.text];
    [newMyPaint setLevel:[NSNumber numberWithInt:word.level]];
    [newMyPaint setLanguage:[NSNumber numberWithInt:language]];
    [newMyPaint setBgImageName:bgImageName];
}


- (void)initMyPaint:(MyPaint *)newMyPaint
              image:(UIImage*)image
pbNoCompressDrawData:(PBNoCompressDrawData*)pbNoCompressDrawData
             userId:(NSString *)userId
           nickName:(NSString *)nickName
               word:(Word *)word
           language:(NSInteger)language
            bgImage:(UIImage *)bgImage
{
    [self initMyPaint:newMyPaint
                image:image
             drawData:[pbNoCompressDrawData data]
               userId:userId
             nickName:nickName
                 word:word
             language:language
              bgImage:bgImage
          bgImageName:pbNoCompressDrawData.bgImageName];
    
//    NSString *imageFileName = [self imageFileName];
//    NSString *pbDataFileName = [self pbNoCompressDrawDataFileName];
//    
//    if (image != nil){
//        [_imageManager saveImage:image forKey:imageFileName];
//    }
//        
//    if (pbNoCompressDrawData != nil){
//        [_drawDataManager saveData:[pbNoCompressDrawData data] forKey:pbDataFileName];
//    }    
//    
//    if (bgImage != nil) {
//        [_bgImgeManager saveImage:bgImage forKey:pbNoCompressDrawData.bgImageName];
//    }
//    
//    [newMyPaint setDataFilePath:pbDataFileName];
//    [newMyPaint setImage:imageFileName];
//    
//    BOOL drawByMe = [[UserManager defaultManager] isMe:userId];
//    
//    [newMyPaint setDrawByMe:[NSNumber numberWithBool:drawByMe]];
//    [newMyPaint setDrawUserId:userId];
//    [newMyPaint setDrawUserNickName:nickName];
//    [newMyPaint setCreateDate:[NSDate date]];
//    [newMyPaint setDrawWord:word.text];
//    [newMyPaint setLevel:[NSNumber numberWithInt:word.level]];
//    [newMyPaint setLanguage:[NSNumber numberWithInt:language]];
//    [newMyPaint setBgImageName:pbNoCompressDrawData.bgImageName];
}

- (BOOL)createMyPaintWithImage:(UIImage*)image
                    pbDrawData:(NSData*)pbDrawData
                          feed:(DrawFeed*)feed
//                        userId:(NSString*)userId
//                      nickName:(NSString*)nickName
//                          word:(NSString*)word
//                      language:(int)language
//                         level:(int)level

{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    MyPaint* newMyPaint = [dataManager insert:@"MyPaint"];
    
    [self initMyPaint:newMyPaint
                image:image
           pbDrawData:pbDrawData
                 feed:feed];
    
    [newMyPaint setDraft:[NSNumber numberWithBool:NO]];
    
    PPDebug(@"<createMyPaintWithImage> %@", [newMyPaint description]);
    return [dataManager save];
    
}

- (BOOL)createMyPaintWithImage:(UIImage*)image
                        pbDraw:(PBDraw*)pbDraw
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    MyPaint* newMyPaint = [dataManager insert:@"MyPaint"];
    
    [self initMyPaint:newMyPaint
                image:image
               pbDraw:pbDraw];
    
    [newMyPaint setDraft:[NSNumber numberWithBool:NO]];
    
    PPDebug(@"<createMyPaintWithImage> %@", [newMyPaint description]);
    return [dataManager save];
    
}

- (MyPaint *)createDraft:(UIImage *)image
    pbNoCompressDrawData:(PBNoCompressDrawData *)pbNoCompressDrawData
               targetUid:(NSString *)targetUid
               contestId:(NSString *)contestId
                  userId:(NSString *)userId
                nickName:(NSString *)nickName
                    word:(Word *)word
                language:(NSInteger)language
                 bgImage:(UIImage *)bgImage
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    MyPaint* newMyPaint = [dataManager insert:@"MyPaint"];
    [self initMyPaint:newMyPaint
                image:image
 pbNoCompressDrawData:pbNoCompressDrawData
               userId:userId
             nickName:nickName
                 word:word
             language:language
              bgImage:bgImage];
    [newMyPaint setTargetUserId:targetUid];
    [newMyPaint setContestId:contestId];
    [newMyPaint setDraft:[NSNumber numberWithBool:YES]];
    [newMyPaint setDrawWordData:[word data]];
    PPDebug(@"<createDraft> %@", [newMyPaint description]);
    [dataManager save];
    return newMyPaint;
}

- (MyPaint *)createDraft:(UIImage *)image
                drawData:(NSData *)drawData
               targetUid:(NSString *)targetUid
               contestId:(NSString *)contestId
                  userId:(NSString *)userId
                nickName:(NSString *)nickName
                    word:(Word *)word
                language:(NSInteger)language
                 bgImage:(UIImage *)bgImage
             bgImageName:(NSString*)bgImageName
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    MyPaint* newMyPaint = [dataManager insert:@"MyPaint"];
    [self initMyPaint:newMyPaint
                image:image
             drawData:drawData
               userId:userId
             nickName:nickName
                 word:word
             language:language
              bgImage:bgImage
          bgImageName:bgImageName];
    [newMyPaint setTargetUserId:targetUid];
    [newMyPaint setContestId:contestId];
    [newMyPaint setDraft:[NSNumber numberWithBool:YES]];
    [newMyPaint setDrawWordData:[word data]];
    PPDebug(@"<createDraft> %@", [newMyPaint description]);
    [dataManager save];
    return newMyPaint;    
}

- (MyPaint *)createDraftForRecovery:(NSString *)targetUid
                          contestId:(NSString *)contestId
                             userId:(NSString *)userId
                           nickName:(NSString *)nickName
                               word:(Word *)word
                           language:(NSInteger)language
                        bgImageName:(NSString *)bgImageName
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    MyPaint* newMyPaint = [dataManager insert:@"MyPaint"];
    [self initMyPaint:newMyPaint
                image:nil
 pbNoCompressDrawData:nil
               userId:userId
             nickName:nickName
                 word:word
             language:language
              bgImage:nil];
    [newMyPaint setTargetUserId:targetUid];
    [newMyPaint setContestId:contestId];
    [newMyPaint setDraft:[NSNumber numberWithBool:YES]];
    [newMyPaint setDrawWordData:[word data]];
    [newMyPaint setIsRecovery:[NSNumber numberWithBool:YES]];
    [newMyPaint setBgImageName:bgImageName];
    PPDebug(@"<createDraftForRecovery> %@", [newMyPaint description]);
    [dataManager save];
    return newMyPaint;
}

- (BOOL)updateDraft:(MyPaint *)draft
              image:(UIImage *)image
pbNoCompressDrawData:(PBNoCompressDrawData *)pbNoCompressDrawData
{
    return [self updateDraft:draft image:image drawData:[pbNoCompressDrawData data]];
    
//    BOOL needSave = NO;
//    if (draft) {
//        NSString *imageFileName = [draft image];
//        NSString *pbDataFileName = [draft dataFilePath];
//        //update image
//        if ([imageFileName length] != 0) {
//            [_imageManager saveImage:image forKey:imageFileName];
//        }else{
//            NSString *imageFileName = [self imageFileName];
//            [_imageManager saveImage:image forKey:imageFileName];
//            [draft setImage:imageFileName];
//            needSave = YES;
//        }
//        
//        //update draw data.
//        if ([pbDataFileName length] != 0) {
//            if ([self saveDataAsPBNOCompressDrawData:draft]) {
//                [_drawDataManager saveData:[pbNoCompressDrawData data] forKey:pbDataFileName];
//            }else{
//                //if old data save as action list, remove old data
//                [_drawDataManager removeDataForKey:pbDataFileName];
//                
//                //save and rename path.
//                pbDataFileName = [self pbNoCompressDrawDataFileName];
//                [_drawDataManager saveData:[pbNoCompressDrawData data] forKey:pbDataFileName];
//                [draft setDataFilePath:pbDataFileName];
//                needSave = YES;
//            }
//
//        }else{
//            pbDataFileName = [self pbNoCompressDrawDataFileName];
//            [_drawDataManager saveData:[pbNoCompressDrawData data] forKey:pbDataFileName];
//            [draft setDataFilePath:pbDataFileName];
//            needSave = YES;
//        }
//        
//        if (needSave) {
//            [draft setIsRecovery:[NSNumber numberWithBool:NO]];
//            [self save];            
//        }
//
//    }
//    return YES;
}

- (BOOL)updateDraft:(MyPaint *)draft
              image:(UIImage *)image
           drawData:(NSData *)drawData
{
    BOOL needSave = NO;
    if (draft) {
        NSString *imageFileName = [draft image];
        NSString *pbDataFileName = [draft dataFilePath];
        //update image
        if ([imageFileName length] != 0) {
            [_imageManager saveImage:image forKey:imageFileName];
        }else{
            NSString *imageFileName = [self imageFileName];
            [_imageManager saveImage:image forKey:imageFileName];
            [draft setImage:imageFileName];
            needSave = YES;
        }
        
        //update draw data.
        if ([pbDataFileName length] != 0) {
            if ([self saveDataAsPBNOCompressDrawData:draft]) {
                [_drawDataManager saveData:drawData forKey:pbDataFileName];
            }else{
                //if old data save as action list, remove old data
                [_drawDataManager removeDataForKey:pbDataFileName];
                
                //save and rename path.
                pbDataFileName = [self pbNoCompressDrawDataFileName];
                [_drawDataManager saveData:drawData forKey:pbDataFileName];
                [draft setDataFilePath:pbDataFileName];
                needSave = YES;
            }
            
        }else{
            pbDataFileName = [self pbNoCompressDrawDataFileName];
            [_drawDataManager saveData:drawData forKey:pbDataFileName];
            [draft setDataFilePath:pbDataFileName];
            needSave = YES;
        }
        
        if (needSave) {
            [draft setIsRecovery:[NSNumber numberWithBool:NO]];
            [self save];
        }
        
    }
    return YES;
}


- (NSMutableArray *)drawActionListForPaint:(MyPaint *)paint
{
    NSData *drawData = nil;
    if ([paint.dataFilePath length] != 0) {
        //save file data
        if ([self saveDataAsPBNOCompressDrawData:paint]) {
            
            drawData = [_drawDataManager dataForKey:paint.dataFilePath];
            
            // refactor by using C lib
            Game__PBNoCompressDrawData* nDrawC = NULL;
            int dataLen = [drawData length];
            if (dataLen == 0)
                return nil;
            
            uint8_t* buf = malloc(dataLen);
            if (buf == NULL)
                return nil;
            
            // TODO PBDRAWC to be optimized since this will duplicate data , double size of memory
            [drawData getBytes:buf length:dataLen];
            nDrawC = game__pbno_compress_draw_data__unpack(NULL, dataLen, buf);
            free(buf);
            
            if (nDrawC == NULL)
                return nil;
            
            paint.drawDataVersion = nDrawC->version;
            if (nDrawC->opusdesc != NULL) {
                paint.opusDesc = [NSString stringWithUTF8String:nDrawC->opusdesc];
            }
            
            if (nDrawC->canvassize == NULL) {
                paint.canvasSize = [CanvasRect deprecatedRect].size;                
            }else{
                paint.canvasSize = CGSizeFromPBSizeC(nDrawC->canvassize);
            }
            
            if (nDrawC->bgimagename != NULL) {
                paint.bgImageName = [NSString stringWithUTF8String:nDrawC->bgimagename];
            }
            
            NSMutableArray* list = [DrawAction pbNoCompressDrawDataCToDrawActionList:nDrawC
                                                                          canvasSize:paint.canvasSize];
            game__pbno_compress_draw_data__free_unpacked(nDrawC, NULL);
            
            return list;
            
            // old implementation, keep here for later check
//            drawData = [_drawDataManager dataForKey:paint.dataFilePath];
//            PBNoCompressDrawData *nDraw = [PBNoCompressDrawData parseFromData:drawData];
//            paint.drawDataVersion = nDraw.version;
//            if ([nDraw hasOpusDesc]) {
//                paint.opusDesc = nDraw.opusDesc;
//            }
//            if (![nDraw hasCanvasSize]) {
//                
//                paint.canvasSize = [CanvasRect deprecatedRect].size;
//
//            }else{
//                paint.canvasSize = CGSizeFromPBSize(nDraw.canvasSize);
//            }
//            
//            if ([nDraw hasBgImageName]) {
//                paint.bgImageName = nDraw.bgImageName;
//            }
//            
//            return [DrawAction pbNoCompressDrawDataToDrawActionList:nDraw canvasSize:paint.canvasSize];
        }else if ([self saveDataAsPBDraw:paint]) {
                                    
            drawData = [_drawDataManager dataForKey:paint.dataFilePath];
            // refactor by using C lib
            Game__PBDraw* pbDrawC = NULL;
            int dataLen = [drawData length];
            if (dataLen > 0){
                uint8_t* buf = malloc(dataLen);
                if (buf != NULL){
                    
                    // TODO PBDRAWC to be optimized since this will duplicate data , double size of memory
                    [drawData getBytes:buf length:dataLen];
                    pbDrawC = game__pbdraw__unpack(NULL, dataLen, buf);
                    free(buf);
                    
                    Draw* draw = [[[Draw alloc] initWithPBDrawC:pbDrawC] autorelease];
                    
                    paint.drawDataVersion = pbDrawC->version;
                    if (pbDrawC->canvassize == NULL) {
                        if (paint.draft.intValue == 1) {
                            paint.canvasSize = [CanvasRect deprecatedRect].size;
                        }else{
                            paint.canvasSize = [CanvasRect deprecatedIPhoneRect].size;
                        }
                        
                    }else{
                        paint.canvasSize = CGSizeFromPBSizeC(pbDrawC->canvassize);
                    }
                    
                    game__pbdraw__free_unpacked(pbDrawC, NULL);                    
                    return draw.drawActionList;
                    
                }
            }
                        
            // old implementation, keep here for later check
//            drawData = [_drawDataManager dataForKey:paint.dataFilePath];
//            PBDraw *pbDraw = [PBDraw parseFromData:drawData];
//            paint.drawDataVersion = pbDraw.version;
//            if (![pbDraw hasCanvasSize]) {
//                // paint.canvasSize = [CanvasRect deprecatedRect].size;
//                if (paint.draft.intValue == 1) {
//                    paint.canvasSize = [CanvasRect deprecatedRect].size;
//                }else{
//                    paint.canvasSize = [CanvasRect deprecatedIPhoneRect].size;
//                }
//
//            }else{
//                paint.canvasSize = CGSizeFromPBSize(pbDraw.canvasSize);
//            }
//
//            Draw *draw = [[[Draw alloc] initWithPBDraw:pbDraw] autorelease];
//            return draw.drawActionList;
        }else{
            NSString *fullPath = [_drawDataManager pathWithKey:paint.dataFilePath];
            drawData = [NSData dataWithContentsOfFile:fullPath];
        }
    }else{
        drawData = paint.data;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:drawData];
}

- (NSString*)fullDataPath:(NSString*)dataFileName
{
    if (dataFileName == nil)
        return nil;
    
    return [_drawDataManager pathWithKey:dataFileName];
}

- (NSString *)imagePathForPaint:(MyPaint *)paint
{
    NSString *path = [_imageManager pathWithKey:paint.image];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return path;
    }else{
        NSString* imageName = [FileUtil getFileNameByFullPath:paint.image];
        NSString* imagePath = [FileUtil getFileFullPath:imageName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
            return imagePath;
        }
    }
    return nil;
}

- (UIImage *)bgImageForPaint:(MyPaint *)paint
{
    return [_bgImgeManager imageForKey:paint.bgImageName];
}

- (void)saveBgImage:(UIImage *)image name:(NSString *)name;
{
    if (name && image) {
        [_bgImgeManager saveImage:image forKey:name];
        PPDebug(@"bgImagePath:%@", [_imageManager pathWithKey:name]);
    }
}

@end
