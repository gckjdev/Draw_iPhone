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
@property (retain, nonatomic) CMPopTipView *cardTypesPopupView;

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

    if (self.chipsSelectPopupView == nil) {
        self.chipsSelectPopupView = [[[CMPopTipView alloc] initWithCustomViewWithoutBubble:chipsSelectView] autorelease];
    }
    
    [self.chipsSelectPopupView presentPointingAtView:atView inView:inView aboveView:aboveView animated:YES pointDirection:PointDirectionAuto];
    
    [self performSelector:@selector(dismissChipsSelectView)
               withObject:nil
               afterDelay:3.0];
}

- (void)dismissChipsSelectView
{
    [self.chipsSelectPopupView dismissAnimated:YES];
}

- (void)popupCardTypesWithCardType:(PBZJHCardType)cardType
                            atView:(UIView *)atView
                          inView:(UIView *)inView
{
    if ([self.cardTypesPopupView isPopup]) {
        return;
    }
    
    UIView *cardTypesView = [ZJHCardTypesView cardTypesViewWithCardType:cardType];
    
    if (self.cardTypesPopupView == nil) {
        self.cardTypesPopupView = [[[CMPopTipView alloc] initWithCustomView:cardTypesView needBubblePath:NO] autorelease];
        self.chipsSelectPopupView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    }
    
    [self.cardTypesPopupView presentPointingAtView:atView inView:inView animated:YES];
    
    [self performSelector:@selector(dismissCardTypesView)
               withObject:nil
               afterDelay:3.0];
}

- (void)dismissCardTypesView
{
    [self.chipsSelectPopupView dismissAnimated:YES];
}

@end
