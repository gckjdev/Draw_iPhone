//
//  PointNode.h
//  Draw
//
//  Created by gamy on 13-1-23.
//
//

#import <Foundation/Foundation.h>

@interface HPointList : NSObject
{
}

- (void)addPoint:(float)x y:(float)y;
- (float)getPointX:(int)index;
- (float)getPointY:(int)index;
- (CGPoint)lastPoint;
- (int)count;
- (CGPoint)pointAtIndex:(int)index;
- (void)createPointXList:(NSMutableArray**)pointXList pointYList:(NSMutableArray**)pointYList;
- (void)createPointFloatXList:(CGFloat*)floatXList floatYList:(CGFloat*)floatYList;


@end

