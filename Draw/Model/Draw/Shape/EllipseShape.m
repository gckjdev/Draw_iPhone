//
//  EllipseShape.m
//  Draw
//
//  Created by gamy on 13-2-28.
//
//

#import "EllipseShape.h"

@implementation EllipseShape
- (void)drawInContext:(CGContextRef)context
{
    if (context != NULL) {
        CGContextSaveGState(context);
        
        if (self.stroke) {
            CGContextSetStrokeColorWithColor(context, self.color.CGColor);
            CGContextStrokeEllipseInRect(context, self.rect);
        }else{
            CGContextSetFillColorWithColor(context, self.color.CGColor);
            CGContextFillEllipseInRect(context, self.rect);
        }
        CGContextRestoreGState(context);
    }
}

@end
