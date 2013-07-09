//
//  SelectorCommand.m
//  Draw
//
//  Created by gamy on 13-7-9.
//
//

#import "SelectorCommand.h"

@implementation SelectorCommand


- (UIView *)contentView
{
    return [SelectorBox selectorBoxWithDelegate:self];
}

- (BOOL)execute
{
    if ([super execute]) {
        [self showPopTipView];
    }
    return YES;
    
}

- (void)selectorBox:(SelectorBox *)box didSelectClipType:(ClipType)clipType
{
    [self hidePopTipView];
}
- (void)didClickCancelAtSelectorBox:(SelectorBox *)box
{
    [self hidePopTipView];
}
- (void)didClickHelpAtSelectorBox:(SelectorBox *)box
{
    [self hidePopTipView];
}

@end
