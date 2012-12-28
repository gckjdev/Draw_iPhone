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



#define WIDTH_COUNT ([DeviceDetection isIPAD]?5:5)
#define DEFAULT_WIDTH 10
+ (NSInteger *)widthValues
{
    static NSInteger iPhoneList[] = {24,16,8,4,2};
    static NSInteger iPadList[] = {32,16,8,4,2};
    return [DeviceDetection isIPAD] ? iPadList : iPhoneList;
}

+ (NSInteger *)showWidthValues
{
    static NSInteger iPhoneList[] = {23,17,12,7,4};
    static NSInteger iPadList[] = {36,28,20,12,5};
    return [DeviceDetection isIPAD] ? iPadList : iPhoneList;
}

+ (NSInteger)defaultWidth
{
    NSInteger *values = [WidthView widthValues];
    return values[2];
}

+ (NSInteger)showWidthForValue:(NSInteger)value
{
    NSInteger *values = [WidthView widthValues];
    int i = 0;
    for (; i < WIDTH_COUNT; ++ i) {
        if(value == values[i])
        {
            break;
        }
    }
    if (i <= WIDTH_COUNT) {
        NSInteger *showValues = [WidthView showWidthValues];
        return showValues[i];
    }
    return DEFAULT_WIDTH;
}


+ (NSMutableArray *)widthArray
{
    NSInteger *values = [WidthView widthValues];
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < WIDTH_COUNT; ++ i) {
        NSInteger value = values[i];
        NSNumber *number = [NSNumber numberWithInt:value];
        [array addObject:number];
    }
    return array;
}


#define SIZE  (([DeviceDetection isIPAD]) ? 27*2 : 27)
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
//    showWidth = [WidthView showWidthForValue:showWidth];
    CGFloat x = (SIZE - showWidth) / 2;
    CGRect r = CGRectMake(x, x, showWidth, showWidth);
    CGContextFillEllipseInRect(context, r);
    
//    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);    
//    CGContextStrokeRectWithWidth(context, self.bounds, 1);
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
