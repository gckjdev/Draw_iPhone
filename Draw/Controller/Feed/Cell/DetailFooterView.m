//
//  DetailFooterView.m
//  Draw
//
//  Created by gamy on 13-8-24.
//
//

#import "DetailFooterView.h"

@implementation DetailFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = COLOR_YELLOW1;//[UIColor clearColor];
    }
    return self;
}

#define FOOTER_HEIGHT (ISIPAD ? 100 : 40)
+ (DetailFooterView *)footerViewWithDelegate:(id<DetailFooterViewDelegate>)delegate
{
    CGFloat y = CGRectGetHeight([[UIScreen mainScreen] applicationFrame]) - FOOTER_HEIGHT;
    CGRect frame = CGRectMake(0, y, CGRectGetWidth([[UIScreen mainScreen] bounds]), FOOTER_HEIGHT);
    DetailFooterView *footer = [[DetailFooterView alloc] initWithFrame:frame];
    footer.delegate = delegate;
    return footer;
}

- (UIButton *)buttonWithType:(FooterType)type
{
    if (type != FooterTypeNo) {
        return (id)[self viewWithTag:type];
    }
    return nil;
}

#define KEY(x) @(x)
- (UIImage *)imageForType:(FooterType)type
{
    NSDictionary *dict = @{
    KEY(FooterTypeComment): @"detail_comment@2x.png",
    KEY(FooterTypeFlower): @"detail_flower@2x.png",
    KEY(FooterTypeGuess): @"detail_guess@2x.png",
    KEY(FooterTypeReplay): @"detail_replay@2x.png",
    KEY(FooterTypeShare): @"detail_share@2x.png",
    KEY(FooterTypeTomato): @"detail_tomato@2x.png",
    //TODO change it!!
    KEY(FooterTypeReport): @"detail_tomato@2x.png",
    KEY(FooterTypeJudge): @"detail_tomato@2x.png",
    };
    NSString *name = [dict objectForKey:KEY(type)];
    return name ? [UIImage imageNamed:name] : nil;
}

- (void)setButtonsWithTypes:(NSArray *)types
{
    for (UIButton *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    NSInteger count = [types count];
    if (count == 0) {
        return;
    }
    
    CGFloat width = CGRectGetHeight(self.bounds);
    CGFloat space = (CGRectGetWidth(self.bounds) - (width * count))/count;
    CGFloat x = space / 2;
    for (NSNumber *number in types) {
        NSInteger type = number.integerValue;
        UIButton * button = [self reuseButtonWithTag:type frame:CGRectMake(x, 0, width, width) font:nil text:nil];
        x += width + space;
        [button setImage:[self imageForType:type] forState:UIControlStateNormal];
//        CGFloat inset = width*0.1;
//        [button setContentEdgeInsets:UIEdgeInsetsMake(inset, inset, inset, inset)];
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (void)setButton:(FooterType)type enabled:(BOOL)enabled
{
    [[self buttonWithType:type] setEnabled:enabled];
}

- (void)clickButton:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(detailFooterView:didClickAtButton:type:)]) {
        [self.delegate detailFooterView:self
                       didClickAtButton:button
                                   type:button.tag];
    }
}

@end
