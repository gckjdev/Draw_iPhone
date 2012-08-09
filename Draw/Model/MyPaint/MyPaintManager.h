//
//  MyPaintManager.h
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
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
- (BOOL)deleteAllPaintsAtIndex:(NSInteger)index;
- (BOOL)deleteOnlyMyPaintsAtIndex:(NSInteger)index;
- (BOOL)deleteMyPaints:(MyPaint*)paint;
- (void)deleteAllPaints:(BOOL)onlyDrawnByMe;
- (void)savePhoto:(NSString*)filePath;

@end
