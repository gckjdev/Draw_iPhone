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
    [super updateCGContext:context paint:paint];
    if (paint) {
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
