//
//  MyPaintManager.m
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyPaintManager.h"
#import "CoreDataUtil.h"
#import "MyPaint.h"
#import "PPDebug.h"

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

- (NSArray*)findOnlyMyPaints
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    return [dataManager execute:@"findOnlyMyPaints" sortBy:@"createDate" ascending:NO];
}

- (NSArray*)findAllPaints
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    return [dataManager execute:@"findAllMyPaints" sortBy:@"createDate" ascending:NO];

}

- (BOOL)deleteAllPaintsAtIndex:(NSInteger)index
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    NSArray* array = [dataManager execute:@"findAllMyPaints" sortBy:@"createDate" ascending:NO];
    NSManagedObject* object = [array objectAtIndex:index];
    [dataManager del:object];
    return [dataManager save];
}

- (BOOL)deleteOnlyMyPaintsAtIndex:(NSInteger)index
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    NSArray* array = [dataManager execute:@"findOnlyMyPaints" sortBy:@"createDate" ascending:NO];
    NSManagedObject* object = [array objectAtIndex:index];
    [dataManager del:object];
    return [dataManager save];
}

- (void)deleteAllPaints
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    NSArray* array = [dataManager execute:@"findAllMyPaints" sortBy:@"createDate" ascending:NO];
    for (NSManagedObject* paint in array){
        [dataManager del:paint];
    }
    
    [dataManager save];    
}

- (BOOL)deleteMyPaints:(MyPaint*)paint
{
    NSString* image = [NSString stringWithString:paint.image];

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

@end
