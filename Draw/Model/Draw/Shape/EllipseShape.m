//
//  EllipseShape.m
//  Draw
//
//  Created by gamy on 13-2-28.
//
//

#import "EllipseShape.h"

@implementation EllipseShape


- (CGPathRef)path
{
    if (_path == NULL) {
        _path = CGPathCreateWithEllipseInRect(self.rect, NULL);
    }
    return _path;
}


- (void)drawInContext:(CGContextRef)context
{
    if (context != NULL) {
        CGContextSaveGState(context);
        
        if (_stroke) {
            CGContextSetLineWidth(context, self.width);            
            CGContextSetStrokeColorWithColor(context, self.color.CGColor);
            CGContextStrokeEllipseInRect(context, self.rect);
        }else{
            CGContextSetFillColorWithColor(context, self.color.CGColor);
            CGContextFillEllipseInRect(context, self.rect);
        }
        
//        CGContextSetLineWidth(context, 2);
//        CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
//        CGContextStrokeRect(context, self.rect);

        
        CGContextRestoreGState(context);
    }
}

@end
