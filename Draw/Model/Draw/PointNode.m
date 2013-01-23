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

- (void)setPoint:(CGPoint)point
{
    self.x = point.x;
    self.y = point.y;
}
- (CGPoint)point
{
    return CGPointMake(self.x, self.y);
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
    NSInteger ret = ([DrawUtils roundFloatValue:_x] * (1 << 15)) + [DrawUtils roundFloatValue:_y];
    return ret;
}

- (NSInteger)toCompressPointWithXScale:(CGFloat)xScale yScale:(CGFloat)yScale
{
    NSInteger ret = ([DrawUtils roundFloatValue:_x * xScale] * (1 << 15)) + [DrawUtils roundFloatValue:_y * yScale];
    return ret;
}

- (PBPoint *)toPBPoint
{
    PBPoint_Builder *builder = [[PBPoint_Builder alloc] init];
    [builder clear];
    [builder setX:_x];
    [builder setY:_y];
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
    PointNode *node = [[[PointNode alloc] init]autorelease];
    node.x = self.x;
    node.y = self.y;
    return node;
}

- (BOOL)equalsToPoint:(PointNode *)point
{
    return self.x == point.x && self.y == point.y;
}

- (CGFloat)distancWithPoint:(PointNode *)point
{
    return sqrtf(powf(_x - point.x, 2) + powf(_y - point.y, 2));
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
