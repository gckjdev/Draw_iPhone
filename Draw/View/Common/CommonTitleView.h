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
@property (assign, nonatomic) SEL rightButtonSelctor;

- (void)setTitle:(NSString *)title;
- (void)setRightButtonAsRefresh;
- (void)setRightButtonTitle:(NSString *)title;

@end
