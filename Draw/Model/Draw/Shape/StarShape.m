//
//  StarShape.m
//  Draw
//
//  Created by gamy on 13-2-28.
//
//

#import "StarShape.h"

#define TSLP(x,y) CGPointMake((x)+1,1-(y))

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

        static const float R1 = 0.1 * M_PI;
        static const float R3 = 0.3 * M_PI;

        
        if (self.startPoint.y > self.endPoint.y /*&& ![self point1:self.startPoint equalToPoint:self.endPoint]*/) {
            CGContextMoveToPoint(context, minX, maxY - yRatio * height);
            CGContextAddLineToPoint(context, maxX, maxY - yRatio * height);
            CGContextAddLineToPoint(context, minX + xRatio * width, minY);
            CGContextAddLineToPoint(context, minX + width / 2, maxY);
            CGContextAddLineToPoint(context, maxX - xRatio * width, minY);
        }else{
/*
            CGPoint P1[5] = {};
            
            P1[0] = TSLP(0, 1);
            P1[1] = TSLP(cosf(R1), sinf(R1));
            P1[2] = TSLP(cosf(R3), -sinf(R3));
            P1[3] = TSLP(-cosf(R3), -sinf(R3));
            P1[4] = TSLP(-cosf(R1), sinf(R1));
            
            for (int i = 0; i < 5; ++ i) {
                P1[i].x = P1[i].x * width/2 + minX;
                P1[i].y = P1[i].y * height/2 + minY;
                if (i == 0) {
                    CGContextMoveToPoint(context, P1[i].x, P1[i].y);
                }else{
                    CGContextAddLineToPoint(context, P1[i].x, P1[i].y);
                }
            }
            
     */       
/* */
            CGContextMoveToPoint(context, minX, minY + yRatio * height);
            CGContextAddLineToPoint(context, maxX, minY + yRatio * height);
            CGContextAddLineToPoint(context, minX + xRatio * width, maxY);
            CGContextAddLineToPoint(context, minX + width / 2, minY);
            CGContextAddLineToPoint(context, maxX - xRatio * width, maxY);
/* */
        }
        CGContextClosePath(context);
//        CGContextFillPath(context);
        
        if (self.stroke) {
            CGContextSetLineWidth(context, self.width);
            CGContextSetLineJoin(context, kCGLineJoinMiter);
            CGContextSetStrokeColorWithColor(context, self.color.CGColor);
            CGContextStrokePath(context);
        }else{
            CGContextSetFillColorWithColor(context, self.color.CGColor);
            CGContextFillPath(context);
        }
        CGContextSetLineWidth(context, 2);
        CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
        CGContextStrokeRect(context, rect);
        CGContextRestoreGState(context);
    }
}

@end
