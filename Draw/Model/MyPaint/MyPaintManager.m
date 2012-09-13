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

#define MY_PAINT_IMAGE_DIR @"Paints"

@interface MyPaintManager()

- (void)deletePaintImage:(NSString *)paintImage sync:(BOOL)sync;

@end


@implementation MyPaintManager

static MyPaintManager* _defaultManager;

+ (MyPaintManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[MyPaintManager alloc] init];
    }
    
    return _defaultManager;
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
    
    [newMyPaint setData:data];
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
    time_t aTime = time(0);
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
            NSLog(@"<updateDraft> delete old image");
            [self deletePaintImage:draft.image sync:YES];            
        }
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:drawActionList];
        draft.data = data;
        draft.image = imageName;
        CoreDataManager* dataManager = GlobalGetCoreDataManager();
        NSLog(@"<update draft> before save, draft = %@",draft);
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
{
    
    NSLog(@"<Draw Log>createDraft");
    
    NSString *imageName = [self writeImage:image];
    if (imageName) {
        //create the drawlist data.
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:drawActionList];

        CoreDataManager* dataManager = GlobalGetCoreDataManager();
        
        NSLog(@"<Draw Log>createDraft insert new draft");
        
        MyPaint* newMyPaint = [dataManager insert:@"MyPaint"];
        
        NSLog(@"<Draw Log>createDraft set attributes");
        
        [newMyPaint setData:data];
        [newMyPaint setImage:imageName];
        [newMyPaint setDrawByMe:[NSNumber numberWithBool:YES]];
        [newMyPaint setDraft:[NSNumber numberWithBool:YES]];
        [newMyPaint setDrawUserId:[[UserManager defaultManager] userId]];
        [newMyPaint setDrawUserNickName:[[UserManager defaultManager] nickName]];
        [newMyPaint setCreateDate:[NSDate date]];
        [newMyPaint setDrawWord:drawWord];
        
        NSLog(@"<Draw Log>before set Lanauge,  %@", [newMyPaint description]);
        
        [newMyPaint setLanguage:[NSNumber numberWithInt:language]];
        
        NSLog(@"<Draw Log>before set level,  %@", [newMyPaint description]);
        
        [newMyPaint setLevel:[NSNumber numberWithInt:level]];
        
        PPDebug(@"<createDraftWithImage> %@", [newMyPaint description]);
        
        NSLog(@"<Draw Log>createDraft before save draft, new Paint = %@",newMyPaint);
        
        BOOL result = [dataManager save];
        
        NSLog(@"<Draw Log>createDraft saved!, result = %d",result);
            
        if (result) {
            return newMyPaint;
        }else{
            PPDebug(@"<createDraft>:fail to create draft, word = %@", drawWord);
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

- (void)findMyPaintsFrom:(NSInteger)offset 
                       limit:(NSInteger)limit 
                    delegate:(id<MyPaintManagerDelegate>)delegate
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (queue) {
        dispatch_async(queue, ^{
            NSArray *array = [dataManager execute:@"findOnlyMyPaints" sortBy:@"createDate" returnFields:nil ascending:NO offset:offset limit:limit];
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
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (queue) {
        dispatch_async(queue, ^{
            NSArray *array = [dataManager execute:@"findAllMyPaints" sortBy:@"createDate" returnFields:nil ascending:NO offset:offset limit:limit];
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
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (queue) {
        dispatch_async(queue, ^{
            NSArray *array = [dataManager execute:@"findAllDrafts" sortBy:@"createDate" returnFields:nil ascending:NO offset:offset limit:limit];
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
    
    for (MyPaint* paint in array){
        [paint setDeleteFlag:[NSNumber numberWithBool:YES]];
        //remove the image path.
        [self deletePaintImage:paint.image sync:YES];
        //delete data        
        [dataManager del:paint];
    }
    [dataManager save];    
}

- (BOOL)deletePaintsByRquestName:(NSString *)requestName
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    NSArray* array = [dataManager execute:requestName];
    for (MyPaint* paint in array){
        [paint setDeleteFlag:[NSNumber numberWithBool:YES]];
//        NSString *imagePath = paint.image;
//        BOOL flag = [dataManager del:paint];     
//        if (flag) {
//            [self deletePaintImage:imagePath sync:NO];
//        }
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


- (void)deletePaintImage:(NSString *)paintImage sync:(BOOL)sync
{
    dispatch_block_t block = ^{
        NSString* image = [NSString stringWithString:[MyPaintManager getMyPaintImagePathByCapacityPath:paintImage]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:image]) {
            [[NSFileManager defaultManager] removeItemAtPath:image error:nil];
            PPDebug(@"<deleteMyPaints> remove image at %@", image);
        }        
    };
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (!sync && queue != NULL){
        dispatch_async(queue, block);
    }else{
        NSString* image = [NSString stringWithString:[MyPaintManager getMyPaintImagePathByCapacityPath:paintImage]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:image]) {
            [[NSFileManager defaultManager] removeItemAtPath:image error:nil];
            PPDebug(@"<deleteMyPaints> remove image at %@", image);
        }        
    }
}

- (BOOL)deleteMyPaint:(MyPaint*)paint
{
//    NSString *paintImage = paint.image;
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    [paint setDeleteFlag:[NSNumber numberWithBool:YES]];
//    NSLog(@"<deleteMyPaint> before del");
//    [dataManager del:paint];
    
    NSLog(@"<deleteMyPaint> before save");
    BOOL result = [dataManager save];
    
//    NSLog(@"<deleteMyPaint> after save, result = %d",result);
//    
//    if (result) {
//        [self deletePaintImage:paintImage sync:YES];
//    }
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
        NSLog(@"Document directory not found!");
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
    NSLog(@"construct path = %@",uniquePath);
    return uniquePath;
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
