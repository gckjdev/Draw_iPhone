//
//  BlurPen.m
//  Draw
//
//  Created by gamy on 13-2-22.
//
//

#import "BlurPen.h"

@implementation BlurPen

- (void)updateCGContext:(CGContextRef)context paint:(Paint *)paint
{
    if (paint) {
        
        CGContextSetLineWidth(context, paint.width);
        CGContextSetStrokeColorWithColor(context, paint.color.CGColor);
        
        //set blur
        CGContextSetShadowWithColor(context, CGSizeMake(0, 3), 3, paint.color.CGColor);
        CGContextSetShadowWithColor(context, CGSizeMake(0, -3), 3, paint.color.CGColor);
        CGContextSetShadowWithColor(context, CGSizeMake(2, 0), 2, paint.color.CGColor);
        CGContextSetShadowWithColor(context, CGSizeMake(-2, 0), 2, paint.color.CGColor);
    }
}

- (DrawPenType)penType
{
    return DrawPenTypeBlur;
}


- (UIImage *)penImage
{
    return nil;
}

- (NSString *)name
{
    return NSLS(@"kBlurPen");
}

- (NSString *)desc
{
    return NSLS(@"kBlurPenDesc");
}
@end
