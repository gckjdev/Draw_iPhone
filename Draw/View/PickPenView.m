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

//- (void)setColorViews:(NSArray *)colorViews
//{
//    
//}

- (void)clickButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    for (UIButton *button in widthButtonArray) {
        [button setSelected:NO];
    }
    [button setSelected:YES];
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
    ColorView *colorView = (ColorView *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedColor:)]) {
//        DrawColor *color = [_colorList objectAtIndex:button.tag];
        [self.delegate didPickedColorView:colorView];
    }
}

- (UIButton *)addAndSetButtonWith:(DrawColor *)color
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    [self addSubview:button];
    [color addObject:button];
    [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//- (void)removeAllColorViews
//{
//    for (ColorView *colorView in colorViewArray) {
//        [colorView removeFromSuperview];
//    }
//    [colorViewArray removeAllObjects];
//}

#define BUTTON_COUNT_PER_ROW 5

- (void)setColorViews:(NSArray *)colorViews
{
    
    if (colorViews != colorViewArray) {
        [colorViewArray release];
        colorViewArray = colorViews;
        [colorViewArray retain];
        
        //create buttons and add buttons
//        [self removeAllColorViews];
        int i = 0;
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        
        NSInteger rowNumber = [colorViews count] / BUTTON_COUNT_PER_ROW ;
        if ([colorViews count] % BUTTON_COUNT_PER_ROW != 0) {
            rowNumber ++;
        }
        
        CGFloat space = w / (3.0 * BUTTON_COUNT_PER_ROW + 1);
//        CGFloat width = 2 * space;
//        CGFloat height = (h - (rowNumber + 1) * space) / rowNumber;

        CGFloat baseX = 50;
        CGFloat baseY = 20;    
        CGFloat x = 0, y = 0;
        int k  = 0;
        for (ColorView *colorView in colorViews) {
            CGFloat width = colorView.frame.size.width;
            CGFloat height= colorView.frame.size.height;
            x = baseX + width / 2 + (width + space) * (i++);
            y = baseY + height / 2;
        }
    }
        
}

@end
