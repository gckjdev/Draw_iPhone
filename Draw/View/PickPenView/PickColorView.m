//
//  PickColorView.m
//  Draw
//
//  Created by  on 12-4-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PickColorView.h"
#import "ShareImageManager.h"
#import "ColorView.h"
#import <QuartzCore/QuartzCore.h>
#import "WidthView.h"

@implementation PickColorView



#define ADD_BUTTON_FRAME ([DeviceDetection isIPAD] ? CGRectMake(0, 0, 32 * 2, 34 * 2) : CGRectMake(0, 0, 32, 34))

#define ADD_BUTTON_CENTER ([DeviceDetection isIPAD] ? CGPointMake(650.84,204) : CGPointMake(276, 82))

- (void)clickAddColorButton:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedMoreColor)]) {
        [self.delegate didPickedMoreColor];
    }
    [self startRunOutAnimation];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIButton *addColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addColorButton.frame = ADD_BUTTON_FRAME;
        addColorButton.center = ADD_BUTTON_CENTER;
        [addColorButton addTarget:self action:@selector(clickAddColorButton:) forControlEvents:UIControlEventTouchUpInside];
        [addColorButton setBackgroundImage:[[ShareImageManager defaultManager]addColorImage] forState:UIControlStateNormal];
        [self addSubview:addColorButton];
    }
    return self;
}
/*
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
*/
#pragma mark - init colorView


- (void)clickColorView:(id)sender
{
    ColorView *colorView = (ColorView *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedColorView:)]) {
        [self.delegate didPickedColorView:colorView];
    }
    [self startRunOutAnimation];
}


- (void)removeAllColorViews
{
    for (ColorView *colorView in colorViewArray) {
        [colorView removeFromSuperview];
    }
}

#define BUTTON_COUNT_PER_ROW 5

#define PEN_STATR_X ([DeviceDetection isIPAD] ? 78 * 2: 70)
#define PEN_STATR_Y ([DeviceDetection isIPAD] ? 10 * 5 : 15)
- (void)updatePickColorView
{
    
    for (ColorView *colorView in colorViewArray) {
        [colorView removeFromSuperview];
    }
    
    CGFloat baseX = PEN_STATR_X;
    CGFloat baseY = PEN_STATR_Y;            
    CGFloat w = self.frame.size.width - baseX;
    CGFloat space = w  / (3.0 * BUTTON_COUNT_PER_ROW );
    if ([DeviceDetection isIPAD]) {
        space = w  / (3.0 * BUTTON_COUNT_PER_ROW - 4);
    }
    CGFloat x = 0, y = 0;
    int l = 0, r = 0;
    for (ColorView *colorView in colorViewArray) {
        CGFloat width = colorView.frame.size.width;
        CGFloat height= colorView.frame.size.height;
        x = baseX + width / 2 + (width + space) * r;
        y = baseY + height / 2 + (height + space) * l ;
        colorView.center = CGPointMake(x, y);
        r = (r+1) % BUTTON_COUNT_PER_ROW;
        if (r == 0) {
            l ++;
        }
        [self addSubview:colorView];
        [colorView addTarget:self action:@selector(clickColorView:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setColorViews:(NSArray *)colorViews
{
    if (colorViews != colorViewArray) {
        [self removeAllColorViews];
        [colorViewArray release];
        colorViewArray = [NSMutableArray arrayWithArray:colorViews];
        [colorViewArray retain];
        [self updatePickColorView];
    } 
}
- (NSArray *)colorViews
{
    return colorViewArray;
}
- (NSInteger)indexOfColorView:(ColorView *)colorView
{
    if (colorView) {
        int i = 0;
        for (ColorView *view in colorViewArray) {
            if ([view isEqual:colorView]) {
                return i;
            }
            ++ i;
        }
    }
    return -1;
}

#define INSERT_INDEX 5
#define COLOR_SIZE 9
- (void)updatePickColorView:(ColorView *)lastUsedColorView
{
    if (lastUsedColorView == nil) {
        return;
    }
    NSInteger index = [self indexOfColorView:lastUsedColorView];
    if (index == -1) {
        if ([colorViewArray count] >= COLOR_SIZE) {
            [colorViewArray removeLastObject];
        }
        ColorView *newColorView = [ColorView colorViewWithDrawColor:lastUsedColorView.drawColor 
                                                              scale:ColorViewScaleSmall];
        [colorViewArray insertObject:newColorView atIndex:INSERT_INDEX];
    }else{
        if (index > INSERT_INDEX) {
            ColorView *newColorView = [ColorView 
                                       colorViewWithDrawColor:lastUsedColorView.drawColor 
                                                        scale:ColorViewScaleSmall];
            [colorViewArray removeObject:lastUsedColorView];
            [colorViewArray insertObject:newColorView atIndex:INSERT_INDEX];
        }
    }
    [self updatePickColorView];    
}
@end
