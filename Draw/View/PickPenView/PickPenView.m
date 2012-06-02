//
//  PickPenView.m
//  Draw
//
//  Created by  on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PickPenView.h"
#import "PPDebug.h"
#import "PenView.h"
@implementation PickPenView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _penArray = [[NSMutableArray alloc] init];
//        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_penArray);
    [super dealloc];
}

- (void)removeAllPens
{
    for (PenView *penView in _penArray) {
        [penView removeFromSuperview];
    }
    [_penArray removeAllObjects];
}


- (void)clickPenView:(PenView *)penView
{
    if (_delegate && [_delegate respondsToSelector:@selector(didPickedPickView:penView:)]) {
        [_delegate didPickedPickView:self penView:penView];
    }
    [self setHidden:YES animated:YES];
}

- (void)updatePenViews
{
    NSInteger count = [_penArray count];
    if (count == 0) {
        return;
    }
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    CGFloat xSpace = (width - [PenView width] * count)/ (count + 1);
    CGFloat ySpace = (height - [PenView height]) / 4 ;
    CGFloat x = xSpace;
    CGFloat y = ySpace;
    for (int i = 0; i < count; ++ i) {
        PenView *pen = [_penArray objectAtIndex:i];
        pen.frame = CGRectMake(x, y, [PenView width], [PenView height]);
        [pen addTarget:self action:@selector(clickPenView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pen];
        x += xSpace + [PenView width];
    }
}

- (void)setPens:(NSArray *)pens
{
    [self removeAllPens];
    for (PenView *penView in pens) {
        [_penArray  addObject:penView];
    }
    [self updatePenViews];
}
@end
