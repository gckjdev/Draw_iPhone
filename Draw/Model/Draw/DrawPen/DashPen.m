//
//  DashPen.m
//  Draw
//
//  Created by gamy on 13-2-22.
//
//

#import "DashPen.h"

@implementation DashPen


- (void)updateCGContext:(CGContextRef)context paint:(Paint *)paint
{
    if (paint) {
        CGContextSetLineWidth(context, paint.width);
        CGContextSetStrokeColorWithColor(context, paint.color.CGColor);
        
        CGFloat lengths[] = {3,3};
        CGContextSetLineDash(context, 0, lengths, 2);    
    }
}

- (DrawPenType)penType
{
    return DrawPenTypeDash;
}

- (UIImage *)penImage
{
    return nil;
}

- (NSString *)name
{
    return NSLS(@"kDashPen");
}

- (NSString *)desc
{
    return NSLS(@"kDashPenDesc");
}

@end
