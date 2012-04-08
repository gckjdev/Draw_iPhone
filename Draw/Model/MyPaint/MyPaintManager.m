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
{
    CoreDataManager* dataManager = GlobalGetCoreDataManager();
    MyPaint* newMyPaint = [dataManager insert:@"MyPaint"];
    
    [newMyPaint setData:data];
    [newMyPaint setImage:image];
    [newMyPaint setDrawByMe:[NSNumber numberWithBool:drawByMe]];
    [newMyPaint setDrawUserId:drawUserId];
    [newMyPaint setDrawUserNickName:drawUserNickName];
    [newMyPaint setCreateDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
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
    return [dataManager del:object];
}

- (BOOL)deleteOnlyMyPaintsAtIndex:(NSInteger)index
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    NSArray* array = [dataManager execute:@"findOnlyMyPaints" sortBy:@"createDate" ascending:NO];
    NSManagedObject* object = [array objectAtIndex:index];
    return [dataManager del:object];
}

- (BOOL)deleteMyPaints:(MyPaint*)paint
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    [dataManager del:paint];
    return [dataManager save];
}

@end
