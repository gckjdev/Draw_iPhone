//
//  MyPaintManager.m
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyPaintManager.h"
#import "CoreDataUtil.h"
//#import "MyPaint.h"
#import "PPDebug.h"
#import "FileUtil.h"
#import "UserManager.h"
#import "StringUtil.h"

#define MY_PAINT_IMAGE_DIR @"Paints"
#define MY_PAINT_DATA_DIR @"PaintData"

#define SUFFIX_NUMBER 100
@interface MyPaintManager()
{
    long _dataPathSuffixIndex;
}
- (void)deletePaintImage:(NSString *)paintImage sync:(BOOL)sync;
- (void)deletePaintData:(NSString *)path;
- (void)transferDrawDataToPath:(NSArray *)paints;
@end


@implementation MyPaintManager

static MyPaintManager* _defaultManager;

- (id)init
{
    self = [super init];
    _dataPathSuffixIndex = 0;
    return self;
}

+ (MyPaintManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[MyPaintManager alloc] init];
    }
    
    return _defaultManager;
}

- (NSString *)saveDrawData:(NSData *)data
{
    ;
    NSString* fileName = [NSString stringWithFormat:@"%@.dat", [NSString GetUUID]];
    NSString *path = [MyPaintManager constructDataPath:fileName];
    PPDebug(@"data save to path = %@", path);
    [data writeToFile:path atomically:YES];
    return fileName;
}

- (BOOL)createMyPaintWithImage:(NSString*)image
                          data:(NSData*)data
                    drawUserId:(NSString*)drawUserId
              drawUserNickName:(NSString*)drawUserNickName
                      drawByMe:(BOOL)drawByMe
                      drawWord:(NSString*)drawWord

{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    MyPaint* newMyPaint = [dataManager insert:@"MyPaint"];
    NSString *path = [self saveDrawData:data];
    [newMyPaint setDataFilePath:path];

    //    [newMyPaint setData:data];
    
    //save the data, and set the data path.
    [newMyPaint setImage:image];
    [newMyPaint setDrawByMe:[NSNumber numberWithBool:drawByMe]];
    [newMyPaint setDrawUserId:drawUserId];
    [newMyPaint setDrawUserNickName:drawUserNickName];
    [newMyPaint setCreateDate:[NSDate date]];
    [newMyPaint setDrawWord:drawWord];
    
    PPDebug(@"<createMyPaintWithImage> %@", [newMyPaint description]);
    BOOL result = [dataManager save];
    return result;
}


- (NSString *)writeImage:(UIImage *)image
{
    int aTime = time(0);
    NSString* imageName = [NSString stringWithFormat:@"%d.png", aTime];
    NSString *uniquePath=[MyPaintManager constructImagePath:imageName];
    NSData* imageData = UIImagePNGRepresentation(image);
    
    //save image
    BOOL result=[imageData writeToFile:uniquePath atomically:YES];
    if (result) {
        PPDebug(@"<writeImage> save image to path:%@ result:%d , canRead:%d", uniquePath, result, [[NSFileManager defaultManager] fileExistsAtPath:uniquePath]);        
        return imageName;
    }
    return nil;
}

- (BOOL)updateDraft:(MyPaint *)draft 
              image:(UIImage *)image
               data:(NSMutableArray*)drawActionList
{
    NSString *imageName = [self writeImage:image];
    if (imageName) {
        if (![imageName isEqualToString:draft.image]) {
//            NSLog(@"<updateDraft> delete old image");
            [self deletePaintImage:draft.image sync:YES];            
        }
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:drawActionList];
        NSString *path = [MyPaintManager constructDataPath:draft.dataFilePath];
        [data writeToFile:path atomically:YES];
        draft.image = imageName;
        CoreDataManager* dataManager = GlobalGetCoreDataManager();
//        NSLog(@"<update draft> before save, draft = %@",draft);
        return [dataManager save];        
    }

    return NO;
    
//    NSString *olodPath = 
}



- (MyPaint *)createDraft:(UIImage *)image
                    data:(NSMutableArray*)drawActionList 
                language:(LanguageType)language
                drawWord:(NSString*)drawWord 
                   level:(WordLevel)level
               targetUid:(NSString *)targetUid

