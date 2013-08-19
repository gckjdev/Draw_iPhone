//
//  CommonTitleView.h
//  Draw
//
//  Created by 王 小涛 on 13-7-22.
//
//


#import <UIKit/UIKit.h>

typedef void (^NavigationButtonActionBlock)(UIButton *button);

@interface CommonTitleView : UIView

@property (assign, nonatomic) id target;
@property (assign, nonatomic) SEL rightButtonSelector;
@property (assign, nonatomic) SEL backButtonSelector;

- (void)setTitle:(NSString *)title;
- (void)setRightButtonAsRefresh;
- (void)setRightButtonTitle:(NSString *)title;

- (void)setBgImage:(UIImage *)image;
- (void)setLeftButtonImage:(UIImage *)image;

// 按钮的显示和隐藏控制
- (void)hideBackButton;
- (void)showBackButton;
- (void)hideRightButton;
- (void)showRightButton;

// 在标题栏显示加载进度
- (void)showLoading;
- (void)showLoading:(NSString*)loadingText;
- (void)hideLoading;

+ (CommonTitleView*)createTitleView:(UIView*)superView;
+ (CommonTitleView*)titleView:(UIView*)superView;

@end
