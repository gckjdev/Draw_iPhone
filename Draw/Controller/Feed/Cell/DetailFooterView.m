//
//  DetailFooterView.m
//  Draw
//
//  Created by gamy on 13-8-24.
//
//

#import "DetailFooterView.h"
#import "StableView.h"

@implementation DetailFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = COLOR_YELLOW_ICON;
    }
    return self;
}

#define FOOTER_HEIGHT (ISIPAD ? 88 : 44)
+ (DetailFooterView *)footerViewWithDelegate:(id<DetailFooterViewDelegate>)delegate
{
    CGFloat y = CGRectGetHeight([[UIScreen mainScreen] bounds]) - FOOTER_HEIGHT-(ISIOS7?0:20);
    CGRect frame = CGRectMake(0, y, CGRectGetWidth([[UIScreen mainScreen] bounds]), FOOTER_HEIGHT);
    DetailFooterView *footer = [[DetailFooterView alloc] initWithFrame:frame];
    footer.delegate = delegate;
    return footer;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
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
    KEY(FooterTypeReport): @"detail_report@2x.png",
    KEY(FooterTypeRate): @"detail_rate@2x.png",
    };
    NSString *name = [dict objectForKey:KEY(type)];
    return name ? [UIImage imageNamed:name] : nil;
}

- (void)setButtonsWithCustomTypes:(NSArray *)types
                           images:(NSArray *)images
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
    NSInteger index = 0;
    for (NSNumber *number in types) {
        NSInteger type = number.integerValue;
        UIButton * button = [self reuseButtonWithTag:type frame:CGRectMake(x, 0, width, width) font:nil text:nil];
        x += width + space;
        UIImage *image = images[index];
        [button setImage:image forState:UIControlStateNormal];
        CGFloat inset = width*0.15;
        [button setContentEdgeInsets:UIEdgeInsetsMake(inset, inset, inset, inset)];
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        index++;
    }
}

- (void)setButtonsWithTypes:(NSArray *)types
{
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:types.count];
    for (NSNumber *number in types) {
        UIImage *image = [self imageForType:number.integerValue];
        [images addObject:image];
    }
    [self setButtonsWithCustomTypes:types images:images];
}
- (void)setButton:(FooterType)type enabled:(BOOL)enabled
{
    [[self buttonWithType:type] setEnabled:enabled];
}
- (void)setButton:(FooterType)type badge:(NSInteger)badge
{
#define BUTTON_BADGE_TAG 20131129
#define BADGE_OFFSET (ISIPAD?10:3)    
    UIButton *button = [self buttonWithType:type];
    if (button) {
        BadgeView *bgView = (id)[button viewWithTag:BUTTON_BADGE_TAG];
        if (bgView == nil) {
            bgView = [BadgeView badgeViewWithNumber:badge];
            bgView.tag = BUTTON_BADGE_TAG;
            [button addSubview:bgView];
            CGRect frame = bgView.frame;
            CGFloat dx = CGRectGetWidth(button.frame) - CGRectGetWidth(frame);
            bgView.frame = CGRectOffset(frame, dx+BADGE_OFFSET, -BADGE_OFFSET);
        }
        bgView.number = badge;
    }
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
