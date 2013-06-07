//
//  ImageShapeManager.h
//  Draw
//
//  Created by gamy on 13-6-7.
//
//

#import <Foundation/Foundation.h>
#import "ShapeInfo.h"

@interface ImageShapeManager : NSObject

+ (ImageShapeInfo *)imageShapeWithType:(ShapeType)type;
+ (void)cleanCache;
//+ ()

@end
