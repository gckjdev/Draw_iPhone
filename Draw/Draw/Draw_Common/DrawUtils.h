//
//  DrawUtils.h
//  Draw
//
//  Created by  on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceDetection.h"

#define PICK_PEN_VIEW_IPHONE_HEIGHT 152

#define ILLEGAL_POINT CGPointMake(-100000, -100000)
#define IPAD_SCALE 2.4013
#define IPAD_WIDTH_SCALE 2.4013
#define IPAD_HEIGHT_SCALE 2.18125
#define DRAW_VIEW_FRAME_IPAD CGRectMake(19, 106, 730, 698)
#define DRAW_VIEW_FRAME_IPHONE CGRectMake(8, 46, 304, 320)

#define DRAW_VIEW_WIDTH_IPAD (304 * IPAD_WIDTH_SCALE)
#define DRAW_VIEW_WIDTH_IPHONE (304)


#define DRAW_VIEW_FRAME ([DeviceDetection isIPAD] ? DRAW_VIEW_FRAME_IPAD : DRAW_VIEW_FRAME_IPHONE)

#define DRAW_VIEW_WIDTH ([DeviceDetection isIPAD] ? DRAW_VIEW_WIDTH_IPAD :DRAW_VIEW_WIDTH_IPHONE)





@class DrawColor;
@interface DrawUtils : NSObject
+ (CGPoint)illegalPoint;
+ (BOOL)isIllegalPoint:(CGPoint)point;
+ (CGRect)constructWithPoint1:(CGPoint)point1 point2:(CGPoint)point2;
+ (CGRect)constructWithPoint1:(CGPoint)point1 point2:(CGPoint)point2 edgeWidth:(CGFloat)edgeWidth;
+ (CGPoint)zipPoint:(CGPoint)point size:(NSInteger)size;
+ (CGFloat)distanceBetweenPoint:(CGPoint)point1 point2:(CGPoint)point2;

+ (NSInteger)compressDrawColor:(DrawColor *)color;
+ (DrawColor *)decompressIntDrawColor:(NSInteger)intColor;

+ (NSInteger)compressRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (UIColor *)decompressIntColor:(NSInteger)intColor;

+ (NSInteger)compressPoint:(CGPoint)point;
+ (CGPoint)decompressIntPoint:(NSInteger)intPoint;
+ (NSArray *)compressCGPointList:(NSArray *)pointList;
+ (NSArray *)decompressNumberPointList:(NSArray *)numberPointList;


+ (NSInteger)compressLineWidth:(CGFloat)width;
+ (NSInteger)compressLineWidth:(CGFloat)width penType:(int)type;
+ (CGFloat )decompressPenTypeWidth:(NSInteger)intLineWidth;
+ (CGFloat )decompressIntLineWidth:(NSInteger)intLineWidth;

+ (NSInteger)roundFloatValue:(CGFloat)value;

+ (CGRect)rectForPath:(CGPathRef)path withWidth:(CGFloat)width bounds:(CGRect)bounds;
//+ (CGRect)rectForPath1:(CGPathRef)path1 path2:(CGPathRef)path2 withWidth:(CGFloat)width;

/*
+ (CGPoint)midPoint1:(CGPoint)p1 point2:(CGPoint) p2;
+ (void)addSmoothPath:(CGMutablePathRef)pathRef startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
+ (void)addSmoothPath2:(CGMutablePathRef)pathRef startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
+ (void)addSmoothPath1:(CGMutablePathRef)pathRef startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
*/
 
@end
