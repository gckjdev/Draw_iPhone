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
#import "PPConfigManager.h"
#import "UserManager.h"
//#import "PPSNSIntegerationService.h"
#import "PPSNSConstants.h"
#import "PPViewController.h"
#import "MBProgressHUD.h"
#import "UserService.h"
#import "GameSNSService.h"
#import "CommonMessageCenter.h"
#import "ShareImageManager.h"
#import "StringUtil.h"
#import "WordFilterService.h"
#import "AutoCreateViewByXib.h"


@implementation InputAlert

+ (void)showWithSubject:(NSString *)subject
                content:(NSString *)contest
                 inView:(UIView *)view
                  block:(InputAlertBlock)block{
    
    [self showWithSubject:subject
                  content:contest
                  showSNS:YES
                   inView:view
                    block:block];
}

+ (void)showWithSubjectWithoutSNS:(NSString *)subject
                          content:(NSString *)contest
                           inView:(UIView *)view
                            block:(InputAlertBlock)block{
    
    [self showWithSubject:subject
                  content:contest
                  showSNS:NO
                   inView:view
                    block:block];
}

+ (void)showWithSubject:(NSString *)subject
                content:(NSString *)contest
                showSNS:(NSString *)showSNS
                 inView:(UIView *)view
                  block:(InputAlertBlock)block
{
    InputAlertView *v = nil;
    BOOL hasSubject = [subject length] > 0;

    if ([GameApp forceChineseOpus]) {
    
        BOOL hasSNS = NO;
        if (showSNS) {
            hasSNS = ([LocaleUtils isChina]
                      || [[UserManager defaultManager] hasBindQQWeibo]
                      || [[UserManager defaultManager] hasBindSinaWeibo]);
        }else{
            hasSNS = NO;
        }
        
        ComposeInputDialogType type = 0;
        if (hasSubject == YES && hasSNS == YES) {
            type = ComposeInputDialogTypeTitleAndContentWithSNS;
            v = [InputAlertView createWithType:type];
            [v.titleInputField becomeFirstResponder];
        }else if (hasSubject == YES && hasSNS == NO){
            type = ComposeInputDialogTypeTitleAndContent;
            v = [InputAlertView createWithType:type];
            [v.titleInputField becomeFirstResponder];
        }else if (hasSubject == NO && hasSNS == YES){
            type = ComposeInputDialogTypeContentWithSNS;
            v = [InputAlertView createWithType:type];
            [v.contentInputView becomeFirstResponder];
        }else{
            type = ComposeInputDialogTypeContent;
            v = [InputAlertView createWithType:type];
            [v.contentInputView becomeFirstResponder];
        }
        
    } else {
        v = [InputAlertView createWithType:ComposeInputDialogTypeContentWithSNS];
        [v.contentInputView becomeFirstResponder];
    }
    
    [v.titleInputField setText:subject];
    [v.contentInputView setText:contest];
    v.titleInputField.placeholder = NSLS(@"kSubjectPlaceholder");
    
    [v setMaxTitleLength:[PPConfigManager getOpusNameMaxLength]];    
    [v setMaxContentLength:[PPConfigManager getOpusDescMaxLength]];
    
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kAddOpusDesc") customView:v style:CommonDialogStyleDoubleButton];
    dialog.manualClose = YES;
    [dialog showInView:view];
    
    
    [dialog setClickOkBlock:^(id infoView){
        
        NSString *newSubject = nil;

        if (hasSubject) {
            
            newSubject = v.titleInputField.text;
            
            if ([newSubject length] <= 0) {
                POSTMSG(NSLS(@"kOpusNameInvaild"));
                return;
            }
            
            if (!NSStringIsValidChinese(newSubject)
                 && !NSStringISValidEnglish(newSubject)) {
                POSTMSG(NSLS(@"kOnlyChineseOrEnglishTitleAllowed"));
                return;
            }
            
            if([newSubject length] > [PPConfigManager getOpusNameMaxLength]){
                NSString *msg = [NSString stringWithFormat:NSLS(@"kSubjectLengthLimited"),
                                 [PPConfigManager getOpusNameMaxLength]];
                POSTMSG(msg);
                return;
            }
        }
        
        NSString *newContent = v.contentInputView.text;
        if ([newContent length] > [PPConfigManager getOpusDescMaxLength]) {
            NSString *msg = [NSString stringWithFormat:NSLS(@"kOpusDescLengthLimited"),
                             [PPConfigManager getOpusNameMaxLength]];
            POSTMSG(msg);
            return;
        }
    
        dialog.manualClose = NO;
        EXECUTE_BLOCK(block, YES, newSubject, newContent, v.shareSet);
    }];
    
    [dialog setClickCancelBlock:^(id infoView){
        
        dialog.manualClose = NO;
        
        NSString *newSubject = hasSubject ? v.titleInputField.text : nil;
        NSString *newContent = v.contentInputView.text;
        EXECUTE_BLOCK(block, NO, newSubject, newContent, v.shareSet);
    }];
}

@end



#define GAP (ISIPAD ? 15 : 8)

@interface InputAlertView ()<UITextFieldDelegate, UITextViewDelegate>{
    int _maxTitleLength;
    int _maxContentLength;
}

@property (assign, nonatomic) ComposeInputDialogType type;

@property (retain, nonatomic) IBOutlet UILabel *shareToSinaLabel;
@property (retain, nonatomic) IBOutlet UILabel *shareToQQLabel;
@property (retain, nonatomic) IBOutlet UIButton *sinaCheckBox;
@property (retain, nonatomic) IBOutlet UIButton *qqCheckBox;

- (IBAction)clickSinaCheckBox:(UIButton *)sender;
- (IBAction)clickQQCheckBox:(UIButton *)sender;

