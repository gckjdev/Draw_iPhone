//
//  PointNode.h
//  Draw
//
//  Created by gamy on 13-1-23.
//
//

#import <Foundation/Foundation.h>

@class PBPoint;

@interface PointNode : NSObject<NSCoding>
{
//    CGPoint _point;
}
//@property(nonatomic, assign) CGFloat x;
//@property(nonatomic, assign) CGFloat y;

@property(nonatomic, assign)CGPoint point;


- (BOOL)pointInRect:(CGRect)rect;
- (CGFloat)x;
- (CGFloat)y;
- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;

- (NSInteger)toCompressPoint;
- (NSInteger)toCompressPointWithXScale:(CGFloat)xScale yScale:(CGFloat)yScale;
- (PBPoint *)toPBPoint;
- (PointNode *)scaleX:(CGFloat)scale;
- (PointNode *)scaleY:(CGFloat)scale;
- (id)copy;

- (BOOL)equalsToPoint:(PointNode *)point;
- (CGFloat)distancWithPoint:(PointNode *)point;

- (id)initPointWithX:(CGFloat)x Y:(CGFloat)y;
+ (id)pointWithCGPoint:(CGPoint)point;
+ (id)pointWithPBPoint:(PBPoint *)point;
+ (PointNode *)illegalPoint;
+ (PointNode *)zeroPoint;

@end

