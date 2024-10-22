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
#import "UIImageUtil.h"
#import "StringUtil.h"
#import "DrawBgManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

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
#define THUMB_IMAGE_SUFFIX @"_m.png"

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
        _bgImageManager = [[DrawBgManager defaultManager] imageManager];
        //[[StorageManager alloc] initWithStoreType:StorageTypePersistent directoryName:PAINT_BG_IMAGE_DIR];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_imageManager);
    PPRelease(_drawDataManager);
    PPRelease(_bgImageManager);
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
        [self save];
    }
    PPDebug(@"<transferDrawDataToPath> end");
}

- (void)addDraftId:(NSArray*)paintList
{
    BOOL hasDraftIdAdded = NO;
    for (MyPaint* paint in paintList){
        if ([paint.draftId length] == 0){
            hasDraftIdAdded = YES;
            NSString* draftId = [NSString GetUUID];
            [paint setDraftId:draftId];
            PPDebug(@"<addDraftId> %@ for paint %@", draftId, paint.drawWord);
        }
    }

    if (hasDraftIdAdded){
        [self save];
    }
}

- (MyPaint*)findDraftById:(NSString*)draftId
{
    if ([draftId length] == 0){
        return nil;
    }
    
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    MyPaint* draft = (MyPaint*)[dataManager execute:@"findMyPaintByDraftId" forKey:@"DRAFT_ID" value:draftId];
    return draft;
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

- (int)countAllDrafts
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    NSArray *draftArray = [dataManager execute:@"findAllDrafts" sortBy:@"createDate" returnFields:nil ascending:NO offset:0 limit:HUGE_VAL];

    return [draftArray count];
}

- (void)removeAllDraft
{
    PPDebug(@"removeAllDraftPaints");

    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    NSArray *draftArray = [dataManager execute:@"findAllDrafts" sortBy:@"createDate" returnFields:nil ascending:NO offset:0 limit:HUGE_VAL];

    @try {
        for (MyPaint* paint in draftArray){
            [paint setDeleteFlag:[NSNumber numberWithBool:YES]];
            
            //delete image
            [FileUtil removeFile:paint.imageFilePath];
            
            //delete thumb
            
            [FileUtil removeFile:[self thumbPathFromImagePath:paint.imageFilePath]];
            
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
            
            //delete thumb
            
            [FileUtil removeFile:[self thumbPathFromImagePath:paint.imageFilePath]];
            
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
        [_bgImageManager removeDataForKey:imageName];
    }
}

- (BOOL)deleteMyPaint:(MyPaint*)paint
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    [paint setDeleteFlag:[NSNumber numberWithBool:YES]];
    BOOL result = [dataManager save];
    
    return result;
}

- (BOOL)completeDeletePaint:(MyPaint*)paint
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    [dataManager del:paint];
    [self deleteBgImage:paint.bgImageName];
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
    
//    dispatch_async(queue, ^{
//        UIImage* image = [[UIImage alloc] initWithContentsOfFile:filePath];
        _savePhotoToAlbumDelegate = delegate;

        
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data){
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeImageDataToSavedPhotosAlbum:data
                                             metadata:nil
                                      completionBlock:^(NSURL *assetURL, NSError *error) {
                                          
                                          [self image:nil didFinishSavingWithError:error contextInfo:nil];
                                      }
             ];
            [library release];
        }
        else{
            [self image:nil didFinishSavingWithError:[NSError errorWithDomain:@"" code:-1 userInfo:nil] contextInfo:nil];
        }
    
