//
//  PickColorView.m
//  Draw
//
//  Created by  on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PickColorView.h"
#import "DrawColor.h"
@implementation PickColorView
@synthesize delegate = _delegate;
@synthesize backgroudView = _backgroundView;


- (void)dealloc
{
    [_backgroundView release], _backgroundView = nil;
    [_colorList release], _colorList = nil;
    [buttonArray release], buttonArray = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        buttonArray = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

- (void)didClickButton:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedColor:)]) {
        DrawColor *color = [_colorList objectAtIndex:button.tag];
        [self.delegate didPickedColor:color];
    }
}

- (UIButton *)addAndSetButtonWith:(DrawColor *)color
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color.color;
    [self addSubview:button];
    [buttonArray addObject:button];
    [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)removeAllButtons
{
    for (UIButton *button in buttonArray) {
        [button removeFromSuperview];
    }
    [buttonArray removeAllObjects];
}

#define BUTTON_COUNT_PER_ROW 4

- (void)setColorList:(NSArray *)colorList
{
    
    if (colorList != _colorList) {
        [_colorList release];
        _colorList = colorList;
        [_colorList retain];
    
        //create buttons and add buttons
        [self removeAllButtons];
        int i = 0;
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        
        NSInteger rowNumber = [colorList count] / BUTTON_COUNT_PER_ROW ;
        if ([colorList count] % BUTTON_COUNT_PER_ROW != 0) {
            rowNumber ++;
        }
        
        CGFloat space = w / (3.0 * BUTTON_COUNT_PER_ROW + 1);
        CGFloat width = 2 * space;
        CGFloat height = (h - (rowNumber + 1) * space) / rowNumber;
        int x = 0, y = 0;
        for (DrawColor *color in colorList) {
            UIButton *button = [self addAndSetButtonWith:color];
            button.tag = i ;
            if (i % BUTTON_COUNT_PER_ROW == 0) {
                y += space;
                x  = space;
                if (i != 0) {
                    y += height;
                }
            } else
            {
                x += space;
            }
            button.frame = CGRectMake(x, y, width, height);
            x += width;
            ++ i;
        }
        
    }
    
    
//    UIButton 
}

@end
