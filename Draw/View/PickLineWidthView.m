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
    int i = 1;
    CGFloat lineWidth = self.frame.size.width * 3.0 / 5.0;
    CGFloat lineHeight = self.frame.size.height / ([widthArray count] * 2+ 1);
    
    for (NSNumber *width in widthArray) {
        UIButton *button = [self addAndSetButtonWithWidth:width.integerValue];
        CGFloat x = self.frame.size.width / 5.0;
        CGFloat y = lineHeight * i;
        i += 2;
        button.frame = CGRectMake(x, y, lineWidth, lineHeight);
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
