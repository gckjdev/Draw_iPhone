//
//  DrawUtils.h
//  Draw
//
//  Created by  on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceDetection.h"

#define ILLEGAL_POINT CGPointMake(-100000, -100000)
#define IPAD_SCALE 2.4
#define IPAD_WIDTH_SCALE 2.4
#define IPAD_HEIGHT_SCALE 2.18
#define DRAW_VEIW_FRAME_IPAD CGRectMake(18, 106, 304 * IPAD_WIDTH_SCALE, 320 * IPAD_HEIGHT_SCALE)
#define DRAW_VEIW_FRAME_IPHONE CGRectMake(8, 46, 304, 320)

#define DRAW_VIEW_WIDTH_IPAD (304 * IPAD_WIDTH_SCALE)
#define DRAW_VIEW_WIDTH_IPHONE (304)

#define PICK_PEN_VIEW_IPAD CGRectMake(21, 520, 302 *IPAD_SCALE, 122*IPAD_SCALE)
#define PICK_PEN_VIEW_IPHONE CGRectMake(8, 250, 302, 122)


#define DRAW_VEIW_FRAME ([DeviceDetection isIPAD] ? DRAW_VEIW_FRAME_IPAD : DRAW_VEIW_FRAME_IPHONE)
#define PICK_PEN_VIEW ([DeviceDetection isIPAD] ? PICK_PEN_VIEW_IPAD : PICK_PEN_VIEW_IPHONE)
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
+ (CGFloat )decompressIntLineWidth:(NSInteger)intLineWidth;



@end
