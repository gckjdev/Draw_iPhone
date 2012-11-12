//
//  MyPaintManager.h
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MyPaint.h"
#import "UserManager.h"
#import "Word.h"
#import "StorageManager.h"

@protocol MyPaintManagerDelegate <NSObject>

@optional
- (void)didGetAllPaints:(NSArray *)paints;
- (void)didGetMyPaints:(NSArray *)paints;
- (void)didGetAllDrafts:(NSArray *)paints;
@end

@class MyPaint;
@class PBDraw;

@interface MyPaintManager : NSObject
{
    StorageManager *_imageManager;
    StorageManager *_drawDataManager;
}
//+ (NSString*)getMyPaintImagePathByCapacityPath:(NSString*)path;
//+ (NSString *)constructImagePath:(NSString *)imageName;
//+ (NSString *)constructDataPath:(NSString *)dataName;
//
//+ (NSData *)drawDataFromDataPath:(NSString *)path;

//- (MyPaint *)createDraft:(UIImage *)image
//                    data:(NSMutableArray*)drawActionList 
//                language:(LanguageType)language
//                drawWord:(NSString*)drawWord 
//                   level:(WordLevel)level
//               targetUid:(NSString *)targetUid;
//
//- (BOOL)updateDraft:(MyPaint *)draft 
//              image:(UIImage *)image
//               data:(NSMutableArray*)drawActionList;
//
//
//
//- (BOOL)createMyPaintWithImage:(NSString*)image
//                          data:(NSData*)data
//                    drawUserId:(NSString*)drawUserId
//              drawUserNickName:(NSString*)drawUserNickName
//                      drawByMe:(BOOL)drawByMe
//                      drawWord:(NSString*)drawWord;



#pragma mark - below no chage.

+ (MyPaintManager*)defaultManager;

- (void)findMyPaintsFrom:(NSInteger)offset 
                       limit:(NSInteger)limit 
                    delegate:(id<MyPaintManagerDelegate>)delegate;

- (void)findAllPaintsFrom:(NSInteger)offset 
                        limit:(NSInteger)limit 
                     delegate:(id<MyPaintManagerDelegate>)delegate;

- (void)findAllDraftsFrom:(NSInteger)offset 
                    limit:(NSInteger)limit 
                 delegate:(id<MyPaintManagerDelegate>)delegate;


//set delete flag.
- (BOOL)deleteMyPaint:(MyPaint*)paint;
- (BOOL)deleteAllPaints:(BOOL)onlyDrawnByMe;
- (BOOL)deleteAllDrafts;
- (void)savePhoto:(NSString*)filePath;
- (BOOL)save;
- (BOOL)deleteMyPaint:(MyPaint *)paint;

//real remove.
- (void)removeAlldeletedPaints;


#pragma mark new methods.

- (BOOL)createMyPaintWithImage:(UIImage*)image
                    pbDrawData:(PBDraw*)pbDrawData;

- (MyPaint *)createDraft:(UIImage *)image
              pbDrawData:(PBDraw*)pbDrawData
               targetUid:(NSString *)targetUid;

- (BOOL)updateDraft:(MyPaint *)draft
              image:(UIImage *)image
        pbDrawData:(PBDraw*)pbDrawData;

- (NSMutableArray *)drawActionListForPaint:(MyPaint *)paint;
- (NSString *)imagePathForPaint:(MyPaint *)paint;



@end
