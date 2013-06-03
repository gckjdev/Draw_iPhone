//
//  BeelineShape.m
//  Draw
//
//  Created by gamy on 13-2-28.
//
//

#import "BeelineShape.h"

@implementation BeelineShape


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
        
        if (_stroke) {
            static float len[2] = {0};
            len[0] = len[1] = self.width;
            CGContextSetLineDash(context, 0, len, 2);
//            CGContextSetLineJoin(context, kCGLineJoinMiter);
            CGContextSetLineCap(context, kCGLineCapButt);
        }
        CGContextStrokeLineSegments(context, points, 2);
        CGContextRestoreGState(context);
    }
}

@end
