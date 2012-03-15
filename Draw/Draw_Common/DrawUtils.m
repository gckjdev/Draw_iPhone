//
//  DrawUtils.m
//  Draw
//
//  Created by  on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawUtils.h"


@implementation DrawUtils

+ (CGPoint)illegalPoint
{
    return ILLEGAL_POINT;
}

+ (BOOL)isIllegalPoint:(CGPoint)point
{
    if (point.x == ILLEGAL_POINT.x && point.y == ILLEGAL_POINT.y) {
        return YES;
    }
    return NO;
}

+ (CGRect)constructWithPoint1:(CGPoint)point1 point2:(CGPoint)point2
{
    CGFloat x = MIN(point1.x, point2.x);
    CGFloat y = MIN(point1.y, point2.y);
    CGFloat width = ABS(point1.x - point2.x);
    CGFloat height = ABS(point1.y - point2.y);
    return CGRectMake(x , y , width, height);
}

+ (CGRect)constructWithPoint1:(CGPoint)point1 point2:(CGPoint)point2 edgeWidth:(CGFloat)edgeWidth
{
    CGFloat x = MIN(point1.x, point2.x);
    CGFloat y = MIN(point1.y, point2.y);
    CGFloat width = ABS(point1.x - point2.x);
    CGFloat height = ABS(point1.y - point2.y);
    return CGRectMake(x - edgeWidth / 2.0, y - edgeWidth / 2.0, width + edgeWidth, height + edgeWidth);
}

+ (CGPoint)zipPoint:(CGPoint)point size:(NSInteger)size
{
    
    if (size <= 1) {
        return point;
    }
    NSInteger x = point.x;
    NSInteger y = point.y;
    x -= (x % (size / 2));
    y -= (y % (size / 2));
    return CGPointMake(x, y);
}

+ (CGFloat)distanceBetweenPoint:(CGPoint)point1 point2:(CGPoint)point2
{
    CGFloat left = powf(point1.x - point2.x, 2);
    CGFloat right = powf(point1.y - point2.y, 2);
    return sqrtf(left + right);
}

+ (NSInteger)compressRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    NSInteger intRed = red * 255.0;
    NSInteger intGreen = green * 255.0;
    NSInteger intBlue = blue * 255.0;
    NSInteger intAlpha = alpha * 64.0;
    NSInteger ret = intAlpha + (intBlue << 6) + (intGreen << 14) + (intRed << 22);
    return ret;
}


+ (UIColor *)decompressIntColor:(NSInteger)intColor
{
    CGFloat alpha = (intColor % (1<<6)) / 64.0;
    CGFloat blue = ((intColor >> 6) % (1<<8)) / 255.0;
    CGFloat green = ((intColor >> 14) % (1<<8)) / 255.0; 
    CGFloat red = ((intColor >> 22) % (1<<8)) / 255.0; 
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
+ (NSInteger)compressPoint:(CGPoint)point
{
    NSInteger ret = (point.x * (1 << 15)) + point.y;
    return ret;
}

+ (CGPoint)decompressIntPoint:(NSInteger)intPoint
{
    CGFloat y = intPoint % (1 << 15);
    CGFloat x = intPoint >> 15;
    return CGPointMake(x, y);
    
}


#define LINT_TIMES 100000.0
+ (NSInteger)compressLineWidth:(CGFloat)width
{
    return width * LINT_TIMES;
}

+ (CGFloat )decompressIntLineWidth:(NSInteger)intLineWidth
{
    return intLineWidth / LINT_TIMES;
}

@end
