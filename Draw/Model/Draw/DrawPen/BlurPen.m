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
    [super updateCGContext:context paint:paint];
    if (paint) {
        
        NSUInteger blur = 20;//rand() % (NSInteger)paint.width;
        //set blur
//        CGContextSetShadowWithColor(context, CGSizeMake(0, 5), 5, paint.color.CGColor);
//        CGContextSetShadowWithColor(context, CGSizeMake(0, -5), 5, paint.color.CGColor);
//        CGContextSetShadowWithColor(context, CGSizeMake(5, 0), 5, paint.color.CGColor);
        PPDebug(@"blur = %d",blur);
        
        CGContextSetShadowWithColor(context, CGSizeMake(0.1,0.1), blur, paint.color.CGColor);
        CGContextSetLineWidth(context, 1);
        CGContextSetStrokeColorWithColor(context, paint.color.CGColor);
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
