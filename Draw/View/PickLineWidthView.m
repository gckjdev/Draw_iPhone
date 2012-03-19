//
//  PickLineWidthView.m
//  Draw
//
//  Created by  on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PickLineWidthView.h"

@implementation PickLineWidthView
@synthesize backgroudView = _backgroundView;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        buttonArray = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

- (void)dealloc
{
    [buttonArray release];
}

- (void)clickButton:(id)sender
{
    NSInteger tag = [(UIButton *)sender tag];
//    NSLog(@"width = %d",tag);
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedLineWidth:)]) {
        [self.delegate didPickedLineWidth:tag];
    }
}

- (void)removeAllButtons
{
    for (UIButton *button in buttonArray) {
        [button removeFromSuperview];
    }
    [buttonArray removeAllObjects];
}

- (UIButton *)addAndSetButtonWithWidth:(NSInteger)width
{
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor grayColor];
    button.tag = width;
    [self addSubview:button];
    [buttonArray addObject:button];
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setLineWidths:(NSArray *)widthArray
{
    [self removeAllButtons];
    CGFloat lineWidth = self.frame.size.width * 3.0 / 5.0;
    CGFloat totalHeight = 0;
    for (NSNumber *width in widthArray) {
        totalHeight += width.integerValue;
    }
    CGFloat space = (self.frame.size.height - totalHeight) / ([widthArray count] + 1);
    CGFloat y = 0;
    for (NSNumber *width in widthArray) {
        UIButton *button = [self addAndSetButtonWithWidth:width.integerValue];
        CGFloat x = self.frame.size.width / 5.0;
        y += space;
        button.frame = CGRectMake(x, y, lineWidth, width.integerValue);
        y += width.integerValue;
    }
}

//- (id)init
//{
//    self = [super initWithFrame:<#(CGRect)#>
//    if () {
//        <#statements#>
//    }
//}



@end
