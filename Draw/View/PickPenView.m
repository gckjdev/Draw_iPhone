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

//- (void)dismiss
//{
//    CAAnimation *animation = [AnimationManager missingAnimationWithDuration:2];
//    animation.delegate = self;
//    [self.layer addAnimation:animation forKey:@"dismiss"];
//}

- (void)selectWidthButton:(UIButton *)button
{
    for (UIButton *button in widthButtonArray) {
        [button setSelected:NO];
    }
    [button setSelected:YES];
    self.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedLineWidth:)]) {
        [self.delegate didPickedLineWidth:button.tag];
    }
    
}

- (void)clickButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self selectWidthButton:button];
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
    CGFloat space = (self.frame.size.height - totalHeight) / ([widthArray count] + 2);
    CGFloat y = 0;
    _currentWidth = 1000;
    UIButton *selectedButton = nil;
    for (NSNumber *width in widthArray) {
        UIButton *button = [self addAndSetButtonWithWidth:width.integerValue];
        CGFloat x = self.frame.size.width / 5.0;
        y += space;
        if (width.integerValue < 7) {
            button.frame = CGRectMake(x, y, 7, 7);            
        }else{
            button.frame = CGRectMake(x, y, width.integerValue , width.integerValue);
        }
        y += width.integerValue;
        [button setCenter:CGPointMake(25, button.center.y)];
        if (width.integerValue < _currentWidth) {
            _currentWidth = width.integerValue;
            selectedButton = button;
        }
        [self selectWidthButton:selectedButton];
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
