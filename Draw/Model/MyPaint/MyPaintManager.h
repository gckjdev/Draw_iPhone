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

@protocol MyPaintManagerDelegate <NSObject>

@optional
- (void)didGetAllPaints:(NSArray *)paints;
- (void)didGetMyPaints:(NSArray *)paints;
- (void)didGetAllDrafts:(NSArray *)paints;
@end

@class MyPaint;


@interface MyPaintManager : NSObject

+ (NSString*)getMyPaintImagePathByCapacityPath:(NSString*)path;
+ (NSString*)getMyPaintImageDirection;
+ (NSString *)constructImagePath:(NSString *)imageName;

+ (MyPaintManager*)defaultManager;

- (MyPaint *)createDraft:(UIImage *)image
                    data:(NSMutableArray*)drawActionList 
                language:(LanguageType)language
                drawWord:(NSString*)drawWord 
                   level:(WordLevel)level;


- (MyPaint *)latestDraft;

- (BOOL)createMyPaintWithImage:(NSString*)image
                          data:(NSData*)data
                    drawUserId:(NSString*)drawUserId
              drawUserNickName:(NSString*)drawUserNickName
                      drawByMe:(BOOL)drawByMe
                      drawWord:(NSString*)drawWord;


- (void)findMyPaintsFrom:(NSInteger)offset 
                       limit:(NSInteger)limit 
                    delegate:(id<MyPaintManagerDelegate>)delegate;

- (void)findAllPaintsFrom:(NSInteger)offset 
                        limit:(NSInteger)limit 
                     delegate:(id<MyPaintManagerDelegate>)delegate;

- (void)findAllDraftsFrom:(NSInteger)offset 
                    limit:(NSInteger)limit 
                 delegate:(id<MyPaintManagerDelegate>)delegate;


- (BOOL)deleteMyPaint:(MyPaint*)paint;
- (BOOL)deleteAllPaints:(BOOL)onlyDrawnByMe;
- (BOOL)deleteAllDrafts;
- (void)savePhoto:(NSString*)filePath;
- (BOOL)save;
- (BOOL)deleteMyPaint:(MyPaint *)paint;
@end
