//
//  SmoothQuadCurvePen.m
//  Draw
//
//  Created by qqn_pipi on 13-1-19.
//
//

#import "SmoothQuadCurvePen.h"

#define SQC_POINT_COUNT     3

@interface SmoothQuadCurvePen()
{
    CGMutablePathRef _path;

    CGPoint pts[SQC_POINT_COUNT];
    int ptsCount;
    BOOL ptsComplete;
    BOOL _startAddPoint;
    BOOL _hasPoint;
}

@end

@implementation SmoothQuadCurvePen

- (id)init
{
    PPDebug(@"<init> %@", [self description]);

    self = [super init];
    _path = CGPathCreateMutable();
    [self clearPoints];
    _startAddPoint = YES;
    return self;
}

- (void)dealloc
{
    PPDebug(@"<dealloc> %@", [self description]);
    
    RELEASE_PATH(_path);
    [super dealloc];
}

- (BOOL)hasPoint
{
    return _hasPoint;
}

- (void)clearPoints
{
    for (int i=0; i<SQC_POINT_COUNT; i++){
        pts[i] = CGPointZero;
    }
    
    ptsCount = 0;
    ptsComplete = NO;
    _hasPoint = NO;
}

- (void)constructPath:(NSArray*)pointList
{
    PPDebug(@"<constructPath> point count=%d", [pointList count]);
    [self startAddPoint];
    
    int pointCount = [pointList count];
    
    if (pointCount > 0) {
                
        for (int i=0; i<pointCount; i++){
            NSValue *value = [pointList objectAtIndex:i];
            CGPoint point  = [value CGPointValue];
            [self addPointIntoPath:point];
        }
        
    }

    [self finishAddPoint];
}

- (CGPathRef)penPath
{
    return _path;
}

- (void)startAddPoint
{
    _startAddPoint = YES;
    [self finishAddPoint];
}

- (void)addPointIntoPath:(CGPoint)point
{
    _hasPoint = YES;
    
    pts[ptsCount] = point;
    ptsCount ++;
    ptsComplete = NO;
    if (ptsCount == SQC_POINT_COUNT){
        
        CGPoint mid1 = MID_POINT(pts[0], pts[1]);
        CGPoint mid2 = MID_POINT(pts[1], pts[2]);                
        CGPathMoveToPoint(_path, NULL, mid1.x, mid1.y);
        CGPathAddQuadCurveToPoint(_path, NULL, pts[1].x, pts[1].y, mid2.x, mid2.y);

        ptsComplete = YES;
        pts[0] = pts[1];
        pts[1] = pts[2];
        ptsCount = 2;
        
        _startAddPoint = NO;    // at least one line is added
        
    }
    else if (_startAddPoint && ptsCount == 1){
        CGPathMoveToPoint(_path, NULL, pts[0].x, pts[0].y);
        CGPathAddQuadCurveToPoint(_path, NULL, pts[0].x, pts[0].y, pts[0].x, pts[0].y);
    }
    else if (_startAddPoint && ptsCount == 2){
        CGPoint mid1 = MID_POINT(pts[0], pts[1]);
        CGPathAddQuadCurveToPoint(_path, NULL, pts[0].x, pts[0].y, mid1.x, mid1.y);
    }
    
}

- (void)finishAddPoint
{
}

@end
