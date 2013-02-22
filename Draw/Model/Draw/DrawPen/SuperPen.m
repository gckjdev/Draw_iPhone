//
//  SuperPen.m
//  Draw
//
//  Created by gamy on 13-2-22.
//
//

#import "SuperPen.h"
#import "Paint.h"

@implementation SuperPen

- (DrawPenType)penType
{
    return 0;
}

- (NSString *)name
{
    return @"SuperPen";
}

- (void)updateCGContext:(CGContextRef)context paint:(Paint *)paint
{
    if (paint) {
        CGContextSetLineWidth(context, paint.width);
        CGContextSetStrokeColorWithColor(context, paint.color.CGColor);
    }
    
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
}

- (id)init
{
    self = [super init];
    if (self) {
        PPDebug(@"Create %@ pen", [self name]);
    }
    return self;

}

@end
