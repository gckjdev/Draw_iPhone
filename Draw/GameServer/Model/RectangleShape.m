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
        
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        CGContextFillRect(context, self.rect);
        
        CGContextRestoreGState(context);
    }
}

@end
