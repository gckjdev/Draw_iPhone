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
#import "CMPopTipView.h"
#import "DrawUtils.h"
@interface PickColorView()
{
    PickColorViewType _type;
    UIButton *addColorButton;
    NSMutableArray *colorViewArray;
    UIView *divideLine;
}
- (void)updatePickColorView;
- (void)setType:(PickColorViewType)type;
@end

@implementation PickColorView


#define DIVIDE_LINE_FRAME ([DeviceDetection isIPAD] ? CGRectMake(30 * IPAD_SCALE, IPAD_SCALE, IPAD_SCALE, 120 * IPAD_SCALE) : CGRectMake(35, 1, 1, 120))

#define ADD_BUTTON_FRAME ([DeviceDetection isIPAD] ? CGRectMake(0, 0, 32 * 2, 34 * 2) : CGRectMake(0, 0, 32, 34))

#define ADD_BUTTON_CENTER_PEN ([DeviceDetection isIPAD] ? CGPointMake(592,258.8) : CGPointMake(264, 105))

#define ADD_BUTTON_CENTER_BG ([DeviceDetection isIPAD] ? CGPointMake(536.8,258.8) : CGPointMake(216, 105))

#define INSERT_INDEX 5
#define COLOR_SIZE 14


- (void)clickAddColorButton:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedMoreColor)]) {
        [self.delegate didPickedMoreColor];
    }
}

- (void)dealloc
{
    [divideLine release];
    [colorViewArray release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame type:(PickColorViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _type = type;
        addColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addColorButton.frame = ADD_BUTTON_FRAME;
        [addColorButton addTarget:self action:@selector(clickAddColorButton:) forControlEvents:UIControlEventTouchUpInside];
        [addColorButton setBackgroundImage:[[ShareImageManager defaultManager]addColorImage] forState:UIControlStateNormal];
        [self addSubview:addColorButton];

        if (type == PickColorViewTypeBackground) {
            addColorButton.center = ADD_BUTTON_CENTER_BG;            
        }else{
            addColorButton.center = ADD_BUTTON_CENTER_PEN;
            
            divideLine = [[UIView alloc] initWithFrame:DIVIDE_LINE_FRAME];
            [divideLine setBackgroundColor:[UIColor grayColor]];
            [self addSubview:divideLine];

            
            colorViewArray = [[NSMutableArray alloc] init];
            [colorViewArray addObject:[ColorView blackColorView]];
            [colorViewArray addObject:[ColorView redColorView]];
            [colorViewArray addObject:[ColorView yellowColorView]];
            [colorViewArray addObject:[ColorView blueColorView]];
            [colorViewArray addObject:[ColorView whiteColorView]];
            NSArray *recentColors = [DrawColor getRecentColorList];
            if (recentColors ) {
                for (DrawColor *color in recentColors) {
                    ColorView *view = [ColorView colorViewWithDrawColor:color scale:ColorViewScaleSmall];
                    [colorViewArray addObject:view];
                    if ([colorViewArray count] >= COLOR_SIZE) {
                        break;
                    }
                }
            }
            [self updatePickColorView];
        }

    }
    return self;
}

- (void)setColorViews:(NSMutableArray *)colorViews
{
    if (colorViews == colorViewArray) {
        return;
    }
    colorViewArray = [colorViews retain];
}


#pragma mark - init colorView


- (void)clickColorView:(id)sender
{
    ColorView *colorView = (ColorView *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedPickView:colorView:)])
    {
        [self.delegate didPickedPickView:self colorView:colorView];
    }

}


- (void)removeAllColorViews
{
    for (ColorView *colorView in colorViewArray) {
        UIView* view = [colorView superview];
        if ([view respondsToSelector:@selector(clickColorView:)]) {
            [colorView removeTarget:view action:@selector(clickColorView:) 
                   forControlEvents:UIControlEventTouchUpInside];
        }
        [colorView removeFromSuperview];
    }
}

#define BUTTON_COUNT_PER_ROW 5

#define PEN_STATR_X ([DeviceDetection isIPAD] ? 58 * 2: 50)
#define STATR_Y 0

#define BG_STATR_X STATR_Y

- (void)updatePickColorView
{
    [self removeAllColorViews];    
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
        
    }else if(_type == PickColorViewTypePen){
        //show pen width
        [self setLineWidthHidden:NO];
    }else{
        
    }
    CGFloat baseY = STATR_Y;            
    CGFloat w = self.frame.size.width - baseX;
    CGFloat h = self.frame.size.height;
    CGFloat spaceX = (w - [ColorView widthForScale:ColorViewScaleSmall] 
                      * BUTTON_COUNT_PER_ROW) / (BUTTON_COUNT_PER_ROW - 1);

    
    int line = (COLOR_SIZE / BUTTON_COUNT_PER_ROW)+1;
    
    CGFloat spaceY = (h - [ColorView heightForScale:ColorViewScaleSmall] * line) / (line - 1);

    
    CGFloat x = 0, y = 0;
    int l = 0, r = 0;
    int i = 0;
    for (ColorView *colorView in colorViewArray) {
        CGFloat width = colorView.frame.size.width;
        CGFloat height= colorView.frame.size.height;
        x = baseX + width / 2 + (width + spaceX) * r;
        y = baseY + height / 2 + (height + spaceY) * l ;
        colorView.center = CGPointMake(x, y);
        PPDebug(@"index = %d, center = (%f,%f)",i++,x,y );
        r = (r+1) % BUTTON_COUNT_PER_ROW;
        if (r == 0) {
            l ++;
        }
        [self addSubview:colorView];
        [colorView addTarget:self action:@selector(clickColorView:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (NSMutableArray *)colorViews
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

@end



