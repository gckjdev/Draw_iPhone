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
        CGContextSaveGState(context);

        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        CGPoint points[2];
        points[0] = self.startPoint;
        points[1] = self.endPoint;
        CGContextStrokeLineSegments(context, points, 2);
        
        CGContextRestoreGState(context);
    }
}

@end
