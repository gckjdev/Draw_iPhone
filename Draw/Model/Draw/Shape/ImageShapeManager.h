//
//  ImageShapeManager.h
//  Draw
//
//  Created by gamy on 13-6-7.
//
//

#import <Foundation/Foundation.h>
#import "ShapeInfo.h"
#import "SynthesizeSingleton.h"

@interface ImageShapeManager : NSObject

- (ImageShapeInfo *)imageShapeWithType:(ShapeType)type;

- (UIBezierPath *)pathWithType:(ShapeType)type; //default rect = {0, 0, 64, 64}

- (UIBezierPath *)pathWithBasicType:(ShapeType)type
                         startPoint:(CGPoint)startPoint
                           endPoint:(CGPoint)endPoint;

- (BOOL)isBasicShapeType:(ShapeType)type;
- (void)cleanCache;
- (NSArray *)imageShapeGroupList;
+ (id)defaultManager;

#pragma mark- Test Method

+ (void)createMetaFile;
+ (void)loadMetaFile;
@end
