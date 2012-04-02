//
//  StableView.m
//  Draw
//
//  Created by  on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StableView.h"
#import "ShareImageManager.h"

@implementation ToolView
- (id)initWithNumber:(NSInteger)number
{
    self = [super initWithFrame:CGRectMake(0, 0, 39, 52)];
    if(self){
        self.userInteractionEnabled = NO;
        ShareImageManager *imageManager = [ShareImageManager defaultManager];
        [self setBackgroundImage:[imageManager toolImage] forState:UIControlStateNormal];
        numberButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [numberButton setFrame:CGRectMake(27, 10, 24, 24)];
        [numberButton setBackgroundImage:[imageManager toolNumberImage] forState:UIButtonTypeCustom];
        [numberButton setUserInteractionEnabled:NO];
        [self addSubview:numberButton];
        [self setNumber:number];
        [numberButton retain];
    }
    return self;
}

- (void)dealloc
{
    [numberButton release], numberButton = nil;
    [super dealloc];
}
- (void)setNumber:(NSInteger)number
{
    _number = number;
    NSString *numberString = nil;
    numberButton.hidden = YES;
    if (number > 0) {
        numberString = [NSString stringWithFormat:@"%d",number];    
        numberButton.hidden = NO;
    }
    [numberButton setTitle:numberString forState:UIControlStateNormal];
}
- (NSInteger)number
{
    return _number;
}

- (void)decreaseNumber
{
    [self setNumber:--_number];
}

- (void)addTarget:(id)target action:(SEL)action
{
    self.userInteractionEnabled = YES;
    [self addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}
@end
