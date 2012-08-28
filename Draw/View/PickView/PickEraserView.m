//
//  PickEraserView.m
//  Draw
//
//  Created by  on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PickEraserView.h"
#import "WidthView.h"

@implementation PickEraserView


#define MIN_WIDTH ([DeviceDetection isIPAD] ? 2 : 2)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        widthArray  = [[NSMutableArray alloc] init];
        self.userInteractionEnabled = YES;
        
        if ([DeviceDetection isIPAD]) {
            [widthArray addObject:[NSNumber numberWithInt:21 * 2]];
            [widthArray addObject:[NSNumber numberWithInt:14 * 2]];
            [widthArray addObject:[NSNumber numberWithInt:7 * 2]];
        }else{
            [widthArray addObject:[NSNumber numberWithInt:21]];
            [widthArray addObject:[NSNumber numberWithInt:14]];
            [widthArray addObject:[NSNumber numberWithInt:7]];
        }
        [widthArray addObject:[NSNumber numberWithInt:MIN_WIDTH]];
        [self updateLineViews];
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
    for (NSNumber *width in widthArray) {
        WidthView *view = (WidthView *)[self viewWithTag:width.intValue];
        view.selected = NO;
    }
    [button setSelected:YES];
    _currentWidth = button.width;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedPickView:lineWidth:)]) {
        [self.delegate didPickedPickView:self lineWidth:button.width];
    }
}


- (void)updateLineViews
{
    CGFloat x = 0;
    CGFloat count = [widthArray count];
    
    if (count == 0) {
        return;
    }else if(count == 1)
    {
        NSNumber *width = [widthArray objectAtIndex:0];
        WidthView *widthView = [[WidthView alloc] initWithWidth:width.floatValue];
        widthView.center = self.center;
        [self addSubview:widthView];
        [widthView release];
        return;
    }
    
    CGFloat space = (self.frame.size.height - (count * [WidthView height])) / (count - 1);
    CGFloat y = 0;
    
    for (NSNumber *width in widthArray) {
        WidthView *widthView = [[WidthView alloc] initWithWidth:width.floatValue];
        widthView.frame = CGRectMake(x, y, [WidthView height], [WidthView height]);
        widthView.tag = width.intValue;
        [self addSubview:widthView];

        [widthView release];
        [widthView addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        y += [WidthView height] + space;
    }

    WidthView *view = (WidthView *)[self viewWithTag:MIN_WIDTH];
    [self selectWidthButton:view];
}


- (void)clickButton:(id)sender
{
    WidthView *button = (WidthView *)sender;
    [self selectWidthButton:button];
}



- (void)setLineWidthHidden:(BOOL)hidden
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[WidthView class]]) {
            [view setHidden:hidden];
        }
    }
}


@end
