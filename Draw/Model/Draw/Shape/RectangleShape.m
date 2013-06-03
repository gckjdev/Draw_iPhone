//
//  RectangleShape.m
//  Draw
//
//  Created by gamy on 13-2-28.
//
//

#import "RectangleShape.h"

@implementation RectangleShape
- (void)drawInContext:(CGContextRef)context
{
    if (context != NULL) {
        CGContextSaveGState(context);
        
        if (self.isStroke) {
            CGContextSetLineWidth(context, self.width);
            CGContextSetStrokeColorWithColor(context, self.color.CGColor);
            CGContextStrokeRect(context, self.rect);
        }else{
            CGContextSetFillColorWithColor(context, self.color.CGColor);
            CGContextFillRect(context, self.rect);
        }

        
        CGContextRestoreGState(context);
    }
}

@end
