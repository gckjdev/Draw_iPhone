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

@implementation PickPenView
@synthesize delegate = _delegate;
@synthesize backgroudView = _backgroundView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor yellowColor]];
        widthButtonArray  = [[NSMutableArray alloc] init];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (NSInteger)currentWidth
{
    return _currentWidth;
}

- (void)clickButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    for (UIButton *button in widthButtonArray) {
        [button setSelected:NO];
    }
    [button setSelected:YES];
    [self setHidden:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedLineWidth:)]) {
        [self.delegate didPickedLineWidth:button.tag];
    }
}

- (void)removeAllWidthButtons
{
    for (UIButton *button in widthButtonArray) {
        [button removeFromSuperview];
    }
    [widthButtonArray removeAllObjects];
}

- (UIButton *)addAndSetButtonWithWidth:(NSInteger)width
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = width;
    ShareImageManager *imageManager = [ShareImageManager defaultManager];

    [button setBackgroundImage:[imageManager unSelectedPointImage] 
                      forState:UIControlStateNormal];
    [button setBackgroundImage:[imageManager selectedPointImage] 
                      forState:UIControlStateSelected];

    [self addSubview:button];
    [widthButtonArray addObject:button];
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setLineWidths:(NSArray *)widthArray
{
    [self removeAllWidthButtons];
    CGFloat totalHeight = 0;
    for (NSNumber *width in widthArray) {
        totalHeight += width.integerValue;
    }
    CGFloat space = (self.frame.size.height - totalHeight) / ([widthArray count] + 1);
    CGFloat y = 0;
    _currentWidth = 1000;
    UIButton *selectedButton = nil;
    for (NSNumber *width in widthArray) {
        UIButton *button = [self addAndSetButtonWithWidth:width.integerValue];
        CGFloat x = self.frame.size.width / 5.0;
        y += space;
        button.frame = CGRectMake(x, y, width.integerValue + 3, width.integerValue + 3);
        y += width.integerValue;
        [button setCenter:CGPointMake(25, button.center.y)];
        if (width.integerValue < _currentWidth) {
            _currentWidth = width.integerValue;
            selectedButton = button;
        }
        [self clickButton:selectedButton];
    }
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
