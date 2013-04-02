//
//  DrawUtils.h
//  Draw
//
//  Created by  on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceDetection.h"
#import "Draw.pb.h"


#define ILLEGAL_POINT CGPointMake(-100000, -100000)

/*
#define IPAD_SCALE 2.4013
#define IPAD_WIDTH_SCALE 2.4013
#define IPAD_HEIGHT_SCALE 2.18125

// width
#define DRAW_VIEW_WIDTH_IPAD   (730)  // 730 = (304 * IPAD_WIDTH_SCALE)
#define DRAW_VIEW_WIDTH_IPHONE (304)

// height
#define DRAW_VIEW_HEIGHT_IPAD   (698) // 698 = (320 * IPAD_HEIGHT_SCALE)
#define DRAW_VIEW_HEIGHT_IPHONE (320)

// frame
#define DRAW_VIEW_FRAME_IPAD CGRectMake(19, 100, DRAW_VIEW_WIDTH_IPAD, DRAW_VIEW_HEIGHT_IPAD)
#define DRAW_VIEW_FRAME_IPHONE CGRectMake(8, 40, DRAW_VIEW_WIDTH_IPHONE, DRAW_VIEW_HEIGHT_IPHONE)

// rect
#define DRAW_VIEW_RECT_IPAD CGRectMake(0, 0, DRAW_VIEW_WIDTH_IPAD, DRAW_VIEW_HEIGHT_IPAD)
#define DRAW_VIEW_RECT_IPHONE CGRectMake(0, 0, DRAW_VIEW_WIDTH_IPHONE, DRAW_VIEW_HEIGHT_IPHONE)

// auto support for iPhone & iPad
#define DRAW_VIEW_FRAME ([DeviceDetection isIPAD] ? DRAW_VIEW_FRAME_IPAD : DRAW_VIEW_FRAME_IPHONE)
#define DRAW_VIEW_WIDTH ([DeviceDetection isIPAD] ? DRAW_VIEW_WIDTH_IPAD :DRAW_VIEW_WIDTH_IPHONE)
#define DRAW_VIEW_HEIGHT ([DeviceDetection isIPAD] ? DRAW_VIEW_HEIGHT_IPAD :DRAW_VIEW_HEIGHT_IPHONE)

#define DRAW_VIEW_RECT  ([DeviceDetection isIPAD] ? DRAW_VIEW_RECT_IPAD : DRAW_VIEW_RECT_IPHONE)
*/


@class DrawColor;
@interface DrawUtils : NSObject
+ (CGPoint)illegalPoint;
+ (BOOL)isIllegalPoint:(CGPoint)point;
+ (CGRect)constructWithPoint1:(CGPoint)point1 point2:(CGPoint)point2;
+ (CGRect)constructWithPoint1:(CGPoint)point1 point2:(CGPoint)point2 edgeWidth:(CGFloat)edgeWidth;
+ (CGPoint)zipPoint:(CGPoint)point size:(NSInteger)size;
+ (CGFloat)distanceBetweenPoint:(CGPoint)point1 point2:(CGPoint)point2;

+ (BOOL)isNotVersion1:(int)dataVersion;

+ (NSInteger)compressDrawColor:(DrawColor *)color;
+ (DrawColor *)decompressIntDrawColor:(NSInteger)intColor;

+ (NSInteger)compressRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (UIColor *)decompressIntColor:(NSInteger)intColor;

+ (NSInteger)compressPoint:(CGPoint)point;
+ (NSInteger)compressPointWithX:(float)x y:(float)y;
+ (CGPoint)decompressIntPoint:(NSInteger)intPoint;
+ (NSArray *)compressCGPointList:(NSArray *)pointList;
+ (NSArray *)decompressNumberPointList:(NSArray *)numberPointList;


+ (NSInteger)compressLineWidth:(CGFloat)width;
+ (NSInteger)compressLineWidth:(CGFloat)width penType:(int)type;
+ (CGFloat )decompressPenTypeWidth:(NSInteger)intLineWidth;
+ (CGFloat )decompressIntLineWidth:(NSInteger)intLineWidth;

+ (NSInteger)roundFloatValue:(CGFloat)value;

+ (CGRect)rectForPath:(CGPathRef)path withWidth:(CGFloat)width bounds:(CGRect)bounds;

+ (CGContextRef)createNewBitmapContext:(CGRect)rect;
+ (CGLayerRef)createCGLayerWithRect:(CGRect)rect;

// new compress and decompress
+ (NSUInteger)compressColor8WithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (void)decompressColor8:(NSUInteger)intColor red:(CGFloat*)red green:(CGFloat*)green blue:(CGFloat*)blue alpha:(CGFloat*)alpha;
+ (NSUInteger)compressDrawColor8:(DrawColor *)color;

//+ (CGRect)rectForPath1:(CGPathRef)path1 path2:(CGPathRef)path2 withWidth:(CGFloat)width;

/*
+ (CGPoint)midPoint1:(CGPoint)p1 point2:(CGPoint) p2;
+ (void)addSmoothPath:(CGMutablePathRef)pathRef startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
+ (void)addSmoothPath2:(CGMutablePathRef)pathRef startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
+ (void)addSmoothPath1:(CGMutablePathRef)pathRef startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
*/
 
@end


CGFloat CGPointDistance(CGPoint p1, CGPoint p2);
CGFloat CGPointRadian(CGPoint p1, CGPoint p2);
CGPoint CGPointVector(CGPoint p1, CGPoint p2);
CGRect CGRectWithPoints(CGPoint p1, CGPoint p2);
CGRect CGRectWithPointsAndWidth(CGPoint p1, CGPoint p2, CGFloat width);
CGSize CGSizeFromPBSize(PBSize *size);
PBSize *CGSizeToPBSize(CGSize size);
CGRect CGRectFromCGSize(CGSize size);
