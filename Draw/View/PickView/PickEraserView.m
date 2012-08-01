//
//  PickEraserView.m
//  Draw
//
//  Created by  on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PickEraserView.h"
#import "WidthView.h"

@implementation PickEraserView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        widthButtonArray  = [[NSMutableArray alloc] init];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (NSInteger)currentWidth
{
    return _currentWidth;
}



- (void)selectWidthButton:(WidthView *)button
{
    if (button == nil) {
        return;
    }
    for (UIButton *button in widthButtonArray) {
        [button setSelected:NO];
    }
    [button setSelected:YES];
    _currentWidth = button.width;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedPickView:lineWidth:)]) {
        [self.delegate didPickedPickView:self lineWidth:button.width];
    }
    [self startRunOutAnimation];
}

- (void)clickButton:(id)sender
{
    WidthView *button = (WidthView *)sender;
    [self selectWidthButton:button];
}

- (void)removeAllWidthButtons
{
    for (UIButton *button in widthButtonArray) {
        [button removeFromSuperview];
    }
    [widthButtonArray removeAllObjects];
}

- (void)resetWidth
{
    WidthView *wView = nil;
    CGFloat width = 999;
    for (WidthView *view in widthButtonArray) {
        if (view.width < width) {
            width = view.width;
            wView = view;
        }
    }
    [self selectWidthButton:wView];
}

#define LINE_START_X ([DeviceDetection isIPAD] ? 12 * 3 : 12)
#define LINE_START_Y ([DeviceDetection isIPAD] ? 6 * 2 : 5)

- (void)setLineWidths:(NSArray *)widthArray
{
    [self removeAllWidthButtons];
    CGFloat x = LINE_START_X;//self.frame.size.width / 10.0;
    CGFloat count = [widthArray count];
    CGFloat space = (self.frame.size.height - 10 - (count * [WidthView height])) / (count + 1);
    CGFloat y = LINE_START_Y;
    
    for (NSNumber *width in widthArray) {
        y +=  space;
        WidthView *widthView = [[WidthView alloc] initWithWidth:width.floatValue];
        widthView.frame = CGRectMake(x, y, [WidthView height], [WidthView height]);
        [self addSubview:widthView];
        [widthButtonArray addObject:widthView];
        [widthView release];
        [widthView addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        y += [WidthView height];
    }
    [self resetWidth];
}

- (void)setLineWidthHidden:(BOOL)hidden
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[WidthView class]]) {
            [view setHidden:hidden];
        }
    }
}


@end
