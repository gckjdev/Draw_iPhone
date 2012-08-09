//
//  MyPaintManager.h
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyPaintManagerDelegate <NSObject>

@optional
- (void)didGetAllPaints:(NSArray *)paints;
- (void)didGetMyPaints:(NSArray *)paints;

@end

@class MyPaint;

@interface MyPaintManager : NSObject

+ (NSString*)getMyPaintImagePathByCapacityPath:(NSString*)path;
+ (NSString*)getMyPaintImageDirection;
+ (NSString *)constructImagePath:(NSString *)imageName;

+ (MyPaintManager*)defaultManager;
- (BOOL)createMyPaintWithImage:(NSString*)image
                          data:(NSData*)data
                    drawUserId:(NSString*)drawUserId
              drawUserNickName:(NSString*)drawUserNickName
                      drawByMe:(BOOL)drawByMe
                      drawWord:(NSString*)drawWord;


- (NSArray*)findOnlyMyPaints;
- (NSArray*)findAllPaints;

- (void)findMyPaintsFrom:(NSInteger)offset 
                       limit:(NSInteger)limit 
                    delegate:(id<MyPaintManagerDelegate>)delegate;

- (void)findAllPaintsFrom:(NSInteger)offset 
                        limit:(NSInteger)limit 
                     delegate:(id<MyPaintManagerDelegate>)delegate;


//- (BOOL)deleteAllPaintsAtIndex:(NSInteger)index;
//- (BOOL)deleteOnlyMyPaintsAtIndex:(NSInteger)index;

- (BOOL)deleteMyPaint:(MyPaint*)paint;
- (BOOL)deleteAllPaints:(BOOL)onlyDrawnByMe;
- (void)savePhoto:(NSString*)filePath;

@end
