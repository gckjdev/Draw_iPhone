//
//  StarShape.m
//  Draw
//
//  Created by gamy on 13-2-28.
//
//

#import "StarShape.h"

#define T  0.3819660112501
#define TSLP(x,y) CGPointMake((x)+1,1-(y)) //外五边形的坐标转换
#define TSLP1(x,y) CGPointMake((x*T)+1,1-(y*T)) //内五边形的坐标转换

@implementation StarShape
- (void)drawInContext:(CGContextRef)context
{
    if (context != NULL) {
        
        CGContextSaveGState(context);
        
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        
        CGRect rect = [self rect];
        
        
        CGFloat minX = CGRectGetMinX(rect);
        CGFloat minY = CGRectGetMinY(rect);
        
        
        CGFloat width = CGRectGetWidth(rect);
        CGFloat height = CGRectGetHeight(rect);

        static const float R1 = 0.1 * M_PI;
        static const float R3 = 0.3 * M_PI;


        CGPoint P1[10] = {};
        
        //外五边形的点
        P1[0] = TSLP(0, 1);
        P1[2] = TSLP(cosf(R1), sinf(R1));
        P1[4] = TSLP(cosf(R3), -sinf(R3));
        P1[6] = TSLP(-cosf(R3), -sinf(R3));
        P1[8] = TSLP(-cosf(R1), sinf(R1));

        //内五边形的点

        P1[1] = TSLP1(cosf(R3), sinf(R3));
        P1[3] = TSLP1(cosf(R1), -sinf(R1));
        P1[5] = TSLP1(0, -1);
        P1[7] = TSLP1(-cosf(R1), -sinf(R1));
        P1[9] = TSLP1(-cosf(R3), sinf(R3));
        
        for (int i = 0; i < 10; ++ i) {

            if (self.startPoint.y > self.endPoint.y){
                P1[i].y = 2 - P1[i].y;
            }
            
            P1[i].x = P1[i].x * width/2 + minX;
            P1[i].y = P1[i].y * height/2 + minY;
            
            if (i == 0) {
                CGContextMoveToPoint(context, P1[i].x, P1[i].y);
            }else{
                CGContextAddLineToPoint(context, P1[i].x, P1[i].y);
            }
            
        }
        
        CGContextClosePath(context);
        
        if (self.stroke) {
            CGContextSetLineWidth(context, self.width);
            CGContextSetLineJoin(context, kCGLineJoinMiter);
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
