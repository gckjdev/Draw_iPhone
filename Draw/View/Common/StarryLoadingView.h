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
}
@property (copy,nonatomic) NSString *title;
@property (copy,nonatomic) NSString *message;
@property (assign,nonatomic) float radius;
@property (retain, nonatomic) UIImageView*  backgroundImageView;
@property (retain, nonatomic) UILabel*      titleLabel;
@property (retain, nonatomic) UILabel*      messageLabe;

- (id) initWithTitle:(NSString*)title message:(NSString*)message;
- (id) initWithTitle:(NSString*)title;

- (void) startAnimating;
- (void) stopAnimating;

@end