//        UIImageWriteToSavedPhotosAlbum(image,
//                                       self,
//                                       @selector(image:didFinishSavingWithError:contextInfo:),
//                                       nil);
//        [image release];
//    });
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
{
    NSString *imageFileName = [self imageFileName];
    NSString *pbDataFileName = [self pbDataFileName];
    
    [_imageManager saveImage:image forKey:imageFileName];
    [_drawDataManager saveData:pbDrawData forKey:pbDataFileName];
    
    [newMyPaint setDataFilePath:pbDataFileName];
    [newMyPaint setImage:imageFileName];
    
    BOOL drawByMe = [[UserManager defaultManager] isMe:feed.feedUser.userId];
    
    [newMyPaint setDrawByMe:[NSNumber numberWithBool:drawByMe]];
    [newMyPaint setDrawUserId:feed.feedUser.userId];
    [newMyPaint setDrawUserNickName:feed.feedUser.nickName];
    [newMyPaint setDrawWord:feed.wordText];
    [newMyPaint setCreateDate:[NSDate date]];
    [newMyPaint setLanguage:[NSNumber numberWithInt:ChineseType]];      // hard code here, some risk?
    [newMyPaint setLevel:[NSNumber numberWithInt:1]];                   // hard code here, some risk?

    [newMyPaint setOpusId:feed.feedId];
    [newMyPaint setTotalStrokes:@(feed.pbFeed.strokes)];
    [newMyPaint setOpusSpendTime:@(feed.pbFeed.spendTime)];
    
    [newMyPaint setDraftId:[NSString GetUUID]];

}

- (void)initMyPaint:(MyPaint *)newMyPaint
              image:(UIImage*)image
             pbDraw:(PBDraw*)pbDraw
{
    NSString *imageFileName = [self imageFileName];
    NSString *pbDataFileName = [self pbDataFileName];
    
    [_imageManager saveImage:image forKey:imageFileName];
    [self saveImageAsThumb:image path:[self thumbPathFromImagePath:imageFileName]];
    
    [_drawDataManager saveData:[pbDraw data] forKey:pbDataFileName];
    
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
    
    [newMyPaint setDraftId:[NSString GetUUID]];

}

- (void)initMyPaint:(MyPaint *)newMyPaint
              image:(UIImage*)image
         pbDrawData:(NSData*)pbDrawData
               word:(NSString*)word
{
    NSString *imageFileName = [self imageFileName];
    NSString *pbDataFileName = [self pbDataFileName];
    
    [_imageManager saveImage:image forKey:imageFileName];
    [self saveImageAsThumb:image path:[self thumbPathFromImagePath:imageFileName]];
    
    [_drawDataManager saveData:pbDrawData forKey:pbDataFileName];
    
    
    [newMyPaint setDataFilePath:pbDataFileName];
    [newMyPaint setImage:imageFileName];
    
    BOOL drawByMe = YES; //[[UserManager defaultManager] isMe:pbDraw.userId];
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* nickName = [[UserManager defaultManager] nickName];
    int language = [[UserManager defaultManager] getLanguageType];
    int level = WordLeveLMedium;
    
    [newMyPaint setDrawByMe:[NSNumber numberWithBool:drawByMe]];
    [newMyPaint setDrawUserId:userId];
    [newMyPaint setDrawUserNickName:nickName];
    [newMyPaint setCreateDate:[NSDate date]];
    [newMyPaint setDrawWord:word];
    
    // hard code here, some risk?
    [newMyPaint setLanguage:@(language)];
    
    [newMyPaint setDraftId:[NSString GetUUID]];
    
    // hard code here, some risk?
    [newMyPaint setLevel:@(level)];
    
    [newMyPaint setDraftId:[NSString GetUUID]];

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
        [self saveImageAsThumb:image path:[self thumbPathFromImagePath:imageFileName]];
    }
    
    if (drawData != nil){
        [_drawDataManager saveData:drawData forKey:pbDataFileName];
    }
    
    if (bgImage != nil) {
        [_bgImageManager saveImage:bgImage forKey:bgImageName];
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
    
    [newMyPaint setDraftId:[NSString GetUUID]];

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
}

- (BOOL)createMyPaintWithImage:(UIImage*)image
                    pbDrawData:(NSData*)pbDrawData
                          feed:(DrawFeed*)feed
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

