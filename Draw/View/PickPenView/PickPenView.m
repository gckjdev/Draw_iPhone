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
#import "DeviceDetection.h"

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
    CAAnimation *runOut = [AnimationManager scaleAnimationWithFromScale:1 toScale:0.00001 duration:RUN_OUT_TIME delegate:self removeCompeleted:NO];
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
        widthButtonArray  = [[NSMutableArray alloc] init];
        self.userInteractionEnabled = YES;
        UIButton *addColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addColorButton.frame = ADD_BUTTON_FRAME;
        addColorButton.center = ADD_BUTTON_CENTER;
        [addColorButton addTarget:self action:@selector(clickAddColorButton:) forControlEvents:UIControlEventTouchUpInside];
        [addColorButton setBackgroundImage:[[ShareImageManager defaultManager]addColorImage] forState:UIControlStateNormal];
        [self addSubview:addColorButton];
//        addColorButton.hidden = YES; //hide the add button this version
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
- (void)updatePickPenView
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
        [self updatePickPenView];
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
- (void)updatePickPenView:(ColorView *)lastUsedColorView
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
            [colorViewArray removeObject:lastUsedColorView];
            [colorViewArray insertObject:lastUsedColorView atIndex:INSERT_INDEX];
        }
    }
    [self updatePickPenView];
    
    
//    if (lastUsedColorView && [colorViewArray count] >= INSERT_INDEX) {
//        [lastUsedColorView setScale:ColorViewScaleSmall];
//        NSInteger index = [self indexOfColorView:lastUsedColorView];
//        if (index == -1) {
//            //the color view not in the list
//            [colorViewArray removeLastObject];
//            
//            ColorView *newColorView = [ColorView colorViewWithDrawColor:lastUsedColorView.drawColor 
//                                                                  scale:ColorViewScaleSmall];
//            
//            [colorViewArray insertObject:newColorView atIndex:INSERT_INDEX];
//            [self updatePickPenView];
//        }else if(index > INSERT_INDEX){
//            //if the color the last list, move it to the first position
//            [colorViewArray removeObject:lastUsedColorView];
//            [colorViewArray insertObject:lastUsedColorView atIndex:INSERT_INDEX];
//            [self updatePickPenView];
//        }else{
//            //if the color is the const color, don't move
//        }
//    }else{
//        [colorViewArray addObject:lastUsedColorView];
//        [self updatePickPenView];
//    }
}
@end
