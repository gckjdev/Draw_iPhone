//
//  CommonTitleView.h
//  Draw
//
//  Created by 王 小涛 on 13-7-22.
//
//


#import <UIKit/UIKit.h>


/*
 
 sample usage, add the following code in viewDidLoad
 
 [CommonTitleView createTitleView:self.view];
 CommonTitleView* titleView = [CommonTitleView titleView:self.view];
 [titleView setTitle:NSLS(@"kFeed")];
 [titleView setRightButtonAsRefresh];
 [titleView setTarget:self];
 [titleView setBackButtonSelector:@selector(clickBackButton:)];
 [titleView setRightButtonSelector:@selector(clickRefreshButton:)];
 
 */

typedef void (^NavigationButtonActionBlock)(UIButton *button);

@interface CommonTitleView : UIView

@property (assign, nonatomic) id target;
@property (assign, nonatomic) SEL rightButtonSelector;
@property (assign, nonatomic) SEL backButtonSelector;

- (void)setTitle:(NSString *)title;
- (void)setRightButtonAsRefresh;
- (void)setRightButtonTitle:(NSString *)title;
- (void)hideBackButton;
- (void)showBackButton;
- (void)hideRightButton;
- (void)showRightButton;
- (CGRect)rightButtonFrame;

+ (CommonTitleView*)createTitleView:(UIView*)superView;
+ (CommonTitleView*)titleView:(UIView*)superView;

@end
