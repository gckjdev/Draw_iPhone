//
//  PopupViewManager.m
//  Draw
//
//  Created by 王 小涛 on 12-11-2.
//
//

#import "PopupViewManager.h"
#import "CMPopTipView.h"

static PopupViewManager *_defaultManager;

@interface PopupViewManager ()

@property (retain, nonatomic) CMPopTipView *chipsSelectPopupView;

@end

@implementation PopupViewManager

+ (PopupViewManager *)defaultManager
{
    if (_defaultManager == nil) {
        _defaultManager = [[PopupViewManager alloc] init];
    }
    
    return _defaultManager;
}

- (void)popupChipsSelectViewAtView:(UIView *)atView
                            inView:(UIView *)inView
                         aboveView:(UIView *)aboveView
                          delegate:(id<ChipsSelectViewProtocol>)delegate
{
    if ([self.chipsSelectPopupView isPopup]) {
        return;
    }
    
    ChipsSelectView *chipsSelectView = [ChipsSelectView createChipsSelectView:delegate];

    self.chipsSelectPopupView = [[[CMPopTipView alloc] initWithCustomView:chipsSelectView] autorelease];
    self.chipsSelectPopupView.backgroundColor = [UIColor magentaColor];
    self.chipsSelectPopupView.alpha = 0.5;
    
    [self.chipsSelectPopupView presentPointingAtView:atView inView:inView aboveView:aboveView animated:YES pointDirection:PointDirectionAuto];
    
    [self.chipsSelectPopupView performSelector:@selector(dismissAnimated:)
                                    withObject:[NSNumber numberWithBool:YES]
                                    afterDelay:3.0];
}

- (void)dismissChipsSelectView
{
    [self.chipsSelectPopupView dismissAnimated:YES];
}

@end
