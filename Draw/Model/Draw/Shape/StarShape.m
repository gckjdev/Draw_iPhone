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

#define P_LEN 10
CGPoint P[P_LEN];
BOOL hasInitPoints = NO;

void updateStartPoints(CGPoint *points, BOOL reverse){
    
    if (!hasInitPoints) {
        //外五边形的点
        static const float R1 = 0.1 * M_PI;
        static const float R3 = 0.3 * M_PI;
        
        P[0] = TSLP(0, 1);
        P[2] = TSLP(cosf(R1), sinf(R1));
        P[4] = TSLP(cosf(R3), -sinf(R3));
        P[6] = TSLP(-cosf(R3), -sinf(R3));
        P[8] = TSLP(-cosf(R1), sinf(R1));
        
        //内五边形的点
        P[1] = TSLP1(cosf(R3), sinf(R3));
        P[3] = TSLP1(cosf(R1), -sinf(R1));
        P[5] = TSLP1(0, -1);
        P[7] = TSLP1(-cosf(R1), -sinf(R1));
        P[9] = TSLP1(-cosf(R3), sinf(R3));
        hasInitPoints = YES;
    }
    for(int i = 0; i < P_LEN; ++ i){
        points[i].x = P[i].x;
        points[i].y = reverse ? (2 - P[i].y) : P[i].y;
    }
}


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

        CGPoint P1[P_LEN];
        updateStartPoints(P1, (self.startPoint.y > self.endPoint.y));
        
        for (int i = 0; i < P_LEN; ++ i) {

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
