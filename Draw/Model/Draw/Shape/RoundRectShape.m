//
//  RoundRectShape.m
//  Draw
//
//  Created by gamy on 13-5-30.
//
//

#import "RoundRectShape.h"


@interface RoundRectShape ()


@end


#define RADIUS 12

@implementation RoundRectShape


- (CGPathRef)path
{
    if (_path == NULL) {
        UIBezierPath *bp = [UIBezierPath bezierPathWithRoundedRect:self.rect cornerRadius:RADIUS];
        _path = bp.CGPath;
        CGPathRetain(_path);
    }
    return _path;
}

- (void)drawInContext:(CGContextRef)context
{
    
    CGRect rrect = [self rect];

    CGContextSaveGState(context);
    UIBezierPath *bp = [UIBezierPath bezierPathWithRoundedRect:rrect cornerRadius:RADIUS];

    if(self.isStroke){
        CGContextSetLineWidth(context, self.width);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        CGContextAddPath(context, bp.CGPath);
        CGContextStrokePath(context);
    }else{
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        CGContextAddPath(context, bp.CGPath);
        CGContextFillPath(context);
    }
    CGContextRestoreGState(context);
}

@end
