//
//  PickPenView.m
//  Draw
//
//  Created by  on 12-4-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PickPenView.h"
#import "ShareImageManager.h"
#import "ColorView.h"
#import "AnimationManager.h"
#import <QuartzCore/QuartzCore.h>
#import "WidthView.h"

@implementation PickPenView
@synthesize delegate = _delegate;
@synthesize backgroudView = _backgroundView;


#define ADD_BUTTON_FRAME CGRectMake(0, 0, 32, 34)
#define ADD_BUTTON_CENTER CGPointMake(267, 72)

- (void)clickAddColorButton:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedMoreColor)]) {
        [self.delegate didPickedMoreColor];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        widthButtonArray  = [[NSMutableArray alloc] init];
        self.userInteractionEnabled = YES;
        UIButton *addColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addColorButton.frame = ADD_BUTTON_FRAME;
        addColorButton.center = ADD_BUTTON_CENTER;
        [addColorButton addTarget:self action:@selector(clickAddColorButton:) forControlEvents:UIControlEventTouchUpInside];
        [addColorButton setImage:[[ShareImageManager defaultManager]addColorImage] forState:UIControlStateNormal];
        [self addSubview:addColorButton];
        addColorButton.hidden = YES; //hide the add button this version
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
    self.hidden = YES;
    _currentWidth = button.width;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedLineWidth:)]) {
        [self.delegate didPickedLineWidth:button.width];
    }
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

- (void)setLineWidths:(NSArray *)widthArray
{
    [self removeAllWidthButtons];
    CGFloat x = 12;//self.frame.size.width / 10.0;
    CGFloat count = [widthArray count];
    CGFloat space = (self.frame.size.height - 10 - (count * [WidthView height])) / (count + 1);
    CGFloat y = 5;
    
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

#pragma mark - init colorView


- (void)clickColorView:(id)sender
{
    [self setHidden:YES];
    ColorView *colorView = (ColorView *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedColorView:)]) {
        [self.delegate didPickedColorView:colorView];
    }
}


- (void)removeAllColorViews
{
    for (ColorView *colorView in colorViewArray) {
        [colorView removeFromSuperview];
    }
}

#define BUTTON_COUNT_PER_ROW 5

- (void)setColorViews:(NSArray *)colorViews
{
    if (colorViews != colorViewArray) {
        [self removeAllColorViews];
        [colorViewArray release];
        colorViewArray = colorViews;
        [colorViewArray retain];
        CGFloat baseX = 78;
        CGFloat baseY = 10;            
        CGFloat w = self.frame.size.width - baseX;
        CGFloat space = w  / (3.0 * BUTTON_COUNT_PER_ROW + 5);
        CGFloat x = 0, y = 0;
        int l = 0, r = 0;
        for (ColorView *colorView in colorViews) {
            CGFloat width = colorView.frame.size.width;
            CGFloat height= colorView.frame.size.height;
            x = baseX + width / 2 + (width + space) * r;
            y = baseY + height / 2 + (height + space) * l ;
            colorView.center = CGPointMake(x, y);
            NSLog(@"(%d,%d):center(%f,%f)",r,l,x,y);
            r = (r+1) % BUTTON_COUNT_PER_ROW;
            if (r == 0) {
                l ++;
            }
            
            [self addSubview:colorView];
            [colorView addTarget:self action:@selector(clickColorView:) forControlEvents:UIControlEventTouchUpInside];
        }
    } 
}


@end
