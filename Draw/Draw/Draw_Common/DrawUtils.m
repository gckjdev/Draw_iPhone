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



+ (BOOL)isNotVersion1:(int)dataVersion
{
    return (dataVersion > 1);
}

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

// This method is NOT used yet, reservered for future analysis
CGPoint midPoint1(CGPoint p1, CGPoint p2)
{
    if (p1.x == p2.x){
        return CGPointMake(p1.x, (p1.y+p2.y)/2.0f);
    }
    
    if (p1.y == p2.y){
        return CGPointMake((p1.x+p2.x)/2.0f, p1.y);
    }
    
    CGPoint p3;
    
    if (p1.x < p2.x){
        p3.x = p2.x;
    }
    else{
        p3.x = p1.x;
    }
    
    if (p1.y < p2.y){
        p3.y = p1.y;
    }
    else{
        p3.y = p2.y;
    }
    
    return p3;
}

// this method is NOT used, just reserver for future analysis
+ (void)addSmoothPath:(CGMutablePathRef)pathRef startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{    
    if (pathRef == NULL)
        return;
    
    static const int TOTAL_POINTS = 1;
    static const int horizontalWiggle = 1;
    
    CGFloat stepChangeX = (endPoint.x - startPoint.x) / TOTAL_POINTS;
    CGFloat stepChangeY = (endPoint.y - startPoint.y) / TOTAL_POINTS;
    
    for(int i = 0; i < TOTAL_POINTS; i++) {
//        CGFloat startX = (startPoint.x + i * stepChangeX);
//        CGFloat startY = (startPoint.y + i * stepChangeY);
        
        CGFloat endX = (startPoint.x + (i+1) * stepChangeX);
        CGFloat endY = (startPoint.y + (i+1) * stepChangeY);
        
        CGFloat cpX1 = (startPoint.x + (i+0.25) * stepChangeX);
        if((i+1)%2) {
            cpX1 -= horizontalWiggle;
        } else {
            cpX1 += horizontalWiggle;
        }
        CGFloat cpY1 = (startPoint.y + (i+0.25) * stepChangeY);
        
        CGFloat cpX2 = (startPoint.x + (i+0.75) * stepChangeX);
        if((i+1)%2) {
            cpX2 -= horizontalWiggle;
        } else {
            cpX2 += horizontalWiggle;
        }
        CGFloat cpY2 = (startPoint.y + (i+0.75) * stepChangeY);
        
//        CGPathMoveToPoint(pathRef, NULL, startX, startY);
        CGPathAddCurveToPoint(pathRef, NULL, cpX1, cpY1, cpX2, cpY2, endX, endY);
    }
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

// new compress, with 8 bits for alpha
+ (NSUInteger)compressColor8WithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    NSUInteger ret = (NSUInteger)(alpha * 255.0) +
                     ((NSUInteger)(blue * 255.0) << 8) +
                     ((NSUInteger)(green * 255.0) << 16) +
                     ((NSUInteger)(red * 255.0) << 24);
    return ret;
}

// new decompress, with 8 bits for alpha
+ (void)decompressColor8:(NSUInteger)intColor red:(CGFloat*)red green:(CGFloat*)green blue:(CGFloat*)blue alpha:(CGFloat*)alpha
{
    *alpha = (intColor % (1<<8)) / 255.0;
    *blue = ((intColor >> 8) % (1<<8)) / 255.0;
    *green = ((intColor >> 16) % (1<<8)) / 255.0;
    *red = ((intColor >> 24) % (1<<8)) / 255.0;
}


+ (NSInteger)roundFloatValue:(CGFloat)value
{
    NSInteger round = value;
    if (value - round > 0.5) {
        ++round;
    }
    return round;
}

+ (NSInteger)compressPointWithX:(float)x y:(float)y
{
    NSInteger ret = ([DrawUtils roundFloatValue:x] * (1 << 15)) + [DrawUtils roundFloatValue:y];
    return ret;
}