@end


@implementation InputAlertView

AUTO_CREATE_VIEW_BY_XIB(InputAlertView);

- (void)dealloc {
    PPDebug(@"%@ dealloc", self);
    PPRelease(_titleInputField);
    PPRelease(_contentInputView);
    PPRelease(_shareToSinaLabel);
    PPRelease(_shareToQQLabel);
    PPRelease(_sinaCheckBox);
    PPRelease(_qqCheckBox);
    [super dealloc];
}

+ (id)createWithType:(ComposeInputDialogType)type{
    
    InputAlertView *v  = [self createView];
    v.type = type;
    [v updateView];
    
    return v;
}

- (void)updateView
{
    [self.sinaCheckBox setSelected:[self canShareViaSina]];
    [self.qqCheckBox setSelected:[self canShareViaQQ]];
    
    [self.shareToSinaLabel setText:NSLS(@"kSinaWeibo")];
    [self.shareToQQLabel setText:NSLS(@"kTencentWeibo")];
    self.shareToSinaLabel.textColor = COLOR_COFFEE;
    self.shareToQQLabel.textColor = COLOR_COFFEE;
    
    SET_INPUT_VIEW_STYLE(self.titleInputField);
    self.titleInputField.delegate = self;
    
    SET_INPUT_VIEW_STYLE(self.contentInputView);
    self.contentInputView.delegate = self;
    
    CGFloat originY;
    switch (_type) {
            
        case ComposeInputDialogTypeContent:
            
            [self.contentInputView updateOriginY:0];
            
            [self.titleInputField removeFromSuperview];
            [self.sinaCheckBox removeFromSuperview];
            [self.qqCheckBox removeFromSuperview];
            [self.shareToQQLabel removeFromSuperview];
            [self.shareToSinaLabel removeFromSuperview];
            
            [self updateHeight:CGRectGetMaxY(self.contentInputView.frame)];
            break;
            
        case ComposeInputDialogTypeTitleAndContent:
            
            [self.titleInputField updateOriginY:0];
            [self.contentInputView updateOriginY:(_titleInputField.frame.size.height + GAP)];
            [self.sinaCheckBox removeFromSuperview];
            [self.qqCheckBox removeFromSuperview];
            [self.shareToQQLabel removeFromSuperview];
            [self.shareToSinaLabel removeFromSuperview];
            
            [self updateHeight:CGRectGetMaxY(self.contentInputView.frame)];

            break;
            
        case ComposeInputDialogTypeContentWithSNS:
            
            [self.titleInputField removeFromSuperview];
            [self.contentInputView updateOriginY:0];
            originY = CGRectGetMaxY(self.contentInputView.frame) + GAP;
            [self.sinaCheckBox updateOriginY:originY];
            [self.qqCheckBox updateOriginY:originY];
            [self.shareToQQLabel updateOriginY:originY];
            [self.shareToSinaLabel updateOriginY:originY];
            
            [self updateHeight:CGRectGetMaxY(self.qqCheckBox.frame)];
            break;
        
        case ComposeInputDialogTypeTitleAndContentWithSNS:
            
            [self.titleInputField updateOriginY:0];
            [self.contentInputView updateOriginY:(CGRectGetMaxY(self.titleInputField.frame) + GAP)];
            originY = CGRectGetMaxY(self.contentInputView.frame) + GAP;
            [self.sinaCheckBox updateOriginY:originY];
            [self.qqCheckBox updateOriginY:originY];
            [self.shareToQQLabel updateOriginY:originY];
            [self.shareToSinaLabel updateOriginY:originY];
            
            [self updateHeight:CGRectGetMaxY(self.qqCheckBox.frame)];

            break;
            
        default:
            break;
    }
}

- (BOOL)canShareViaSina
{
    return [[GameSNSService defaultService] isExpired:TYPE_SINA] == NO;
}

- (BOOL)canShareViaQQ
{
    return [[GameSNSService defaultService] isExpired:TYPE_QQ] == NO;
}


- (void)setMaxTitleLength:(int)maxTitleLeng{
    _maxTitleLength = maxTitleLeng;
}

- (void)setMaxContentLength:(int)maxContentLen{
    _maxContentLength = maxContentLen;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (_maxTitleLength > 0 && range.location >= _maxTitleLength) {
        return NO;
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if (_maxContentLength > 0 && range.location >= _maxContentLength) {
        return NO;
    }
    
    return YES;
}


- (NSSet *)shareSet
{
    NSMutableSet *set = [NSMutableSet setWithCapacity:2];
    if (self.sinaCheckBox.isSelected) {
        [set addObject:@(TYPE_SINA)];
    }
    if (self.qqCheckBox.isSelected) {
        [set addObject:@(TYPE_QQ)];
    }
    return set;
}


- (IBAction)clickSinaCheckBox:(UIButton *)sender {
    if (sender.isSelected) {
        [sender setSelected:NO];
    }else{
        if ([self canShareViaSina]) {
            [sender setSelected:YES];
        }else{
            [self bindSNS:TYPE_SINA sender:sender];
        }
    }
}

- (IBAction)clickQQCheckBox:(UIButton *)sender {
    if (sender.isSelected) {
        [sender setSelected:NO];
    }else{
        if ([self canShareViaQQ]) {
            [sender setSelected:YES];
        }else{
            [self bindSNS:TYPE_QQ sender:sender];
        }
    }
}

#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger length = [PPConfigManager opusDescMaxLength];
    if ([textView.text length] > length) {
        textView.text = [textView.text substringToIndex:length];
    }
}

#pragma mark - Share SNS Control

- (void)bindSNS:(int)snsType sender:(UIControl*)sender
{
    [[GameSNSService defaultService] autheticate:snsType];
}

@end
