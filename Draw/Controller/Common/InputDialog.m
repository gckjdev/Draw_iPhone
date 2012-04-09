//
//  InputDialog.m
//  Draw
//
//  Created by  on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "InputDialog.h"
#import "AnimationManager.h"
#import "ShareImageManager.h"
#import "LocaleUtils.h"

@implementation InputDialog
@synthesize cancelButton;
@synthesize contentView;
@synthesize okButton;
@synthesize bgView;
@synthesize titleLabel;
@synthesize targetTextField;
@synthesize delegate;

#define RUN_OUT_TIME 0.2
#define RUN_IN_TIME 0.4

- (void)updateTextFields
{
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [self.targetTextField setBackground:[imageManager inputImage]];
    [self.targetTextField setPlaceholder:NSLS(@"kNicknameHolder")];
}

- (void)startRunOutAnimation
{
    CAAnimation *runOut = [AnimationManager scaleAnimationWithFromScale:1 toScale:0.1 duration:RUN_OUT_TIME delegate:self removeCompeleted:NO];
    [runOut setValue:@"runOut" forKey:@"AnimationKey"];
    [self.contentView.layer addAnimation:runOut forKey:@"runOut"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* value = [anim valueForKey:@"AnimationKey"];
    if ([value isEqualToString:@"runOut"]) {
        [self setHidden:YES];
        [self removeFromSuperview];
    }else{
        [self.targetTextField becomeFirstResponder];
    }
    [self.contentView.layer removeAllAnimations];
}


- (IBAction)clickCancelButton:(id)sender {
    [self startRunOutAnimation];
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCancel:)]) {
        [self.delegate clickCancel:self];
    }
}

- (IBAction)clickOkButton:(id)sender {
    [self startRunOutAnimation];
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickOk:targetText:)]) {
        [self.delegate clickOk:self targetText:self.targetTextField.text];
    }
}

+ (InputDialog *)dialogWith:(NSString *)title delegate:(id<InputDialogDelegate>)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"InputDialog" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <InputDialog> but cannot find cell object from Nib");
        return nil;
    }
    InputDialog* view =  (InputDialog*)[topLevelObjects objectAtIndex:0];
    
    //init the button
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [view updateTextFields];
    [view setDialogTitle:title];
    [view.cancelButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [view.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [view.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    [view.okButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
    view.delegate = delegate;
    view.tag = 0;
    return view;

}
- (void)showInView:(UIView *)view
{
    self.frame = view.bounds;
    [view addSubview:self];
    CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:RUN_IN_TIME delegate:self removeCompeleted:NO];
    [self.contentView.layer addAnimation:runIn forKey:@"runIn"];
}

- (void)setDialogTitle:(NSString *)title
{
    [self.titleLabel setTitle:title forState:UIControlStateNormal];
}

- (void)setTargetText:(NSString *)text
{
    [self.targetTextField setText:text];
}

//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
//{
//    [self.targetTextField becomeFirstResponder];
//}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self clickOkButton:okButton];
    return YES;
}

- (void)dealloc {
    [cancelButton release];
    [okButton release];
    [bgView release];
    [titleLabel release];
    [targetTextField release];
    [contentView release];
    [super dealloc];
}
@end
