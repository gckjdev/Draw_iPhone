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
        
        NSUInteger blur = paint.width/2;
        //set blur
        PPDebug(@"blur = %d",blur);
        DrawColor *temp = [DrawColor colorWithColor:paint.color];
        CGContextSetShadowWithColor(context, CGSizeMake(0.001,0.001), blur, temp.CGColor);
        CGContextSetLineWidth(context, paint.width);
        CGContextSetStrokeColorWithColor(context, temp.CGColor);
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
