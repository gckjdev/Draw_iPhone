//
//  DrawUtils.h
//  Draw
//
//  Created by  on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ILLEGAL_POINT CGPointMake(-100000, -100000)

@interface DrawUtils : NSObject
+ (CGPoint)illegalPoint;
+ (BOOL)isIllegalPoint:(CGPoint)point;
+ (CGRect)constructWithPoint1:(CGPoint)point1 point2:(CGPoint)point2;
+ (CGRect)constructWithPoint1:(CGPoint)point1 point2:(CGPoint)point2 edgeWidth:(CGFloat)edgeWidth;
+ (CGPoint)zipPoint:(CGPoint)point size:(NSInteger)size;
+ (CGFloat)distanceBetweenPoint:(CGPoint)point1 point2:(CGPoint)point2;
//+ (NSInteger)compressColor:(UIColor *)color;
+ (NSInteger)compressRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (NSInteger)compressPoint:(CGPoint)point;
+ (UIColor *)decompressIntColor:(NSInteger)intColor;
+ (CGPoint)decompressIntPoint:(NSInteger)intPoint;

+ (NSInteger)compressLineWidth:(CGFloat)width;
+ (CGFloat )decompressIntLineWidth:(NSInteger)intLineWidth;

@end
