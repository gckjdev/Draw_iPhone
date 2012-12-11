//
//  StarryLoadingView.h
//  Draw
//
//  Created by Kira on 12-11-26.
//
//

#import <UIKit/UIKit.h>

@interface StarryLoadingView : UIView {
//	UIActivityIndicatorView *_activity;
    NSTimer *_timer;
	BOOL _hidden;
    
	NSString *_title;
	NSString *_message;
	float radius;
    UIView* _maskView;
    UIView* _superView;
    UIImageView* _starView;
    UIImageView* _lightView;
}
@property (copy,nonatomic) NSString *title;
@property (copy,nonatomic) NSString *message;
@property (assign,nonatomic) float radius;
@property (retain, nonatomic) UIImageView*  backgroundImageView;
@property (retain, nonatomic) UILabel*      titleLabel;
@property (retain, nonatomic) UILabel*      messageLabel;
@property (retain, nonatomic) UIView*       loadingView;
@property (retain, nonatomic) UIView*       superView;
@property (retain, nonatomic) UIImageView*  planetView;

- (id) initWithTitle:(NSString*)title message:(NSString*)message;
- (id) initWithTitle:(NSString*)title;

- (void) startAnimating;
- (void) stopAnimating;
- (void)showInView:(UIView*)superView;
@end
