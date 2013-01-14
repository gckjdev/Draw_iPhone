//
//  DrawUtils.m
//  Draw
//
//  Created by  on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawUtils.h"
#import "DrawColor.h"

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
    NSInteger intAlpha = alpha * 63.0;
    NSInteger ret = intAlpha + (intBlue << 6) + (intGreen << 14) + (intRed << 22);
    return ret;
}


+ (UIColor *)decompressIntColor:(NSInteger)intColor
{
    CGFloat alpha = (intColor % (1<<6)) / 63.0;
    CGFloat blue = ((intColor >> 6) % (1<<8)) / 255.0;
    CGFloat green = ((intColor >> 14) % (1<<8)) / 255.0; 
    CGFloat red = ((intColor >> 22) % (1<<8)) / 255.0; 
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (NSInteger)roundFloatValue:(CGFloat)value
{
    NSInteger round = value;
    if (value - round > 0.5) {
        ++round;
    }
    return round;
}

+ (NSInteger)compressPoint:(CGPoint)point
{
    NSInteger ret = ([DrawUtils roundFloatValue:point.x] * (1 << 15)) + [DrawUtils roundFloatValue:point.y];

//    NSLog(@"Compress: %@====>%d",NSStringFromCGPoint(point), ret);
    return ret;
}

+ (CGPoint)decompressIntPoint:(NSInteger)intPoint
{
    NSInteger div = 1<< 15;
    NSInteger y = intPoint % div;
    CGFloat x = (CGFloat)intPoint / (CGFloat)(div);
    CGPoint point = CGPointMake(x, y);
//    NSLog(@"Decompress %d====>%@", intPoint, NSStringFromCGPoint(point));
    return point;
    
}

+ (NSArray *)compressCGPointList:(NSArray *)pointList
{
    NSMutableArray *retArray = [[[NSMutableArray alloc] init] autorelease];
    for (NSValue *value in pointList) {
        CGPoint point = [value CGPointValue];
        NSNumber *number = [NSNumber numberWithInt:[DrawUtils compressPoint:point]];
        [retArray addObject:number];
    }
    return retArray;
}
+ (NSArray *)decompressNumberPointList:(NSArray *)numberPointList
{
    NSMutableArray *pointList = [[[NSMutableArray alloc] init]autorelease];
    for (NSNumber *pointNumber in numberPointList) {
        CGPoint point = [DrawUtils decompressIntPoint:[pointNumber integerValue]];
        [pointList addObject:[NSValue valueWithCGPoint:point]];
    }
    return pointList;
}


+ (NSInteger)compressDrawColor:(DrawColor *)color
{
    return [DrawUtils compressRed:color.red green:color.green blue:color.blue alpha:color.alpha];
}
+ (DrawColor *)decompressIntDrawColor:(NSInteger)intColor
{

    CGFloat alpha = (intColor % (1<<6)) / 63.0;
    CGFloat blue = ((intColor >> 6) % (1<<8)) / 255.0;
    CGFloat green = ((intColor >> 14) % (1<<8)) / 255.0; 
    CGFloat red = ((intColor >> 22) % (1<<8)) / 255.0; 
    return [DrawColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#define LINE_TIMES 100000.0
#define PEN_TYPE 100
+ (NSInteger)compressLineWidth:(CGFloat)width
{
    return width * LINE_TIMES;
}

+ (NSInteger)compressLineWidth:(CGFloat)width penType:(int)type
{
    NSInteger value = width * LINE_TIMES;
    value -= (value % PEN_TYPE);
    return value + type;
}

+ (CGFloat )decompressIntLineWidth:(NSInteger)intLineWidth
{
    return intLineWidth / LINE_TIMES;
}

+ (CGFloat )decompressPenTypeWidth:(NSInteger)intLineWidth
{
    return intLineWidth % PEN_TYPE;
}

+ (CGPoint)midPoint1:(CGPoint)p1 point2:(CGPoint) p2
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

+ (CGRect)rectForPath:(CGPathRef)path withWidth:(CGFloat)width
{
    CGRect rect = CGPathGetBoundingBox(path);
    rect.origin.x = (NSInteger)(rect.origin.x - width) - 1;
    rect.origin.y = (NSInteger)(rect.origin.y - width) - 1;;
    rect.size.width = (NSInteger)(rect.size.width + width * 2) + 2;
    rect.size.height = (NSInteger)(rect.size.height + width * 2) + 2;
    return rect; //make sure all the values are integer
}
@end
