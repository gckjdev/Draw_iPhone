//
//  BeelineShape.m
//  Draw
//
//  Created by gamy on 13-2-28.
//
//

#import "BeelineShape.h"

@implementation BeelineShape


- (CGPathRef)path
{
    if (_path == NULL) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, self.startPoint.x, self.startPoint.y);
        CGPathAddLineToPoint(path, NULL, self.endPoint.x, self.endPoint.y);
        _path = path;
    }
    return _path;
}

- (void)drawInContext:(CGContextRef)context
{
    if (context != NULL) {
        [self rect]; //just cal the redraw rect
        CGContextSaveGState(context);

        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        CGContextSetLineWidth(context, self.width);
        
        CGPoint points[2];
        points[0] = self.startPoint;
        points[1] = self.endPoint;
        

        CGContextStrokeLineSegments(context, points, 2);
        CGContextRestoreGState(context);
    }
}

@end
