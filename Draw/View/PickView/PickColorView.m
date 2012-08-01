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
#import "WidthView.h"
#import <QuartzCore/QuartzCore.h>


@implementation PickColorView



#define ADD_BUTTON_FRAME ([DeviceDetection isIPAD] ? CGRectMake(0, 0, 32 * 2, 34 * 2) : CGRectMake(0, 0, 32, 34))

#define ADD_BUTTON_CENTER_PEN ([DeviceDetection isIPAD] ? CGPointMake(650.84,204) : CGPointMake(276, 82))

#define ADD_BUTTON_CENTER_BG ([DeviceDetection isIPAD] ? CGPointMake(544.84,204) : CGPointMake(221, 82))

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
        addColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addColorButton.frame = ADD_BUTTON_FRAME;
        addColorButton.center = ADD_BUTTON_CENTER_PEN;
        [addColorButton addTarget:self action:@selector(clickAddColorButton:) forControlEvents:UIControlEventTouchUpInside];
        [addColorButton setBackgroundImage:[[ShareImageManager defaultManager]addColorImage] forState:UIControlStateNormal];
        [self addSubview:addColorButton];
        _type = PickColorViewTypePen;
    }
    return self;
}

#pragma mark - init colorView


- (void)clickColorView:(id)sender
{
    ColorView *colorView = (ColorView *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedPickView:colorView:)])
    {
        [self.delegate didPickedPickView:self colorView:colorView];
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
#define STATR_Y ([DeviceDetection isIPAD] ? 10 * 5 : 15)

#define BG_STATR_X STATR_Y

- (void)updatePickColorView
{
    
    for (UIView *colorView in self.subviews) {
        if ([colorView isKindOfClass:[ColorView class]]) {
            [colorView removeFromSuperview];            
        }
    }
    
    CGFloat baseX = PEN_STATR_X;
    if (_type == PickColorViewTypeBackground) {
        baseX = BG_STATR_X;
        //hidden pen width
        [self setLineWidthHidden:YES];
        [addColorButton setCenter:ADD_BUTTON_CENTER_BG];
        
    }else if(_type == PickColorViewTypePen){
        //show pen width
        [self setLineWidthHidden:NO];
        [addColorButton setCenter:ADD_BUTTON_CENTER_PEN];
    }else{
        
    }
    CGFloat baseY = STATR_Y;            
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
            ColorView *lastView = [colorViewArray lastObject];
            [lastView removeFromSuperview];
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

- (void)setType:(PickColorViewType)type
{
    _type = type;
    [self updatePickColorView];
    
}
- (PickColorViewType)type
{
    return _type;
}

//- (void)setHidden:(BOOL)hidden animated:(BOOL)animated
//{
//    if (!hidden) {
//        [self updatePickColorView];
//    }
//    [super setHidden:hidden animated:animated];
//}

@end


/*
#pragma mark - class PickBackgroundColorView

@implementation PickBackgroundColorView

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
        
    }
    return self;
}

#pragma mark - init colorView


- (void)clickColorView:(id)sender
{
    ColorView *colorView = (ColorView *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedPickView:colorView:)])
    {
        [self.delegate didPickedPickView:self colorView:colorView];
    }
    [self startRunOutAnimation];
}


- (void)removeAllColorViews
{
    for (ColorView *colorView in colorViewArray) {
        [colorView removeFromSuperview];
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

#define EDGE_SPACE ([DeviceDetection isIPAD] ? 10 * 5 : 15)

- (void)updatePickColorView
{
    for (ColorView *colorView in colorViewArray) {
        [colorView removeFromSuperview];
    }
    
    CGFloat baseX = EDGE_SPACE;
    CGFloat baseY = EDGE_SPACE;            
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

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (!hidden) {
        [self updatePickColorView];
    }
    [super setHidden:hidden animated:animated];
}

@end
 */