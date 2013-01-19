//
//  InputAlertView.m
//  Draw
//
//  Created by gamy on 13-1-14.
//
//

#import "InputAlertView.h"
#import "BlockUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "ConfigManager.h"


@interface InputAlertView ()
{

}

@property (retain, nonatomic) IBOutlet UILabel *title;
@property (retain, nonatomic) IBOutlet UITextView *content;

@property (retain, nonatomic) IBOutlet UIButton *cancel;
@property (retain, nonatomic) IBOutlet UIButton *confirm;
@property (assign, nonatomic) id target;
@property (assign, nonatomic) SEL cancelSeletor;
@property (assign, nonatomic) SEL commitSeletor;

- (IBAction)clickCancel:(id)sender;
- (IBAction)clickConfirm:(id)sender;

@end


@implementation InputAlertView


- (void)updateView
{
    //update the font...
    [self.cancel setTitle:NSLS(@"kTwoSpaceCancel") forState:UIControlStateNormal];
    [self.confirm setTitle:NSLS(@"kTwoSpaceConfirm") forState:UIControlStateNormal];

    [self addTarget:self action:@selector(clickMask:) forControlEvents:UIControlEventTouchUpInside];
}

+ (id)createView
{
    NSString *identifier = @"InputAlertView";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier
                                                             owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", identifier);
        return nil;
    }
    InputAlertView  *view = (InputAlertView *)[topLevelObjects objectAtIndex:0];
    [view updateView];
    return view;
}



+ (id)inputAlertViewWith:(NSString *)title
                 content:(NSString *)content
                  target:(id)target
           commitSeletor:(SEL)commitSeletor
           cancelSeletor:(SEL)cancelSeletor
{
    InputAlertView *view = [self createView];
    [view.title setText:title];
    [view.content setText:content];
    view.target = target;
    view.commitSeletor = commitSeletor;
    view.cancelSeletor = cancelSeletor;
    return view;

}


- (NSString *)contentText
{
    return self.content.text;
}



- (void)dealloc {
    PPDebug(@"%@ dealloc", self);
    PPRelease(_title);
    PPRelease(_content);
    PPRelease(_cancel);
    PPRelease(_confirm);
    [super dealloc];
}


#define DismissTimeInterval 0.5

- (CGPoint)hideCenter
{
    return CGPointMake(CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds));
}

- (void)showInView:(UIView *)view animated:(BOOL)animated
{
    [view addSubview:self];
    if(animated){
        self.center = [self hideCenter];
        [UIView animateWithDuration:DismissTimeInterval animations:^{
            self.center = view.center;
            
        } completion:^(BOOL finished) {
            [self.content becomeFirstResponder];
        }];
    }else{
        self.center = view.center;
        [self.content becomeFirstResponder];
    }
}

- (void)dismiss:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:DismissTimeInterval animations:^{
            self.center = [self hideCenter];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [self.content resignFirstResponder];
        }];
    }else{
        [self removeFromSuperview];
        [self.content resignFirstResponder];
    }
}

- (IBAction)clickCancel:(id)sender {
    if (self.cancelSeletor != NULL && [self.target respondsToSelector:self.cancelSeletor]){
         [self.target performSelector:self.cancelSeletor];
    }
    [self dismiss:YES];
}
- (IBAction)clickConfirm:(id)sender {
    if (self.commitSeletor != NULL && [self.target respondsToSelector:self.commitSeletor]) {
        [self.target performSelector:self.commitSeletor];
    }
    [self dismiss:YES];
}
- (IBAction)clickMask:(id)sender {
    //dismiss
    [self dismiss:YES];
}

- (void)adjustWithKeyBoardRect:(CGRect)rect
{
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat height = CGRectGetHeight(self.superview.bounds) - CGRectGetHeight(rect);
        CGFloat widht = CGRectGetWidth(self.bounds);
        self.frame = CGRectMake(0, 0, widht, height);
    }];
}


#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger length = [ConfigManager opusDescMaxLength];
    if ([textView.text length] > length) {
        textView.text = [textView.text substringToIndex:length];
    }
}

/*
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    PPDebug(@"shouldChangeTextInRange, textView.text = %@, text = %@",text, textView.text);
    
    if ([text isEqualToString:@"\n"]) {
        if ([textView.text length] != 0) {
            [self clickConfirm:self.confirm];
        }
        return NO;
    }
    return YES;
}
*/
@end