+ (NSInteger)compressPoint:(CGPoint)point
{
    return [DrawUtils compressPointWithX:point.x y:point.y];
    
//    NSInteger ret = ([DrawUtils roundFloatValue:point.x] * (1 << 15)) + [DrawUtils roundFloatValue:point.y];
//    return ret;
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

+ (NSUInteger)compressDrawColor8:(DrawColor *)color
{
    return [DrawUtils compressColor8WithRed:color.red green:color.green blue:color.blue alpha:color.alpha];
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

//+ (CGRect)rectForPath1:(CGPathRef)path1 path2:(CGPathRef)path2 withWidth:(CGFloat)width
//{
//    if (path1 == NULL && path2 == NULL){
//        PPDebug(@"<rectForPath1> both path NULL");
//        return CGRectZero;
//    }
//    
//    if (path1 == NULL){
//        PPDebug(@"[PATH2] rect=%@", NSStringFromCGRect([DrawUtils rectForPath:path2 withWidth:width]));
//        return [DrawUtils rectForPath:path2 withWidth:width];
//    }
//    
//    if (path2 == NULL){
//        PPDebug(@"[PATH1] rect=%@", NSStringFromCGRect([DrawUtils rectForPath:path1 withWidth:width]));
//        return [DrawUtils rectForPath:path1 withWidth:width];;
//    }
//    
//    CGRect rect1 = [DrawUtils rectForPath:path1 withWidth:width];
//    CGRect rect2 = [DrawUtils rectForPath:path2 withWidth:width];
//    CGRect rect = CGRectUnion(rect1, rect2);
//    PPDebug(@"[PATH1+PATH2] rect=%@", NSStringFromCGRect(rect));
//    return rect;
//}

+ (CGRect)rectForPath:(CGPathRef)path withWidth:(CGFloat)width bounds:(CGRect)bounds
{
    CGRect rect = CGPathGetBoundingBox(path);
    rect.origin.x = (NSInteger)(rect.origin.x - width * 2);
    rect.origin.y = (NSInteger)(rect.origin.y - width * 2);
    
    if (rect.origin.x < 0){
        rect.origin.x = 0;
    }
    
    if (rect.origin.y < 0){
        rect.origin.y = 0;
    }
    
    rect.size.width = (NSInteger)(rect.size.width + width * 4);
    rect.size.height = (NSInteger)(rect.size.height + width * 4);

    if (rect.size.width > bounds.size.width){
        rect.size.width = bounds.size.width;
    }
    
    if (rect.size.height > bounds.size.height){
        rect.size.height = bounds.size.height;
    }
    
//    PPDebug(@"rect=%@", NSStringFromCGRect(rect));
    
    return rect; //make sure all the values are integer
}


+ (CGContextRef)createNewBitmapContext:(CGRect)rect
{
    NSInteger width = CGRectGetWidth(rect);
    NSInteger height = CGRectGetHeight(rect);
    
    float *bitmap = NULL;//(float*)malloc(sizeof(float) * width * height);
    
    CGColorSpaceRef colorSpace =  CGColorSpaceCreateDeviceRGB();

    CGContextRef context = CGBitmapContextCreate(
                                                 bitmap,
                                                 width,
                                                 height,
                                                 8, // 每个通道8位
                                                 width * sizeof(float),
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
//    if (context == NULL) {
//        context = CGBitmapContextCreate(
//                                                 NULL,
//                                                 width,
//                                                 height,
//                                                 8, // 每个通道8位
//                                                 width * 4,
//                                                 colorSpace,
//                                                 kCGImageAlphaNoneSkipLast);
//        
//    }
    CGColorSpaceRelease(colorSpace);
    if (bitmap != NULL) {
        free(bitmap);        
    }

    return context;

}

+ (CGLayerRef)createCGLayerWithRect:(CGRect)rect
{
    CGContextRef context = [DrawUtils createNewBitmapContext:rect];
    CGLayerRef layer = CGLayerCreateWithContext(context, rect.size, NULL);
    CGContextRelease(context);
    return layer;
}

+ (DrawColor*)drawColorFromPBNoCompressDrawActionC:(Game__PBNoCompressDrawAction*)action
{
    DrawColor* drawColor = nil;
    if (action->has_rgbcolor){
        drawColor = [DrawColor colorWithBetterCompressColor:action->rgbcolor];
    }
    if (action->color != NULL) {
        drawColor = [[[DrawColor alloc] initWithPBColorC:action->color] autorelease];
    }
    else{
        drawColor = [DrawColor colorWithRed:action->red green:action->green blue:action->blue alpha:action->alpha];
    }
    
    return drawColor;
}

@end


CGFloat CGPointDistance(CGPoint p1, CGPoint p2)
{
    return sqrtf(powf(p1.x - p2.x, 2) + powf(p1.y - p2.y, 2));
}

CGFloat CGPointRadian(CGPoint p1, CGPoint p2)
{
    CGFloat d = (CGPointDistance(p1, CGPointZero) * CGPointDistance(p2, CGPointZero));
    if (d == 0) {
        return 0;
    }
    CGFloat cosx = (p1.x * p2.x + p1.y * p2.y) / d;
    CGFloat ret = acosf(cosx);
    if (isnan(ret)) {
        return 0;
    }
    return ret;
}

CGPoint CGPointVector(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p2.x - p1.x, p2.y - p1.y);
}

CGPoint CGPointMid(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

CGPoint CGPointRand(NSUInteger maxX, NSUInteger maxY)
{
    return CGPointMake(rand()%maxX, rand()%maxY);
}

CGRect CGRectWithPoints(CGPoint p1, CGPoint p2)
{
    
    CGFloat x = MIN(p1.x, p2.x);
    CGFloat y = MIN(p1.y, p2.y);
    CGFloat width = ABS(p1.x - p2.x);
    CGFloat height = ABS(p1.y - p2.y);
    return CGRectMake(x, y, width, height);
}
CGRect CGRectWithPointsAndWidth(CGPoint p1, CGPoint p2, CGFloat width)
{
    
    CGFloat x = MIN(p1.x, p2.x) - width / 2;
    CGFloat y = MIN(p1.y, p2.y) - width / 2;
    width = ABS(p1.x - p2.x) + width;
    CGFloat height = ABS(p1.y - p2.y) + width;
    return CGRectMake(x, y, width, height);
}

CGSize CGSizeFromPBSize(PBSize *size)
{
    CGSize s = CGSizeZero;
    s.width = size.width;
    s.height = size.height;
    return s;
}

CGSize CGSizeFromPBSizeC(Game__PBSize *size)
{
    if (size == NULL)
        return CGSizeZero;
    
    CGSize s = CGSizeZero;
    s.width = size->width;
    s.height = size->height;
    return s;
}


CGRect CGRectFromCGSize(CGSize size)
{
    return CGRectMake(0, 0, size.width, size.height);
}

PBSize *CGSizeToPBSize(CGSize size)
{
    PBSize_Builder *builder = [[[PBSize_Builder alloc] init] autorelease];
    [builder setWidth:size.width];
    [builder setHeight:size.height];
    return [builder build];
}

void CGSizeToPBSizeC(CGSize size, Game__PBSize* pbSizeC)
{
    pbSizeC->has_height = 1;
    pbSizeC->height = size.height;
    pbSizeC->has_width = 1;
    pbSizeC->width = size.width;
}

CGSize CGSizeRand(NSUInteger maxWidth, NSUInteger maxHeight)
{
    return CGSizeMake(rand()%maxWidth, rand()%maxHeight);
}

void CGRectEnlarge(CGRect *rect, CGFloat xLength, CGFloat yLength)//enlarge and hode the center
{
    rect->origin.x -= xLength;
    rect->origin.y -= yLength;
    
    rect->size.width += 2 * xLength;
    rect->size.height += 2 * yLength;
}