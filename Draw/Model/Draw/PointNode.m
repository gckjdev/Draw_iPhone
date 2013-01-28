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
    NSInteger ret = ([DrawUtils roundFloatValue:self.x] * (1 << 15)) + [DrawUtils roundFloatValue:self.y];
    return ret;
}

- (NSInteger)toCompressPointWithXScale:(CGFloat)xScale yScale:(CGFloat)yScale
{
    NSInteger ret = ([DrawUtils roundFloatValue:self.x * xScale] * (1 << 15)) + [DrawUtils roundFloatValue:self.y * yScale];
    return ret;
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
    return [PointNode pointWithCGPoint:self.point];
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