{
    
//    NSLog(@"<Draw Log>createDraft");
    
    NSString *imageName = [self writeImage:image];
    if (imageName) {
        //create the drawlist data.
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:drawActionList];

        CoreDataManager* dataManager = GlobalGetCoreDataManager();
        
        MyPaint* newMyPaint = [dataManager insert:@"MyPaint"];
        
//        [newMyPaint setData:data];
        NSString *path = [self saveDrawData:data];
        [newMyPaint setDataFilePath:path];

        [newMyPaint setImage:imageName];
        [newMyPaint setDrawByMe:[NSNumber numberWithBool:YES]];
        [newMyPaint setDraft:[NSNumber numberWithBool:YES]];
        [newMyPaint setDrawUserId:[[UserManager defaultManager] userId]];
        [newMyPaint setDrawUserNickName:[[UserManager defaultManager] nickName]];
        [newMyPaint setCreateDate:[NSDate date]];
        [newMyPaint setDrawWord:drawWord];
        [newMyPaint setTargetUserId:targetUid];
        
        [newMyPaint setLanguage:[NSNumber numberWithInt:language]];
        [newMyPaint setLevel:[NSNumber numberWithInt:level]];
        
        PPDebug(@"<createDraftWithImage> %@", [newMyPaint description]);
        
        BOOL result = [dataManager save];
        
            
        if (result) {
            return newMyPaint;
        }else{
            return nil;
        }
    }
    return nil;
}

- (MyPaint *)latestDraft
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    NSArray *array = [dataManager execute:@"findAllDrafts" sortBy:@"createDate" returnFields:nil ascending:NO offset:0 limit:1];
    if ([array count] == 0) {
        return nil;
    }
    return [array objectAtIndex:0];
}


- (NSArray *)fetchFields
{
    NSArray *array = [NSArray arrayWithObjects:@"createDate", @"image", @"drawByMe", @"drawUserNickName", @"drawUserId", @"drawWord", @"drawThumbnailData", nil];
    return array;
}


- (void)transferDrawDataToPath:(NSArray *)paints
{
    PPDebug(@"<transferDrawDataToPath> start");
    BOOL needSave = NO;
    for (MyPaint *paint in paints) {
        if (paint.data) {
            if ([paint.dataFilePath length] != 0) {
                [self deletePaintData:paint.dataFilePath];
            }
            NSString *path = [self saveDrawData:paint.data];
            paint.dataFilePath = path;
            paint.data = nil;
            needSave = YES;
            PPDebug(@"<transferDrawDataToPath> transfer path = %@", path);
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
    dispatch_queue_t queue = dispatch_get_main_queue(); //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (queue) {
        dispatch_async(queue, ^{
            NSArray *array = [dataManager execute:@"findOnlyMyPaints" sortBy:@"createDate" returnFields:nil ascending:NO offset:offset limit:limit];
            [self transferDrawDataToPath:array];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (delegate && [delegate respondsToSelector:@selector(didGetMyPaints:)]) {
                    [delegate didGetMyPaints:array];
                } 
            });
        });        
    }
    
}

- (void)findAllPaintsFrom:(NSInteger)offset 
                        limit:(NSInteger)limit 
                     delegate:(id<MyPaintManagerDelegate>)delegate
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    dispatch_queue_t queue = dispatch_get_main_queue(); //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (queue) {
        dispatch_async(queue, ^{
//            PPDebug(@"before find");
            NSArray *array = [dataManager execute:@"findAllMyPaints" sortBy:@"createDate" returnFields:nil ascending:NO offset:offset limit:limit];
//            PPDebug(@"after find");
            [self transferDrawDataToPath:array];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (delegate && [delegate respondsToSelector:@selector(didGetAllPaints:)]) {
                    [delegate didGetAllPaints:array];
                } 
            });
        });        
    }

}

