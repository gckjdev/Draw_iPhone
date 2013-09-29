//
//  PointNode.m
//  Draw
//
//  Created by gamy on 13-1-23.
//
//

#import "HPointList.h"
#import "Draw.pb.h"
#import "DrawUtils.h"
#include <vector>

using std::vector;

@interface HPointList ()
{
    vector<float> xList;
    vector<float> yList;
}

@end

@implementation HPointList


//#define RECT_SPAN_WIDTH 10
//- (BOOL)spanRect:(CGRect)rect ContainsPoint:(CGPoint)point
//{
//    rect.origin.x -= RECT_SPAN_WIDTH;
//    rect.origin.y -= RECT_SPAN_WIDTH;
//    rect.size.width += RECT_SPAN_WIDTH*2;
//    rect.size.height += RECT_SPAN_WIDTH*2;
//    return CGRectContainsPoint(rect, point);
//}
//
//
//- (BOOL)pointInRect:(CGRect)rect
//{
//    if (!CGRectContainsPoint(rect, _point)){
//
//        if (![self spanRect:rect ContainsPoint:_point]) {
//            PPDebug(@"<pointInRect> Detect Incorrect Point = %@, Skip It", NSStringFromCGPoint(_point));
//            return NO;
//        }
//        _point.x = MAX(_point.x, 0);
//        _point.y = MAX(_point.y, 0);
//        _point.x = MIN(_point.x, CGRectGetWidth(rect));
//        _point.y = MIN(_point.y, CGRectGetHeight(rect));
//        PPDebug(@"<pointInRect> Change Point to %@", NSStringFromCGPoint(_point));
//    }
//    return YES;
//}
//
- (void)dealloc
{
    [super dealloc];
}

- (void)addPoint:(float)x y:(float)y
{
    xList.push_back(x);
    yList.push_back(y);
}

- (float)getPointX:(int)index
{
    return xList.at(index);
}

- (float)getPointY:(int)index
{
    return yList.at(index);
}

- (CGPoint)pointAtIndex:(int)index
{
    return CGPointMake(xList.at(index), yList.at(index));
}

- (int)count
{
    return xList.size();
}

- (void)createPointXList:(NSMutableArray**)pointXList pointYList:(NSMutableArray**)pointYList
{
    int size = xList.size();
    if (size > 0) {
        *pointXList = [[[NSMutableArray alloc] init] autorelease];
        *pointYList = [[[NSMutableArray alloc] init] autorelease];
        
        for (int i=0; i<size; i++){
            [*pointXList addObject:@(xList[i])];
            [*pointYList addObject:@(yList[i])];
        }        
    }    
}

- (void)createPointFloatXList:(CGFloat*)floatXList floatYList:(CGFloat*)floatYList
{
    int size = xList.size();
    if (size > 0) {        
        for (int i=0; i<size; i++){
            floatXList[i] = xList[i];
            floatYList[i] = yList[i];
        }
    }
}

- (CGPoint)lastPoint
{
    int index = xList.size();
    if (index <= 0){
        return ILLEGAL_POINT;
    }
    return CGPointMake(xList.at(index-1), yList.at(index-1));
}

//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeCGPoint:self.point forKey:@"CGPointKey"];
//}
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super init];
//    if (self) {
//        self.point = [aDecoder decodeCGPointForKey:@"CGPointKey"];
//    }
//    return self;
//}
//
//- (id)init
//{
//    self = [super init];
//    if (self) {
//        self.point = CGPointZero;
//    }
//    return self;
//}
//
//- (id)initPointWithX:(CGFloat)x Y:(CGFloat)y
//{
//    self = [super init];
//    _point.x = x;
//    _point.y = y;
//    return self;
//}
//
//- (CGFloat)x
//{
//    return _point.x;
//}
//
//- (CGFloat)y
//{
//    return _point.y;
//}
//- (void)setX:(CGFloat)x
//{
//    _point.x = x;
//}
//- (void)setY:(CGFloat)y
//{
//    _point.y = y;
//}
//
//+ (id)pointWithCGPoint:(CGPoint)point
//{
//    PointNode *node = [[[PointNode alloc] init] autorelease];
//    [node setPoint:point];
//    return node ;
//}
//
//+ (id)pointWithPBPoint:(PBPoint *)point
//{
//    PointNode *node = [[[PointNode alloc] init] autorelease];
//    node.x = point.x;
//    node.y = point.y;
//    return node ;
//}
//
//- (NSInteger)toCompressPoint
//{
//    return [DrawUtils compressPointWithX:self.x y:self.y];
//}
//
//- (NSInteger)toCompressPointWithXScale:(CGFloat)xScale yScale:(CGFloat)yScale
//{
//    return [DrawUtils compressPointWithX:self.x * xScale y:self.y * yScale];
//}
//
//- (PBPoint *)toPBPoint
//{
//    PBPoint_Builder *builder = [[PBPoint_Builder alloc] init];
//    [builder setX:self.x];
//    [builder setY:self.y];
//    PBPoint *p = [builder build];
//    PPRelease(builder);
//    return p;
//}
//
//- (PointNode *)scaleX:(CGFloat)scale
//{
//    self.x *= scale;
//    return self;
//}
//- (PointNode *)scaleY:(CGFloat)scale
//{
//    self.y *= scale;
//    return self;
//}
//
//- (id)copy
//{
//    return [[PointNode pointWithCGPoint:self.point] retain];
//}
//
//- (BOOL)equalsToPoint:(PointNode *)point
//{
//    return self.x == point.x && self.y == point.y;
//}
//
//- (CGFloat)distancWithPoint:(PointNode *)point
//{
//    return sqrtf(powf(self.x - point.x, 2) + powf(self.y - point.y, 2));
//}
//
//+ (PointNode *)illegalPoint
//{
//    PointNode *illegal = [PointNode pointWithCGPoint:ILLEGAL_POINT];
//    return illegal;
//}
//+ (PointNode *)zeroPoint
//{
//    PointNode *zero = [PointNode pointWithCGPoint:CGPointZero];
//    return zero;
//}

@end
