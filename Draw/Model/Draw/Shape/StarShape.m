//
//  StarShape.m
//  Draw
//
//  Created by gamy on 13-2-28.
//
//

#import "StarShape.h"

@implementation StarShape
- (void)drawInContext:(CGContextRef)context
{
    if (context != NULL) {
        
        CGContextSaveGState(context);
        
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        
        CGRect rect = [self rect];
        
        CGFloat xRatio = 0.5 * (1 - tanf(0.2 * M_PI));
        CGFloat yRatio = 0.5 * (1 - tanf(0.1 * M_PI));
        
        CGFloat minX = CGRectGetMinX(rect);
        CGFloat minY = CGRectGetMinY(rect);
        
        CGFloat maxX = CGRectGetMaxX(rect);
        CGFloat maxY = CGRectGetMaxY(rect);
        CGFloat width = CGRectGetWidth(rect);
        CGFloat height = CGRectGetHeight(rect);
        
        if (self.startPoint.y > self.endPoint.y /*&& ![self point1:self.startPoint equalToPoint:self.endPoint]*/) {
            CGContextMoveToPoint(context, minX, maxY - yRatio * height);
            CGContextAddLineToPoint(context, maxX, maxY - yRatio * height);
            CGContextAddLineToPoint(context, minX + xRatio * width, minY);
            CGContextAddLineToPoint(context, minX + width / 2, maxY);
            CGContextAddLineToPoint(context, maxX - xRatio * width, minY);
        }else{
            CGContextMoveToPoint(context, minX, minY + yRatio * height);
            CGContextAddLineToPoint(context, maxX, minY + yRatio * height);
            CGContextAddLineToPoint(context, minX + xRatio * width, maxY);
            CGContextAddLineToPoint(context, minX + width / 2, minY);
            CGContextAddLineToPoint(context, maxX - xRatio * width, maxY);
        }
        CGContextClosePath(context);
//        CGContextFillPath(context);
        
        if (self.stroke) {
            CGContextSetLineWidth(context, self.width);
            CGContextSetStrokeColorWithColor(context, self.color.CGColor);
            CGContextStrokePath(context);
        }else{
            CGContextSetFillColorWithColor(context, self.color.CGColor);
            CGContextFillPath(context);
        }

        CGContextRestoreGState(context);
    }
}

@end
