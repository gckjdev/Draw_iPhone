//
//  WidthView.m
//  DrawViewTest
//
//  Created by  on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WidthView.h"

@implementation WidthView

@synthesize width = _width;


#define SIZE 40

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
    
    CGFloat x = (SIZE - _width) / 2;
    CGFloat showWidth = self.width + 3;
    CGRect r = CGRectMake(x, x, showWidth, showWidth);
    CGContextFillEllipseInRect(context, r);
}


@end
