//
//  PointNode.m
//  Draw
//
//  Created by gamy on 13-1-23.
//
//

#import "PointNode.h"

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

@end
