//
//  DefaultPen.m
//  Draw
//
//  Created by gamy on 13-2-22.
//
//

#import "DefaultPen.h"

@implementation DefaultPen

- (void)updateCGContext:(CGContextRef)context paint:(Paint *)paint
{
    [super updateCGContext:context paint:paint];
    if (paint) {

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
    return NSLS(@"kDefaultPen");
}

- (NSString *)desc
{
    return NSLS(@"kDefaultPenDesc");
}

@end
