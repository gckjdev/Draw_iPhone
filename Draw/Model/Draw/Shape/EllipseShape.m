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
        
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        CGContextFillEllipseInRect(context, self.rect);
                
        CGContextRestoreGState(context);
    }
}

@end
