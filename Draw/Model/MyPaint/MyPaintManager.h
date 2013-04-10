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

@class DrawFeed;

@protocol MyPaintManagerDelegate <NSObject>

@optional
- (void)didGetAllPaints:(NSArray *)paints;
- (void)didGetMyPaints:(NSArray *)paints;
- (void)didGetAllDrafts:(NSArray *)paints;
- (void)didSaveToAlbumSuccess:(BOOL)succ;
- (void)didCountAllPaints:(NSInteger)count;
- (void)didCountMyPaints:(NSInteger)count;
- (void)didCountAllDrafts:(NSInteger)count;
@end

@class MyPaint;
@class PBDraw;
@class PBNoCompressDrawData;

@interface MyPaintManager : NSObject
{
    StorageManager *_imageManager;
    StorageManager *_drawDataManager;
}



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

- (NSArray*)findAllDraftForRecovery;

//set delete flag.
- (BOOL)completeDeletePaint:(MyPaint*)paint;
- (BOOL)deleteMyPaint:(MyPaint*)paint;
- (BOOL)deleteAllPaints:(BOOL)onlyDrawnByMe;
- (BOOL)deleteAllDrafts;
- (void)savePhoto:(NSString*)filePath delegate:(id<MyPaintManagerDelegate>)delegate;
- (BOOL)save;
- (BOOL)deleteMyPaint:(MyPaint *)paint;

//real remove.
- (void)removeAlldeletedPaints;


#pragma mark new methods.

- (BOOL)createMyPaintWithImage:(UIImage*)image
                        pbDraw:(PBDraw*)pbDraw;

- (MyPaint *)createDraft:(UIImage *)image
    pbNoCompressDrawData:(PBNoCompressDrawData *)pbNoCompressDrawData
               targetUid:(NSString *)targetUid
               contestId:(NSString *)contestId
                  userId:(NSString *)userId
                nickName:(NSString *)nickName
                    word:(Word *)word
                language:(NSInteger)language;

- (MyPaint *)createDraftForRecovery:(NSString *)targetUid
                   contestId:(NSString *)contestId
                      userId:(NSString *)userId
                    nickName:(NSString *)nickName
                        word:(Word *)word
                    language:(NSInteger)language;

- (BOOL)updateDraft:(MyPaint *)draft
              image:(UIImage *)image
pbNoCompressDrawData:(PBNoCompressDrawData*)pbNoCompressDrawData;

- (NSMutableArray *)drawActionListForPaint:(MyPaint *)paint;
- (NSString *)imagePathForPaint:(MyPaint *)paint;

- (NSString*)fullDataPath:(NSString*)dataFileName;

- (BOOL)createMyPaintWithImage:(UIImage*)image
                    pbDrawData:(NSData*)pbDrawData
                          feed:(DrawFeed*)feed;

@end
