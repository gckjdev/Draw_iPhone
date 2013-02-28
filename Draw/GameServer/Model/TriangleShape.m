//
//  Triangle.m
//  Draw
//
//  Created by gamy on 13-2-28.
//
//

#import "TriangleShape.h"

@implementation TriangleShape

- (void)drawInContext:(CGContextRef)context
{
    if (context != NULL) {
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        CGRect rect = [self rect];
        
        if (self.startPoint.y > self.endPoint.y) {
            CGContextMoveToPoint(context, CGRectGetMidX(rect), CGRectGetMaxY(rect));
            CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
        }else{
            CGContextMoveToPoint(context, CGRectGetMidX(rect), CGRectGetMinY(rect));
            CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
        }
        CGContextClosePath(context);
        CGContextFillPath(context);
        
        CGContextRestoreGState(context);
    }
}

@end
