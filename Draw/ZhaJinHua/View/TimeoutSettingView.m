//
//  TimeoutSettingView.m
//  Draw
//
//  Created by 王 小涛 on 13-2-27.
//
//

#import "TimeoutSettingView.h"
#import "AutoCreateViewByXib.h"

@implementation TimeoutSettingView

AUTO_CREATE_VIEW_BY_XIB(TimeoutSettingView);


+ (id)createTimeoutSettingView{
    TimeoutSettingView *view = [self createView];
    view.titleLabel.text = NSLS(@"kSetTimeoutAction");
    view.foldNoteLabel.text = NSLS(@"kFoldCard");
    view.betOrCompareNotelabel.text = NSLS(@"kBetOrCompareCard");
    
    [view.betOrCompareActionButton addTarget:view action:@selector(clickBetActionButton) forControlEvents:UIControlEventTouchUpInside];
    [view.foldActionButton addTarget:view action:@selector(clickFlodActionButton) forControlEvents:UIControlEventTouchUpInside];
    
    return view;
}

- (void)showInView:(UIView *)view
{
    self.center = view.center;
    [view addSubview:self];
}

- (void)dismiss
{
    [self removeFromSuperview];
}

- (void)clickFlodActionButton {
    [self dismiss];
    if ([_delegate respondsToSelector:@selector(didSelectTimeoutAction:)]) {
        [_delegate didSelectTimeoutAction:PBZJHUserActionFoldCard];
    }
}

- (void)clickBetActionButton {
    [self dismiss];
    if ([_delegate respondsToSelector:@selector(didSelectTimeoutAction:)]) {
        [_delegate didSelectTimeoutAction:PBZJHUserActionBet];
    }
}

- (void)dealloc {
    [_foldActionButton release];
    [_betOrCompareActionButton release];
    [_titleLabel release];
    [_foldNoteLabel release];
    [_betOrCompareNotelabel release];
    [super dealloc];
}

@end
