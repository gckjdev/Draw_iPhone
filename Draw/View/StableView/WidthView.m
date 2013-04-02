//
//  WidthView.m
//  DrawViewTest
//
//  Created by  on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WidthView.h"
#import "ConfigManager.h"

@implementation WidthView

@synthesize width = _width;

#define SIZE  ([ConfigManager maxPenWidth] + 2)
//#define MIN_WIDTH  (([DeviceDetection isIPAD]) ? 4 : 2)

+ (id)viewWithWidth:(CGFloat)width
{
    
    return [[[WidthView alloc] initWithWidth:width]autorelease];
}

- (id)initWithWidth:(CGFloat)width
{
    self = [self initWithFrame:CGRectMake(0, 0, SIZE, SIZE)];
    if (self) {
        self.width = width;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setWidth:(CGFloat)width
{
    _width = width;
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();    
    if (self.selected) {
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    }else{
        CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
    }

    CGFloat showWidth = self.width;

    if (showWidth < 10) {
        showWidth += 3;
    }
    CGFloat x = (SIZE - showWidth) / 2.0;
    CGRect r = CGRectMake(x, x, showWidth, showWidth);
    CGContextFillEllipseInRect(context, r);
}

+ (CGFloat)height
{
    return SIZE;
}

+ (CGFloat)width
{
    return SIZE;
}


@end
