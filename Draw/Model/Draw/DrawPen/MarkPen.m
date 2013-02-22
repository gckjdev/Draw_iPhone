//
//  MarkPen.m
//  Draw
//
//  Created by gamy on 13-2-22.
//
//

#import "MarkPen.h"

@implementation MarkPen

- (void)updateCGContext:(CGContextRef)context paint:(Paint *)paint
{
    if (paint) {
        
        CGContextSetLineWidth(context, paint.width);
        CGContextSetStrokeColorWithColor(context, paint.color.CGColor);
        
        //set mark
        CGContextSetLineCap(context, kCGLineCapSquare);
    }
}

- (DrawPenType)penType
{
    return DrawPenTypeMark;
}

- (UIImage *)penImage
{
    return nil;
}

- (NSString *)name
{
    return NSLS(@"kMarkPen");
}

- (NSString *)desc
{
    return NSLS(@"kMarkPenDesc");
}

@end
