//
//  InputAlertView.h
//  Draw
//
//  Created by gamy on 13-1-14.
//
//

#import <UIKit/UIKit.h>


//return yes to dismiss the view, and no to stay the view.


typedef BOOL (^InputAlertViewClickBlock)(NSString *contentText, BOOL confirm);


@interface InputAlertView : UIControl<UITextViewDelegate>


+ (id)inputAlertViewWith:(NSString *)title
                 content:(NSString *)content
              clickBlock:(InputAlertViewClickBlock)clickBlock;

- (NSString *)contentText;
- (void)showInView:(UIView *)view animated:(BOOL)animated;
- (void)dismiss:(BOOL)animated;
- (void)adjustWithKeyBoardRect:(CGRect)rect;

@end
