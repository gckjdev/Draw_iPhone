//
//  SmoothQuadCurvePen.m
//  Draw
//
//  Created by qqn_pipi on 13-1-19.
//
//

#import "SmoothQuadCurvePen.h"
#import "DrawUtils.h"

#define SQC_POINT_COUNT     3

#define DOUBLE_MIN          (0.000001f)

BOOL threeInOneLine(CGPoint a, CGPoint b, CGPoint c)
{
    // TODO to be optimized later
    double area = (a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y)) / 2.0f;
    return (fabs(area) < 0.0000001f);
}


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
//    PPDebug(@"<init> %@", [self description]);

    self = [super init];
    _path = CGPathCreateMutable();
//    [self clearPoints];               // all data is zero by default, no need to clear? set by Benson
    _startAddPoint = YES;
    return self;
}

- (void)dealloc
{
//    PPDebug(@"<dealloc> %@", [self description]);
    
    RELEASE_PATH(_path);
    [super dealloc];
}

- (BOOL)hasPoint
{
    return _hasPoint;
}

- (void)clearPoints
{
//    for (int i=0; i<SQC_POINT_COUNT; i++){
//        pts[i] = CGPointZero;
//    }
    
    memset(pts, 0, sizeof(pts));
    
    ptsCount = 0;
    ptsComplete = NO;
    _hasPoint = NO;
}

- (void)constructPath:(HPointList*)pointList inRect:(CGRect)rect
{
//    PPDebug(@"<constructPath>");
    
    BOOL checkPoint = !CGRectEqualToRect(rect, CGRectZero);
    
    [self startAddPoint];
    
    int pointCount = [pointList count];
    
    if (pointCount > 0) {
        
//        for (int i=0; i<pointCount; i++){
//            PointNode *node = [pointList objectAtIndex:i];
//            if (!checkPoint || [node pointInRect:rect]) {
//                [self addPointIntoPath:node.point];
//            }
//            
//            
//            
//        }
    
        for (int i=0; i<pointCount; i++){
            CGPoint nodePoint = [pointList pointAtIndex:i];
            if (!checkPoint || [DrawUtils pointInRect:rect inputPoint:&nodePoint]) {
                [self addPointIntoPath:nodePoint];
            }
        }
    
    }

    [self finishAddPoint];
}

//- (void)constructPath:(NSArray*)pointList inRect:(CGRect)rect
//{
//
//    BOOL checkPoint = !CGRectEqualToRect(rect, CGRectZero);
//
//    [self startAddPoint];
//    
//    int pointCount = [pointList count];
//    
//    if (pointCount > 0) {
//                
//        for (int i=0; i<pointCount; i++){
//            PointNode *node = [pointList objectAtIndex:i];
//            if (!checkPoint || [node pointInRect:rect]) {
//                [self addPointIntoPath:node.point];
//            }
//        
//        }
//        
//    }
//
//    [self finishAddPoint];
//}

- (CGPathRef)penPath
{
    return _path;
}

- (void)startAddPoint
{
    _startAddPoint = YES;
    [self clearPoints];
}

/*
#define RECT_SPAN_WIDTH 2
- (BOOL)spanRect:(CGRect)rect ContainsPoint:(CGPoint)point
{
    rect.origin.x -= RECT_SPAN_WIDTH;
    rect.origin.y -= RECT_SPAN_WIDTH;
    rect.size.width += RECT_SPAN_WIDTH*2;
    rect.size.height += RECT_SPAN_WIDTH*2;
    return CGRectContainsPoint(rect, point);
}
*/

- (void)printPoints
{
    NSString* str = @"";
    for (int i=0; i<ptsCount; i++){
        str = [str stringByAppendingFormat:@" [%d]=[%@]", i, NSStringFromCGPoint(pts[i])];
    }
    
    PPDebug(@"pts = %@", str);
}

- (void)addPointIntoPath:(CGPoint)point
{
    /* move to [Paint addPoint]
    CGRect rect = DRAW_VIEW_RECT;
    if (!CGRectContainsPoint(rect, point)){
        //add By Gamy
        //we can change point(304.1,320.4) to point(304,320)
        //this point is not incorrect, but mistake.
        if (![self spanRect:rect ContainsPoint:point]) {
            PPDebug(@"<addPointIntoPath> Detect Incorrect Point = %@, Skip It", NSStringFromCGPoint(point));
            return;
        }
        point.x = MAX(point.x, 0);
        point.y = MAX(point.y, 0);
        point.x = MIN(point.x, DRAW_VIEW_WIDTH);
        point.y = MIN(point.y, DRAW_VIEW_HEIGHT);
    }
    */
    
    _hasPoint = YES;
    
    pts[ptsCount] = point;
    ptsCount ++;
    ptsComplete = NO;
    
   //  [self printPoints];
    
    if (ptsCount == SQC_POINT_COUNT){
        
        if (threeInOneLine(pts[0], pts[1], pts[2])){
//            PPDebug(@"threeInOneLine=YES");
            CGPathAddLineToPoint(_path, NULL, pts[2].x, pts[2].y);
        }
        else{
//            PPDebug(@"threeInOneLine=NO");
            CGPoint mid2 = MID_POINT(pts[1], pts[2]);
            CGPathAddQuadCurveToPoint(_path, NULL, pts[1].x, pts[1].y, mid2.x, mid2.y);

        }
        
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
    /*
    if (ptsComplete == YES){
        // add last point
        PPDebug(@"<Add Last Point>");
        if (threeInOneLine(pts[0], pts[1], pts[2])){
            CGPathAddLineToPoint(_path, NULL, pts[2].x, pts[2].y);
        }
        else{
            CGPathAddQuadCurveToPoint(_path, NULL, pts[1].x, pts[1].y, pts[2].x, pts[2].y);
        }
    }
    else if (ptsCount == 1){
        // do nothing
    }
    else if (ptsCount == 2){
        if (!_startAddPoint){
            // add last point
            CGPoint mid1 = MID_POINT(pts[0], pts[1]);
            CGPathAddQuadCurveToPoint(_path, NULL, mid1.x, mid1.y, pts[1].x, pts[1].y);
        }
    }
    */
}

@end
