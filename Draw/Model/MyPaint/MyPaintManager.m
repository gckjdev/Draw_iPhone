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
        
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_imageManager);
    PPRelease(_drawDataManager);
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
         pbDrawData:(PBDraw*)pbDrawData
{
    NSString *imageFileName = [self imageFileName];
    NSString *pbDataFileName = [self pbDataFileName];
    
    [_imageManager saveImage:image forKey:imageFileName];
    [_drawDataManager saveData:[pbDrawData data] forKey:pbDataFileName];
    
    
    [newMyPaint setDataFilePath:pbDataFileName];
    [newMyPaint setImage:imageFileName];
    
    BOOL drawByMe = [[UserManager defaultManager] isMe:pbDrawData.userId];
    
    [newMyPaint setDrawByMe:[NSNumber numberWithBool:drawByMe]];
    [newMyPaint setDrawUserId:pbDrawData.userId];
    [newMyPaint setDrawUserNickName:pbDrawData.nickName];
    [newMyPaint setCreateDate:[NSDate date]];
    [newMyPaint setDrawWord:pbDrawData.word];

    [newMyPaint setLanguage:[NSNumber numberWithInt:pbDrawData.language]];
    [newMyPaint setLevel:[NSNumber numberWithInt:pbDrawData.level]];

}

- (void)initMyPaint:(MyPaint *)newMyPaint
              image:(UIImage*)image
pbNoCompressDrawData:(PBNoCompressDrawData*)pbNoCompressDrawData
             userId:(NSString *)userId
           nickName:(NSString *)nickName
               word:(Word *)word
           language:(NSInteger)language

{
    NSString *imageFileName = [self imageFileName];
    NSString *pbDataFileName = [self pbNoCompressDrawDataFileName];
    
    if (image != nil){
        [_imageManager saveImage:image forKey:imageFileName];
    }
    
    if (pbNoCompressDrawData != nil){
        [_drawDataManager saveData:[pbNoCompressDrawData data] forKey:pbDataFileName];
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
}

- (BOOL)createMyPaintWithImage:(UIImage*)image
                    pbDrawData:(PBDraw*)pbDrawData 
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    MyPaint* newMyPaint = [dataManager insert:@"MyPaint"];
    
    [self initMyPaint:newMyPaint image:image pbDrawData:pbDrawData];
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
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    MyPaint* newMyPaint = [dataManager insert:@"MyPaint"];
    [self initMyPaint:newMyPaint
                image:image
 pbNoCompressDrawData:pbNoCompressDrawData
               userId:userId
             nickName:nickName
                 word:word
             language:language];
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
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    MyPaint* newMyPaint = [dataManager insert:@"MyPaint"];
    [self initMyPaint:newMyPaint
                image:nil
 pbNoCompressDrawData:nil
               userId:userId
             nickName:nickName
                 word:word
             language:language];
    [newMyPaint setTargetUserId:targetUid];
    [newMyPaint setContestId:contestId];
    [newMyPaint setDraft:[NSNumber numberWithBool:YES]];
    [newMyPaint setDrawWordData:[word data]];
    [newMyPaint setIsRecovery:[NSNumber numberWithBool:YES]];
    PPDebug(@"<createDraftForRecovery> %@", [newMyPaint description]);
    [dataManager save];
    return newMyPaint;
}

- (BOOL)updateDraft:(MyPaint *)draft
              image:(UIImage *)image
    pbNoCompressDrawData:(PBNoCompressDrawData *)pbNoCompressDrawData
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
                [_drawDataManager saveData:[pbNoCompressDrawData data] forKey:pbDataFileName];
            }else{
                //if old data save as action list, remove old data
                [_drawDataManager removeDataForKey:pbDataFileName];
                
                //save and rename path.
                pbDataFileName = [self pbNoCompressDrawDataFileName];
                [_drawDataManager saveData:[pbNoCompressDrawData data] forKey:pbDataFileName];
                [draft setDataFilePath:pbDataFileName];
                needSave = YES;
            }

        }else{
            pbDataFileName = [self pbNoCompressDrawDataFileName];
            [_drawDataManager saveData:[pbNoCompressDrawData data] forKey:pbDataFileName];
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
            PBNoCompressDrawData *nDraw = [PBNoCompressDrawData parseFromData:drawData];
            paint.drawDataVersion = nDraw.version;
            paint.drawBg = nDraw.drawBg;
            return [DrawAction pbNoCompressDrawDataToDrawActionList:nDraw];
        }else if ([self saveDataAsPBDraw:paint]) {
            drawData = [_drawDataManager dataForKey:paint.dataFilePath];
            PBDraw *pbDraw = [PBDraw parseFromData:drawData];
            paint.drawDataVersion = pbDraw.version;
            Draw *draw = [[[Draw alloc] initWithPBDraw:pbDraw] autorelease];
            return draw.drawActionList;
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
@end
