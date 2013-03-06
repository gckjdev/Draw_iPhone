//
//  CustomInfoView.h
//  Draw
//
//  Created by 王 小涛 on 13-3-5.
//
//

#import <UIKit/UIKit.h>

@interface CustomInfoView : UIView

typedef void(^ButtonActionBlock)(UIButton *button, UIView *infoView);

+ (id)createWithTitle:(NSString *)title
                 info:(NSString *)info;

+ (id)createWithTitle:(NSString *)title
             infoView:(UIView *)infoView;

+ (id)createWithTitle:(NSString *)title
             infoView:(UIView *)infoView
       hasCloseButton:(BOOL)hasCloseButton
         buttonTitles:(NSString *)firstTitle, ...;

- (void)showInView:(UIView *)view;

@property (nonatomic, assign) ButtonActionBlock actionBlock;
@property (retain, nonatomic) IBOutlet UIView *mainView;
@property (retain, nonatomic) IBOutlet UILabel *infoLabel;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;

@end
