//
//  PathConstructor.m
//  Draw
//
//  Created by gamy on 13-6-5.
//
//

#import "PathConstructor.h"
#import "DrawUtils.h"

@implementation PathConstructor

- (CGPathRef)path
{
    return _path;
}

- (void)dealloc
{
    PPCGPathRelease(_path);
    [super dealloc];
}

- (void)finishAddPoint
{
    
}

@end


@implementation RectanglePathConstructor


- (void)addPoint:(CGPoint)p
{
    if (_hasAddPoint) {
        _endPoint = p;
    }else{
        _startPoint = _endPoint = p;
        _hasAddPoint = YES;
    }
}

- (CGPathRef)createPathWithXList:(CGFloat *)xList yList:(CGFloat *)yList count:(NSUInteger)count
{
    if (count < 2) {
        return NULL;
    }
    CGPoint p1 = CGPointMake(xList[0], yList[0]);
    CGPoint p2 = CGPointMake(xList[1], yList[1]);
    CGRect rect = CGRectWithPoints(p1, p2);
    return CGPathCreateWithRect(rect, NULL);    
}

- (CGPathRef)path
{
    PPCGPathRelease(_path);
    CGRect rect = CGRectWithPoints(_startPoint, _endPoint);
    _path = CGPathCreateWithRect(rect, NULL);
    return _path;
}


@end


@implementation EllipsePathConstructor

- (CGPathRef)createPathWithXList:(CGFloat *)xList yList:(CGFloat *)yList count:(NSUInteger)count
{
    if (count < 2) {
        return NULL;
    }
    
    CGPoint p1 = CGPointMake(xList[0], yList[0]);
    CGPoint p2 = CGPointMake(xList[1], yList[1]);
    CGRect rect = CGRectWithPoints(p1, p2);
    return CGPathCreateWithEllipseInRect(rect, NULL);
}


- (void)addPoint:(CGPoint)p
{
    if (_hasAddPoint) {
        _endPoint = p;
    }else{
        _startPoint = _endPoint = p;
        _hasAddPoint = YES;
    }
}

- (CGPathRef)path
{
    PPCGPathRelease(_path);
    CGRect rect = CGRectWithPoints(_startPoint, _endPoint);
    _path = CGPathCreateWithEllipseInRect(rect, NULL);
    return _path;
}

@end

@implementation PolygenPathConstructor

- (CGPathRef)createPathWithXList:(CGFloat *)xList yList:(CGFloat *)yList count:(NSUInteger)count
{
    CGMutablePathRef path = CGPathCreateMutable();
    if (count > 0) {
        CGPathMoveToPoint(path, NULL, xList[0],yList[0]);

        for (int k = 1; k < count; k++) {
            CGPathAddLineToPoint(path, NULL, xList[k], yList[k]);
        }        
    }
    return path;
}


- (void)addPoint:(CGPoint)p
{
    if (_hasAddPoint) {
        CGPathAddLineToPoint(_path, NULL, p.x, p.y);
    }else{
        _hasAddPoint = YES;
        _path = CGPathCreateMutable();
        CGPathMoveToPoint(_path, NULL, p.x, p.y);
    }
}

- (CGPathRef)path
{
    return _path;
}



@end


#pragma mark - SmoothQuadCurvePathConstructor

#define SQC_POINT_COUNT     3

#define DOUBLE_MIN          (0.000001f)

BOOL threeInOneLine1(CGPoint a, CGPoint b, CGPoint c)
{
    // TODO to be optimized later
    double area = (a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y)) / 2.0f;
    return (fabs(area) < 0.0000001f);
}


@interface SmoothQuadCurvePathConstructor()
{
    CGPoint pts[SQC_POINT_COUNT];
    int ptsCount;
    BOOL ptsComplete;
    BOOL _startAddPoint;
    BOOL _hasPoint;
}

@end

@implementation SmoothQuadCurvePathConstructor

- (void)reset
{
    ptsComplete = NO;
    ptsCount = 0;
    _startAddPoint = NO;
    _hasPoint = NO;
    _hasAddPoint = NO;
    PPCGPathRelease(_path);
}

- (CGPathRef)createPathWithXList:(CGFloat *)xList yList:(CGFloat *)yList count:(NSUInteger)count
{
    for(int i = 0; i < count; i ++){
        CGPoint point = CGPointMake(xList[i], yList[i]);
        [self addPoint:point];
    }
    CGPathRef path = CGPathCreateCopy(_path);
    [self reset];
    return path;

}
- (void)addPoint:(CGPoint)p
{
    if (_hasAddPoint) {
        
    }else{
        _hasAddPoint = YES;
        _path = CGPathCreateMutable();
    }
    _hasPoint = YES;
    
    pts[ptsCount] = p;
    ptsCount ++;
    ptsComplete = NO;
    if (ptsCount == SQC_POINT_COUNT){
        
        if (threeInOneLine1(pts[0], pts[1], pts[2])){
            CGPathAddLineToPoint((CGMutablePathRef)_path, NULL, pts[2].x, pts[2].y);
        }
        else{
            CGPoint mid2 = CGPointMid(pts[1], pts[2]);
            CGPathAddQuadCurveToPoint((CGMutablePathRef)_path, NULL, pts[1].x, pts[1].y, mid2.x, mid2.y);
            
        }
        
        ptsComplete = YES;
        pts[0] = pts[1];
        pts[1] = pts[2];
        ptsCount = 2;
        
        _startAddPoint = NO;    // at least one line is added
    }
    else if (_startAddPoint && ptsCount == 1){
        CGPathMoveToPoint((CGMutablePathRef)_path, NULL, pts[0].x, pts[0].y);
        CGPathAddQuadCurveToPoint((CGMutablePathRef)_path, NULL, pts[0].x, pts[0].y, pts[0].x, pts[0].y);
    }
    else if (_startAddPoint && ptsCount == 2){
        CGPoint mid1 = CGPointMid(pts[0], pts[1]);
        CGPathAddQuadCurveToPoint((CGMutablePathRef)_path, NULL, pts[0].x, pts[0].y, mid1.x, mid1.y);
    }
    
}

- (CGPathRef)path
{
    return _path;
}

@end


id<PathConstructorProtocol> getPathConstructorByPathConstructType(PathConstructType type)
{
    switch (type) {
        case PathConstructTypeRectangle:
            return [[[RectanglePathConstructor alloc] init] autorelease];

        case PathConstructTypeEllipse:
            return [[[EllipsePathConstructor alloc] init] autorelease];

        case PathConstructTypePolygon:
            return [[[PolygenPathConstructor alloc] init] autorelease];

        case PathConstructTypeSmoothPath:
            return [[[SmoothQuadCurvePathConstructor alloc] init] autorelease];
            
        default:
            return nil;
    }
}