- (MyPaint*)createDraftPaintWithImage:(UIImage*)image
                       pbDrawData:(NSData*)pbDrawData
                             feed:(DrawFeed*)feed
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    MyPaint* newMyPaint = [dataManager insert:@"MyPaint"];
    
    [self initMyPaint:newMyPaint
                image:image
           pbDrawData:pbDrawData
                 feed:feed];
    
    [newMyPaint setDraft:@(1)];
    PPDebug(@"<createDraftPaintWithImage> %@", [newMyPaint description]);
    return newMyPaint;
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

- (BOOL)createMyPaintWithImage:(UIImage*)image
                    pbDrawData:(NSData*)pbDrawData
                          word:(NSString*)word
                        opusId:(NSString*)opusId
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    MyPaint* newMyPaint = [dataManager insert:@"MyPaint"];
    
    [self initMyPaint:newMyPaint
                image:image
           pbDrawData:pbDrawData
                 word:word];
    
    [newMyPaint setOpusId:opusId];
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
              deleteFlag:(BOOL)deleteFlag
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
    [newMyPaint setDeleteFlag:@(deleteFlag)];
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
                               desc:(NSString*)desc
                            strokes:(int64_t)strokes
                          spendTime:(int)spendTime
                       completeDate:(int)completeDate
                         targetType:(int)targetType

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
    [newMyPaint setOpusDesc:desc];
    [newMyPaint setOpusSpendTime:@(spendTime)];
    [newMyPaint setTotalStrokes:@(strokes)];
    [newMyPaint setTargetType:@(targetType)];
    if (completeDate){
        [newMyPaint setOpusCompleteDate:[NSDate dateWithTimeIntervalSince1970:completeDate]];
    }
    
    PPDebug(@"<createDraftForRecovery> %@", [newMyPaint description]);
    [dataManager save];
    return newMyPaint;
}

- (NSString *)thumbPathFromImagePath:(NSString *)imagePath
{
    NSString *path = imagePath;
    if ([path length] != 0) {
        if ([path hasSuffix:IMAGE_SUFFIX]) {
            path = [path substringToIndex:path.length - IMAGE_SUFFIX.length];
//            path = [path stringByAppendingString:THUMB_IMAGE_SUFFIX];
        }
        path = [path stringByAppendingString:THUMB_IMAGE_SUFFIX];
    }
    return path;

}

