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
    InputAlertViewClickBlock _clickBlock;
}

@property (retain, nonatomic) IBOutlet UILabel *title;
@property (retain, nonatomic) IBOutlet UITextView *content;

@property (retain, nonatomic) IBOutlet UIButton *cancel;
@property (retain, nonatomic) IBOutlet UIButton *confirm;

- (IBAction)clickCancel:(id)sender;
- (IBAction)clickConfirm:(id)sender;

@end


@implementation InputAlertView


- (void)setClickBlock:(InputAlertViewClickBlock)block
{
    RELEASE_BLOCK(_clickBlock);
    COPY_BLOCK(_clickBlock, block);
}


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
              clickBlock:(InputAlertViewClickBlock)clickBlock
{
    InputAlertView *view = [self createView];
    [view setClickBlock:clickBlock];
    [view.title setText:title];
    [view.content setText:content];
    
    return view;
}


- (NSString *)contentText
{
    return self.content.text;
}



- (void)dealloc {
    [_title release];
    [_content release];
    [_cancel release];
    [_confirm release];
    RELEASE_BLOCK(_clickBlock);
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
    BOOL flag = _clickBlock(self.contentText, NO);
    if (flag) {
        [self dismiss:YES];
    }
}
- (IBAction)clickConfirm:(id)sender {
    BOOL flag = _clickBlock(self.contentText, YES);
    if (flag) {
        [self dismiss:YES];
    }
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

@end
