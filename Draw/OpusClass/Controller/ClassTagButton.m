//
//  OrderButton.m
//  ifengNewsOrderDemo
//
//  Created by zer0 on 14-2-27.
//  Copyright (c) 2014年 zer0. All rights reserved.
//

#import "SelectTagHeader.h"
#import "ClassTagButton.h"
#import "SelectOpusClassViewController.h"

@implementation ClassTagButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)buttonWithViewController:(UIViewController *)vc titleArr:(NSArray *)titleArr urlStringArr:(NSArray *)urlStringArr{
    ClassTagButton * orderButton = [ClassTagButton buttonWithType:UIButtonTypeCustom];
    [orderButton setVc:vc];
    [orderButton setTitleArr:titleArr];
    [orderButton setUrlStringArr:urlStringArr];
    [orderButton setImage:[UIImage imageNamed:KOrderButtonImage] forState:UIControlStateNormal];
    [orderButton setImage:[UIImage imageNamed:KOrderButtonImageSelected] forState:UIControlStateHighlighted];
    [orderButton setFrame:CGRectMake(KOrderButtonFrameOriginX, KOrderButtonFrameOriginY, KOrderButtonFrameSizeX, KOrderButtonFrameSizeY)];
    
    return orderButton;

}


- (void)dealloc
{
    [_vc release];
    [_titleArr release];
    [_urlStringArr release];
    [super dealloc];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
