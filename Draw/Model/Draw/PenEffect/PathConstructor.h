//
//  PathConstructor.h
//  Draw
//
//  Created by gamy on 13-6-5.
//
//

#import <Foundation/Foundation.h>
#import "PointNode.h"

typedef enum{
    
    PathConstructTypeRectangle = 1,
    PathConstructTypeEllipse = 2,
    PathConstructTypePolygon = 3,
    PathConstructTypeSmoothPath = 4,
    
}PathConstructType;

@protocol PathConstructorProtocol <NSObject>

//New method add by Gamy 2013-6-5 used in Setting Action

- (CGPathRef)createPathWithXList:(CGFloat *)xList yList:(CGFloat *)yList count:(NSUInteger)count;
- (void)addPoint:(CGPoint)p;
- (void)finishAddPoint;
- (CGPathRef)path;

@end


@interface PathConstructor : NSObject
{
    CGPathRef _path;
    BOOL _hasAddPoint;
}

- (CGPathRef)path;

@end

@interface RectanglePathConstructor : PathConstructor<PathConstructorProtocol>
{
    CGPoint _startPoint;
    CGPoint _endPoint;
}
@end

@interface EllipsePathConstructor : PathConstructor<PathConstructorProtocol>
{
    CGPoint _startPoint;
    CGPoint _endPoint;
}
@end

@interface PolygenPathConstructor : PathConstructor<PathConstructorProtocol>
{
    
    
}
@end

@interface SmoothQuadCurvePathConstructor : PathConstructor<PathConstructorProtocol>
{
    
}
@end


extern id<PathConstructorProtocol> getPathConstructorByPathConstructType(PathConstructType type);

