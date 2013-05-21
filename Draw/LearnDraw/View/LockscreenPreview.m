//
//  LockscreenPreview.m
//  Draw
//
//  Created by haodong on 13-5-8.
//
//

#import "LockscreenPreview.h"
#import "AutoCreateViewByXib.h"
#import "TimeUtils.h"

@interface LockscreenPreview()


@end

@implementation LockscreenPreview

AUTO_CREATE_VIEW_BY_XIB(LockscreenPreview);

+ (LockscreenPreview *)createWithImage:(UIImage *)image
{
    LockscreenPreview *view = [self createView];
    view.contentImageView.image = image;
    return view;
}

- (void)showInView:(UIView *)superView
{
    NSDate *date = [NSDate date];
    self.timeLabel.text = dateToLocaleStringWithFormat(date, @"HH:mm");
    
    NSString *weekStr = dateToLocaleStringWithFormat(date, @"cccc");
    NSString *monAndDayStr = nil;
    if ([LocaleUtils isChinese]) {
        monAndDayStr = dateToLocaleStringWithFormat(date, @"M月d日");
        self.dateLabel.text = [NSString stringWithFormat:@"%@%@", monAndDayStr, weekStr];
    } else {
        monAndDayStr = dateToLocaleStringWithFormat(date, @"d MMM");
        self.dateLabel.text = [NSString stringWithFormat:@"%@, %@",weekStr,  monAndDayStr];
    }
    
    
    
    self.slideLabel.text = NSLS(@"kDreamLockscreenSlider");
    
    self.frame = superView.bounds;
    self.alpha = 0.0f;
    [UIView beginAnimations:@"showLockView" context:nil];
    [superView addSubview:self];
    [UIView setAnimationDuration:0.8];
    self.alpha = 1.0f;
    [UIView commitAnimations];
}

- (IBAction)touchDown:(id)sender {
    [self removeFromSuperview];
}

- (void)dealloc {
    [_contentImageView release];
    [_timeLabel release];
    [_dateLabel release];
    [_slideLabel release];
    [super dealloc];
}

@end
