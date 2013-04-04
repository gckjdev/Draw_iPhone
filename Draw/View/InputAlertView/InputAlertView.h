//
//  InputAlertView.h
//  Draw
//
//  Created by gamy on 13-1-14.
//
//

#import <UIKit/UIKit.h>


//return yes to dismiss the view, and no to stay the view.


@interface InputAlertView : UIControl<UITextViewDelegate>
{
    
}

@property (assign, nonatomic) NSInteger maxInputLen;

+ (id)inputAlertViewWith:(NSString *)title
                 content:(NSString *)content
                  target:(id)target
           commitSeletor:(SEL)commitSeletor
           cancelSeletor:(SEL)cancelSeletor;

+ (id)inputAlertViewWith:(NSString *)title
                 content:(NSString *)content
                  target:(id)target
           commitSeletor:(SEL)commitSeletor
           cancelSeletor:(SEL)cancelSeletor
                  hasSNS:(BOOL)hasSNS;

- (NSString *)contentText;
- (NSString *)setContentText:(NSString *)text;
- (void)showInView:(UIView *)view animated:(BOOL)animated;
- (void)dismiss:(BOOL)animated;
- (void)adjustWithKeyBoardRect:(CGRect)rect;
- (void)setCanClickCommitButton:(BOOL)can;
- (void)clickConfirm;
@end
