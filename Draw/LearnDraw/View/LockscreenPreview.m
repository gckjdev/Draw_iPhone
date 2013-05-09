//
//  LockscreenPreview.m
//  Draw
//
//  Created by haodong on 13-5-8.
//
//

#import "LockscreenPreview.h"
#import "AutoCreateViewByXib.h"

@interface LockscreenPreview()

@property (retain, nonatomic) IBOutlet UIButton *closeButton;

@end

@implementation LockscreenPreview

AUTO_CREATE_VIEW_BY_XIB(LockscreenPreview);

+ (LockscreenPreview *)createWithImage:(UIImage *)image
{
    LockscreenPreview *view = [self createView];
    view.contentImageView.image = image;
    return view;
}

- (void)showInView:(UIView *)superView
{
    self.alpha = 0.0f;
    [UIView beginAnimations:@"showLockView" context:nil];
    [superView addSubview:self];
    [UIView setAnimationDuration:0.8];
    self.alpha = 1.0f;
    [UIView commitAnimations];
}

- (IBAction)clickCloseButton:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)touchDown:(id)sender {
    self.closeButton.hidden = !self.closeButton.hidden ;
}

- (void)dealloc {
    [_contentImageView release];
    [_closeButton release];
    [super dealloc];
}

@end
