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


- (MyPaint *)createDraft:(UIImage *)image
                    data:(NSMutableArray*)drawActionList 
                language:(LanguageType)language
                drawWord:(NSString*)drawWord 
                   level:(WordLevel)level
{
    
    time_t aTime = time(0);
    NSString* imageName = [NSString stringWithFormat:@"%d.png", aTime];
    NSString *uniquePath=[MyPaintManager constructImagePath:imageName];
    NSData* imageData = UIImagePNGRepresentation(image);

    //save image
    BOOL result=[imageData writeToFile:uniquePath atomically:YES];
    PPDebug(@"<createDraft> save image to path:%@ result:%d , canRead:%d", uniquePath, result, [[NSFileManager defaultManager] fileExistsAtPath:uniquePath]);
    
    //create the drawlist data.
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:drawActionList];

    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    MyPaint* newMyPaint = [dataManager insert:@"MyPaint"];
    
    [newMyPaint setData:data];
    [newMyPaint setImage:imageName];
    [newMyPaint setDrawByMe:[NSNumber numberWithBool:YES]];
    [newMyPaint setDraft:[NSNumber numberWithBool:YES]];
    [newMyPaint setDrawUserId:[[UserManager defaultManager] userId]];
    [newMyPaint setDrawUserNickName:[[UserManager defaultManager] nickName]];
    [newMyPaint setCreateDate:[NSDate date]];
    [newMyPaint setDrawWord:drawWord];
    [newMyPaint setLanguage:language];
    [newMyPaint setLevel:level];
    
    PPDebug(@"<createDraftWithImage> %@", [newMyPaint description]);
    result = [dataManager save];
    if (result) {
        return newMyPaint;
    }else{
        PPDebug(@"<createDraft>:fail to create draft, word = %@", drawWord);
        return nil;
    }
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

- (BOOL)deleteAllPaints:(BOOL)onlyDrawnByMe
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    NSArray* array;
    if (onlyDrawnByMe) {
         array = [dataManager execute:@"findOnlyMyPaints" sortBy:@"createDate" ascending:NO];
    } else {
        array = [dataManager execute:@"findAllMyPaints" sortBy:@"createDate" ascending:NO];
    }
    for (NSManagedObject* paint in array){
        [dataManager del:paint];       
    }
    [dataManager save];    
    return YES;
}

- (BOOL)deleteAllDrafts
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    NSArray* array = [dataManager execute:@"findAllDrafts" sortBy:@"createDate" ascending:NO];
    for (NSManagedObject* paint in array){
        [dataManager del:paint];       
    }
    [dataManager save];    
    return YES;    
}

- (BOOL)deleteMyPaint:(MyPaint*)paint
{
    NSString* image = [NSString stringWithString:[MyPaintManager getMyPaintImagePathByCapacityPath:paint.image]];

    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    [dataManager del:paint];
    BOOL result = [dataManager save];

    if (result && [[NSFileManager defaultManager] fileExistsAtPath:image]) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        if (queue == NULL){
            queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        }

        if (queue != NULL){
            dispatch_async(queue, ^{
                [[NSFileManager defaultManager] removeItemAtPath:image error:nil];
                PPDebug(@"<deleteMyPaints> remove image at %@", image);
            });
        }
    }
    
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