- (BOOL)updateDraft:(MyPaint *)draft
              image:(UIImage *)image
           drawData:(NSData *)drawData
          forceSave:(BOOL)forceSave
{
    if ([drawData length] <= 0){
        PPDebug(@"<updateDraft> but draw data length is 0 or nil???");
        return NO;
    }
    
    BOOL needSave = YES;  // set to always yes here by Benson 2013-10-08
    if (draft) {
        NSString *imageFileName = [draft image];
        NSString *pbDataFileName = [draft dataFilePath];
        //update image
        if ([imageFileName length] != 0) {
            [_imageManager saveImage:image forKey:imageFileName];
        }else{
            imageFileName = [self imageFileName];
            [_imageManager saveImage:image forKey:imageFileName];
            [draft setImage:imageFileName];
            needSave = YES;
        }
        
        [self saveImageAsThumb:image path:[self thumbPathFromImagePath:imageFileName]];
        
        //update draw data.
        if ([pbDataFileName length] != 0) {
            if ([self saveDataAsPBNOCompressDrawData:draft]) {
                [_drawDataManager saveData:drawData forKey:pbDataFileName];
//                needSave = YES;
            }else{
                //if old data save as action list, remove old data
                [_drawDataManager removeDataForKey:pbDataFileName];
                
                //save and rename path.
                pbDataFileName = [self pbNoCompressDrawDataFileName];
                [_drawDataManager saveData:drawData forKey:pbDataFileName];
                [draft setDataFilePath:pbDataFileName];
//                needSave = YES;
            }
            
        }else{
            pbDataFileName = [self pbNoCompressDrawDataFileName];
            [_drawDataManager saveData:drawData forKey:pbDataFileName];
            [draft setDataFilePath:pbDataFileName];
//            needSave = YES;
        }
        
        if (needSave||forceSave) {
            [draft setIsRecovery:[NSNumber numberWithBool:NO]];
            return [self save];
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
            
            paint.layers = [DrawLayer layersFromPBLayers:nDrawC->layer number:nDrawC->n_layer];

            //create layer for old datas
            if (paint.layers == nil) {
                paint.layers = [DrawLayer defaultOldLayersWithFrame:CGRectFromCGSize(paint.canvasSize)];
            }

            // set strokes, spend time, and complete date while they doesn't exist in draft model (added by Benson, 2014-05-22)
            if (nDrawC->strokes > 0 && [paint.totalStrokes intValue] == 0){
                paint.totalStrokes = @(nDrawC->strokes);
            }
            
            if (nDrawC->spendtime > 0 && [paint.opusSpendTime intValue] == 0){
                paint.opusSpendTime = @(nDrawC->spendtime);
            }
            
            if (nDrawC->completedate > 0 && paint.opusCompleteDate == nil){
                paint.opusCompleteDate = [NSDate dateWithTimeIntervalSince1970:nDrawC->completedate];
            }
            
            NSMutableArray* list = [DrawAction pbNoCompressDrawDataCToDrawActionList:nDrawC
                                                                          canvasSize:paint.canvasSize];
            game__pbno_compress_draw_data__free_unpacked(nDrawC, NULL);
            
            return list;
            
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
                    
                    // set version
                    paint.drawDataVersion = pbDrawC->version;
                    
                    // set strokes, spend time, and complete date (added by Benson, 2014-05-22)
                    [paint setTotalStrokes:@(pbDrawC->strokes)];
                    [paint setOpusSpendTime:@(pbDrawC->spendtime)];
                    [paint setOpusCompleteDate:[NSDate dateWithTimeIntervalSince1970:pbDrawC->completedate]];
                    
                    // set canvas size
                    if (pbDrawC->canvassize == NULL) {
                        if (paint.draft.intValue == 1) {
                            paint.canvasSize = [CanvasRect deprecatedRect].size;
                        }else{
                            paint.canvasSize = [CanvasRect deprecatedIPhoneRect].size;
                        }
                        
                    }else{
                        paint.canvasSize = CGSizeFromPBSizeC(pbDrawC->canvassize);
                    }
                    
                    // set layer info
                    paint.layers = [DrawLayer layersFromPBLayers:pbDrawC->layer number:pbDrawC->n_layer];
                    
                    //create layer for old datas
                    if (paint.layers == nil) {
                        paint.layers = [DrawLayer defaultOldLayersWithFrame:CGRectFromCGSize(paint.canvasSize)];
                    }

                    game__pbdraw__free_unpacked(pbDrawC, NULL);                    
                    return draw.drawActionList;
                    
                }
            }
            
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

#define MAX_SIZE 150.0

- (UIImage *)saveImageAsThumb:(UIImage *)largeImage path:(NSString *)path
{
    NSString *key = [FileUtil getFileNameByFullPath:path];
    CGSize size = largeImage.size;
    CGFloat r = MIN(size.width, size.height) / MAX_SIZE;
    size = CGSizeMake(size.width / r, size.height / r);
    UIImage *thumb = [largeImage imageByScalingAndCroppingForSize:size];
    [_imageManager saveImage:thumb forKey:key];
    PPDebug(@"<saveImageAsThumb> path = %@", path);
    return thumb;
}


- (UIImage *)bgImageForPaint:(MyPaint *)paint
{
    return [_bgImageManager imageForKey:paint.bgImageName];
}

- (NSString *)bgImageFullPath:(MyPaint *)paint
{
    return [_bgImageManager pathWithKey:paint.bgImageName];
}

- (void)saveBgImage:(UIImage *)image name:(NSString *)name;
{
    if (name && image) {
        [_bgImageManager saveImage:image forKey:name];
        PPDebug(@"bgImagePath:%@", [_imageManager pathWithKey:name]);
    }
}

@end
