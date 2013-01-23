//
//  PointNode.h
//  Draw
//
//  Created by gamy on 13-1-23.
//
//

#import <Foundation/Foundation.h>

@class PBPoint;

@interface PointNode : NSObject
{
//    CGPoint _point;
}
//@property(nonatomic, assign) CGFloat x;
//@property(nonatomic, assign) CGFloat y;

@property(nonatomic, assign)CGPoint point;

- (CGFloat)x;
- (CGFloat)y;
- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;

//- (void)setPoint:(CGPoint)point;
//- (CGPoint)point;
+ (id)pointWithCGPoint:(CGPoint)point;
+ (id)pointWithPBPoint:(PBPoint *)point;
- (NSInteger)toCompressPoint;
- (NSInteger)toCompressPointWithXScale:(CGFloat)xScale yScale:(CGFloat)yScale;
- (PBPoint *)toPBPoint;
- (PointNode *)scaleX:(CGFloat)scale;
- (PointNode *)scaleY:(CGFloat)scale;
- (id)copy;
+ (PointNode *)illegalPoint;
+ (PointNode *)zeroPoint;
- (BOOL)equalsToPoint:(PointNode *)point;
- (CGFloat)distancWithPoint:(PointNode *)point;
@end