- (void)findAllDraftsFrom:(NSInteger)offset 
                    limit:(NSInteger)limit 
                 delegate:(id<MyPaintManagerDelegate>)delegate
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    dispatch_queue_t queue = dispatch_get_main_queue(); //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (queue) {
        dispatch_async(queue, ^{
            NSArray *array = [dataManager execute:@"findAllDrafts" sortBy:@"createDate" returnFields:nil ascending:NO offset:offset limit:limit];
            [self transferDrawDataToPath:array];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (delegate && [delegate respondsToSelector:@selector(didGetAllDrafts:)]) {
                    [delegate didGetAllDrafts:array];
                } 
            });
        });        
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
            
            //remove the image path.
            [self deletePaintImage:paint.image sync:YES];
            
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
    NSString *dataPath = [MyPaintManager constructDataPath:path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:dataPath error:nil];
        PPDebug(@"<deleteMyPaints> remove image at %@", dataPath);
    }            
}

- (void)deletePaintImage:(NSString *)paintImage sync:(BOOL)sync
{
    dispatch_block_t block = ^{
        @try {
            NSString* image = [NSString stringWithString:[MyPaintManager getMyPaintImagePathByCapacityPath:paintImage]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:image]) {
                [[NSFileManager defaultManager] removeItemAtPath:image error:nil];
                PPDebug(@"<deleteMyPaints> remove image at %@", image);
            }        
        }
        @catch (NSException *exception) {
//            NSLog(@"<deletePaintImage> caught Exception: %@, reason: %@",[exception description],[exception reason]);
        }
        @finally {
            
        }    
    };
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (!sync && queue != NULL){
        dispatch_async(queue, block);
    }else{
        @try {
            NSString* image = [NSString stringWithString:[MyPaintManager getMyPaintImagePathByCapacityPath:paintImage]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:image]) {
                [[NSFileManager defaultManager] removeItemAtPath:image error:nil];
                PPDebug(@"<deleteMyPaints> remove image at %@", image);
            }        
        }
        @catch (NSException *exception) {
//            NSLog(@"<deletePaintImage> caught Exception: %@, reason: %@",[exception description],[exception reason]);
        }
        @finally {
            
        }
    }
}

- (BOOL)deleteMyPaint:(MyPaint*)paint
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    [paint setDeleteFlag:[NSNumber numberWithBool:YES]];
//    NSLog(@"<deleteMyPaint> before save");
    BOOL result = [dataManager save];
    
    return result;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    PPDebug(@"Save Photo, Result=%@", [error description]);
}

- (void)savePhoto:(NSString*)filePath
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
        [image release];    
    });
}

+ (NSString *)constructImagePath:(NSString *)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    if (!paths || [paths count] == 0) {
        return nil;
    }
    NSString *imgName = imageName;
    NSString *dir = [paths objectAtIndex:0];
    
    dir = [dir stringByAppendingPathComponent:MY_PAINT_IMAGE_DIR];
    BOOL flag = [FileUtil createDir:dir];
    if (flag == NO) {
        PPDebug(@"<MyPaintManager> create dir fail. dir = %@",dir);
    }
    NSString *uniquePath=[dir stringByAppendingPathComponent:imgName];
    return uniquePath;
}

+ (NSString *)constructDataPath:(NSString *)dataName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    if (!paths || [paths count] == 0) {
        return nil;
    }
    NSString *dir = [paths objectAtIndex:0];
    
    dir = [dir stringByAppendingPathComponent:MY_PAINT_DATA_DIR];
    BOOL flag = [FileUtil createDir:dir];
    if (flag == NO) {
        PPDebug(@"<MyPaintManager> create dir fail. dir = %@",dir);
    }
    NSString *uniquePath=[dir stringByAppendingPathComponent:dataName];
    return uniquePath;
}

+ (NSData *)drawDataFromDataPath:(NSString *)path
{
    NSString *dataPath = [MyPaintManager constructDataPath:path];
    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    return data;
}


+ (NSString*)getMyPaintImageDirection
{
    NSString* homePath = [FileUtil getAppHomeDir];
    return [NSString stringWithFormat:@"%@/Paints",homePath];
}

+ (NSString*)getMyPaintImagePathByCapacityPath:(NSString *)path
{
    NSString* homePath = [FileUtil getAppHomeDir];
    NSString* imageName = [FileUtil getFileNameByFullPath:path];
    NSString* imagePath = [NSString stringWithFormat:@"%@/%@",homePath, imageName];
    NSString* newImagePath = [MyPaintManager constructImagePath:imageName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:newImagePath]) {
        return newImagePath;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        return imagePath;
    }
    return nil;
}
- (BOOL)save
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    return [dataManager save];    
}
@end
