//
//  PointNode.m
//  Draw
//
//  Created by gamy on 13-1-23.
//
//

#import "PointNode.h"
#import "Draw.pb.h"
#import "DrawUtils.h"

@implementation PointNode


#define RECT_SPAN_WIDTH 10
- (BOOL)spanRect:(CGRect)rect ContainsPoint:(CGPoint)point
{
    rect.origin.x -= RECT_SPAN_WIDTH;
    rect.origin.y -= RECT_SPAN_WIDTH;
    rect.size.width += RECT_SPAN_WIDTH*2;
    rect.size.height += RECT_SPAN_WIDTH*2;
    return CGRectContainsPoint(rect, point);
}


- (BOOL)pointInRect:(CGRect)rect
{
    if (!CGRectContainsPoint(rect, _point)){

        if (![self spanRect:rect ContainsPoint:_point]) {
//            PPDebug(@"<addPoint> Detect Incorrect Point = %@, Skip It", NSStringFromCGPoint(_point));
            return NO;
        }
        _point.x = MAX(_point.x, 0);
        _point.y = MAX(_point.y, 0);
        _point.x = MIN(_point.x, CGRectGetWidth(rect));
        _point.y = MIN(_point.y, CGRectGetHeight(rect));
    }
    return YES;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeCGPoint:self.point forKey:@"CGPointKey"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.point = [aDecoder decodeCGPointForKey:@"CGPointKey"];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.point = CGPointZero;
    }
    return self;
}

- (CGFloat)x
{
    return _point.x;
}

- (CGFloat)y
{
    return _point.y;
}
- (void)setX:(CGFloat)x
{
    _point.x = x;
}
- (void)setY:(CGFloat)y
{
    _point.y = y;
}

+ (id)pointWithCGPoint:(CGPoint)point
{
    PointNode *node = [[[PointNode alloc] init] autorelease];
    [node setPoint:point];
    return node ;
}

+ (id)pointWithPBPoint:(PBPoint *)point
{
    PointNode *node = [[[PointNode alloc] init] autorelease];
    node.x = point.x;
    node.y = point.y;
    return node ;
}

- (NSInteger)toCompressPoint
{
    return [DrawUtils compressPointWithX:self.x y:self.y];
}

- (NSInteger)toCompressPointWithXScale:(CGFloat)xScale yScale:(CGFloat)yScale
{
    return [DrawUtils compressPointWithX:self.x * xScale y:self.y * yScale];
//    NSInteger ret = ([DrawUtils roundFloatValue:self.x * xScale] * (1 << 15)) + [DrawUtils roundFloatValue:self.y * yScale];
//    return ret;
}

- (PBPoint *)toPBPoint
{
    PBPoint_Builder *builder = [[PBPoint_Builder alloc] init];
//    [builder clear];
    [builder setX:self.x];
    [builder setY:self.y];
    PBPoint *p = [builder build];
    PPRelease(builder);
    return p;
}

- (PointNode *)scaleX:(CGFloat)scale
{
    self.x *= scale;
    return self;
}
- (PointNode *)scaleY:(CGFloat)scale
{
    self.y *= scale;
    return self;
}

- (id)copy
{
    return [[PointNode pointWithCGPoint:self.point] retain];
}

- (BOOL)equalsToPoint:(PointNode *)point
{
    return self.x == point.x && self.y == point.y;
}

- (CGFloat)distancWithPoint:(PointNode *)point
{
    return sqrtf(powf(self.x - point.x, 2) + powf(self.y - point.y, 2));
}

+ (PointNode *)illegalPoint
{
    PointNode *illegal = [PointNode pointWithCGPoint:ILLEGAL_POINT];
    return illegal;
}
+ (PointNode *)zeroPoint
{
    PointNode *zero = [PointNode pointWithCGPoint:CGPointZero];
    return zero;
}
@end
