//
//  CustomInfoView.h
//  Draw
//
//  Created by 王 小涛 on 13-3-5.
//
//

#import <UIKit/UIKit.h>

@interface CustomInfoView : UIView
{
        
}

typedef void(^ButtonActionBlock)(UIButton *button, UIView *infoView);
typedef void(^CloseHandler)();

@property (nonatomic, assign) ButtonActionBlock actionBlock;
@property (retain, nonatomic) IBOutlet UIView *mainView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;
@property (retain, nonatomic) UIView *infoView;
@property (retain, nonatomic) NSMutableDictionary *notifications;
@property (copy, nonatomic) CloseHandler closeHandler;

+ (id)createWithTitle:(NSString *)title
             infoView:(UIView *)infoView;

+ (id)createWithTitle:(NSString *)title
             infoView:(UIView *)infoView
         hasEdgeSpace:(BOOL)hasEdgeSpace;


+ (id)createWithTitle:(NSString *)title
             infoView:(UIView *)infoView
         closeHandler:(CloseHandler)closeHandler;

+ (id)createWithTitle:(NSString *)title
             infoView:(UIView *)infoView
       hasCloseButton:(BOOL)hasCloseButton
         buttonTitles:(NSArray *)buttonTitles;

- (void)showInView:(UIView *)view;
- (void)dismiss;

- (void)showActivity;
- (void)hideActivity;

- (void)setTitle:(NSString*)title;

- (void)registerNotificationWithName:(NSString *)name
                          usingBlock:(void (^)(NSNotification *note))block;
- (void)unregisterAllNotifications;

@end
