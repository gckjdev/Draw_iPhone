//
//  DashPen.m
//  Draw
//
//  Created by gamy on 13-2-22.
//
//

#import "DashPen.h"

@implementation DashPen


- (id)init
{
    self = [super init];
    if (self) {
        PPDebug(@"Create %@ pen", [self name]);
    }
    return self;
}

- (void)updateCGContext:(CGContextRef)context paint:(Paint *)paint
{
    [super updateCGContext:context paint:paint];
    if (paint) {
        CGFloat lengths[] = {50, 50};
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
