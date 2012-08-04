//
//  PickPenView.m
//  Draw
//
//  Created by  on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PickPenView.h"
#import "PenView.h"
#import "AccountService.h"
#import "ShoppingManager.h"

@implementation PickPenView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _penArray = [[NSMutableArray alloc] init];
        NSInteger price = [[ShoppingManager defaultManager] getPenPrice];
        for (int i = PenStartType; i < PenCount; ++ i) {
            PenView *pen = [PenView penViewWithType:i];
            pen.price = price;
            [_penArray addObject:pen];
        }
        [self updatePenViews];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_penArray);
    [super dealloc];
}


- (void)clickPenView:(PenView *)penView
{
    if (_delegate && [_delegate respondsToSelector:@selector(didPickedPickView:penView:)]) {
        [_delegate didPickedPickView:self penView:penView];
    }
}

- (void)sortPens
{
    [_penArray sortUsingComparator:^(id obj1,id obj2){
        PenView *pen1 = (PenView *)obj1;
        PenView *pen2 = (PenView *)obj2;
        BOOL hasBought1 = [pen1 isDefaultPen] || [[AccountService defaultService] hasEnoughItemAmount:pen1.penType amount:1];
        BOOL hasBought2 = [pen2 isDefaultPen] || [[AccountService defaultService] hasEnoughItemAmount:pen2.penType amount:1];
        NSInteger ret = hasBought2 - hasBought1;
        if (ret == 0) {
            return NSOrderedAscending;
        }
        return ret;
    }];

}

- (void)updatePenViews
{
    NSInteger count = [_penArray count];
    if (count == 0) {
        return;
    }
    [self sortPens];
    if ([_penArray count] == 1) {
        PenView *pen = [_penArray objectAtIndex:0];
        pen.center = self.center;
        [self addSubview:pen];
        return;
    }
    
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    CGFloat xSpace = (width - [PenView width] * count)/ (count - 1);
    CGFloat ySpace = (height - [PenView height]) / 2 ;
    CGFloat x = 0;
    CGFloat y = ySpace;
    for (int i = 0; i < count; ++ i) {
        PenView *pen = [_penArray objectAtIndex:i];
        pen.frame = CGRectMake(x, y, [PenView width], [PenView height]);
        [pen addTarget:self action:@selector(clickPenView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pen];
        x += xSpace + [PenView width];
    }
}

@end
