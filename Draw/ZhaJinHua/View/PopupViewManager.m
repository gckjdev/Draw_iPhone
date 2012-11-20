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

    self.chipsSelectPopupView = [[[CMPopTipView alloc] initWithCustomViewWithoutBubble:chipsSelectView] autorelease];
    self.chipsSelectPopupView.disableTapToDismiss = YES;
    
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
    
    self.cardTypesPopupView = [[[CMPopTipView alloc] initWithCustomView:cardTypesView pointerSize:6.0] autorelease];
    self.cardTypesPopupView.disableTapToDismiss = YES;
    self.cardTypesPopupView.backgroundColor = [UIColor clearColor];
    
    [self.cardTypesPopupView presentPointingAtView:atView inView:inView animated:YES];
    
    [self performSelector:@selector(dismissCardTypesView)
               withObject:nil
               afterDelay:3.0];
}

- (void)dismissCardTypesView
{
    [self.cardTypesPopupView dismissAnimated:YES];
}

@end
