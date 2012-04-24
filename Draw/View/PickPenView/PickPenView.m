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


#define RUN_OUT_TIME 0.2
#define RUN_IN_TIME 0.2

- (void)startRunOutAnimation
{
    if (self.hidden) {
        return;
    }
    CAAnimation *runOut = [AnimationManager scaleAnimationWithFromScale:1 toScale:0.1 duration:RUN_OUT_TIME delegate:self removeCompeleted:NO];
    [runOut setValue:@"runOut" forKey:@"AnimationKey"];
    [self.layer addAnimation:runOut forKey:@"runOut"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* value = [anim valueForKey:@"AnimationKey"];
    if ([value isEqualToString:@"runOut"]) {
        [super setHidden:YES];
    }
}


- (void)startRunInAnimation
{
    [super setHidden:NO];
    CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:RUN_IN_TIME delegate:self removeCompeleted:NO];
    [self.layer addAnimation:runIn forKey:@"runIn"];

}


- (void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (hidden == self.hidden) {
        return;
    }
    
    if (!animated) {
        [super setHidden:hidden];
        return;
    }
    if (hidden == YES) {
        [self startRunOutAnimation];
    }else{    
        [self startRunInAnimation];
    }
    
}

//- (void)showInView:(UIView *)view
//{
//    [view addSubview:self];
//    [self startRunInAnimation];
//}

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
    _currentWidth = button.width;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedLineWidth:)]) {
        [self.delegate didPickedLineWidth:button.width];
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
//    [self setHidden:YES];
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
