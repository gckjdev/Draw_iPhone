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
#import "UserManager.h"
#import "PPSNSIntegerationService.h"
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
    
    SET_VIEW_ROUND_CORNER(self.titleInputField);
    [self.titleInputField.layer setBorderWidth:TEXT_VIEW_BORDER_WIDTH];
    [self.titleInputField.layer setBorderColor:[COLOR_YELLOW CGColor]];
    self.titleInputField.delegate = self;
    
    SET_VIEW_ROUND_CORNER(self.contentInputView);
    [self.contentInputView.layer setBorderWidth:TEXT_VIEW_BORDER_WIDTH];
    [self.contentInputView.layer setBorderColor:[COLOR_YELLOW CGColor]];
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
    if ([[UserManager defaultManager] hasBindSinaWeibo] == NO ||
        [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_SINA] isAuthorizeExpired]){
        return NO;
    }
    return YES;
}

- (BOOL)canShareViaQQ
{
    if ([[UserManager defaultManager] hasBindQQWeibo] == NO ||
        [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] isAuthorizeExpired]){
        return NO;
    }
    return YES;
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


//+ (id)inputAlertViewWith:(NSString *)title
//                 content:(NSString *)content
//                  target:(id)target
//           commitSeletor:(SEL)commitSeletor
//           cancelSeletor:(SEL)cancelSeletor
//{
//    InputAlertView *view = [self createView];
//    [view.title setText:title];
//    [view.content setText:content];
//    view.target = target;
//    view.commitSeletor = commitSeletor;
//    view.cancelSeletor = cancelSeletor;
//    return view;
//}

//+ (id)inputAlertViewWith:(NSString *)title
//                 content:(NSString *)content
//                  target:(id)target
//           commitSeletor:(SEL)commitSeletor
//           cancelSeletor:(SEL)cancelSeletor
//                  hasSNS:(BOOL)hasSNS
//{
//    return [self inputAlertViewWith:title content:content target:target commitSeletor:commitSeletor cancelSeletor:cancelSeletor hasSNS:hasSNS hasSubject:NO];
//}

//+ (id)inputAlertViewWith:(NSString *)title
//                 content:(NSString *)content
//                  target:(id)target
//           commitSeletor:(SEL)commitSeletor
//           cancelSeletor:(SEL)cancelSeletor
//                  hasSNS:(BOOL)hasSNS
//              hasSubject:(BOOL)hasSubject
//{
//    InputAlertView *view = [self createView];
////    [view.title setText:title];
////    [view.content setText:content];
////    view.target = target;
////    view.commitSeletor = commitSeletor;
////    view.cancelSeletor = cancelSeletor;
//    
//    if (!hasSNS) {
//        CGRect inputRect = view.content.frame;
//        [view.contentBg setFrame:CGRectMake(inputRect.origin.x, inputRect.origin.y, inputRect.size.width, view.qqCheckBox.center.y - inputRect.origin.y)];
//        //        [view.contentBg setFrame:view.content.frame];
//        [view.content setCenter:view.contentBg.center];
//        [view.qqCheckBox setHidden:YES];
//        [view.sinaCheckBox setHidden:YES];
//        [view.shareToQQ setHidden:YES];
//        [view.shareToSina setHidden:YES];
//    }
//    
//    if (hasSubject) {
//        [view.subject setBackground:[[ShareImageManager defaultManager] inputDialogInputBgImage]];
//        view.subject.delegate = view;
//        [view.subject setPlaceholder:NSLS(@"kLittleGeeDrawTitle")];
//        [view.subject setHidden:NO];
//        CGRect inputRect = view.content.frame;
//        [view.contentBg setFrame:CGRectMake(inputRect.origin.x, inputRect.origin.y + view.subject.frame.size.height, inputRect.size.width, view.contentBg.frame.size.height - view.subject.frame.size.height)];
//        [view.content setFrame:view.contentBg.frame];
//    }
//    return view;
//}


//- (NSString *)contentText
//{
//    return self.content.text;
//}

//- (NSString *)setContentText:(NSString *)text
//{
//    [self.content setText:text];
//    return self.content.text;
//}

//- (NSString*)subjectText
//{
//    return self.subject.text;
//}
//- (NSString*)setSubjectText:(NSString*)text
//{
//    [self.subject setText:text];
//    return self.content.text;
//}




#define DismissTimeInterval 0.5

//- (CGPoint)hideCenter
//{
//    return CGPointMake(CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds));
//}

//- (void)showInView:(UIView *)view animated:(BOOL)animated
//{
//    if (_maxInputLen > 0 && [self.content.text length] >= _maxInputLen) {
//        NSString* text = [self.content.text substringToIndex:_maxInputLen];
//        [self.content setText:text];
//    }
//    [view addSubview:self];
//    if(animated){
//        self.center = [self hideCenter];
//        [UIView animateWithDuration:DismissTimeInterval animations:^{
//            self.center = view.center;
//            
//        } completion:^(BOOL finished) {
//            [(self.subject.hidden?self.content:self.subject) becomeFirstResponder];
//        }];
//    }else{
//        self.center = view.center;
//        [(self.subject.hidden?self.content:self.subject) becomeFirstResponder];
//    }
//}

//- (void)dismiss:(BOOL)animated
//{
//    if (animated) {
//        [UIView animateWithDuration:DismissTimeInterval animations:^{
//            self.center = [self hideCenter];
//        } completion:^(BOOL finished) {
//            [self removeFromSuperview];
//            [self.content resignFirstResponder];
//        }];
//    }else{
//        [self removeFromSuperview];
//        [self.content resignFirstResponder];
//    }
//}

//- (IBAction)clickCancel:(id)sender {
//    if (self.cancelSeletor != NULL && [self.target respondsToSelector:self.cancelSeletor]){
//         [self.target performSelector:self.cancelSeletor];
//    }
//    [self dismiss:YES];
//}

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

//- (BOOL)isTitlelegal
//{
//    if (_delegate && [_delegate respondsToSelector:@selector(isSubjectValid:)] && [self canEditSubject]) {
//        return [_delegate isSubjectValid:self.subjectText];
//    }
//    return YES;
//    
//}

//- (IBAction)clickConfirm:(id)sender {
//    if (!_subject.hidden && [_subject.text length] == 0) {
//        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kMustHaveTitle") delayTime:1.5 atHorizon:(ISIPAD?0:(-60))];
//        return;
//    }
//    if (![self isTitlelegal]) {
//
//        return;
//    }
//    
//    if ([[WordFilterService defaultService] checkForbiddenWord:[self contentText]]){
//        return;
//    }
//    
//    if ([self hasSubjectText] && [[WordFilterService defaultService] checkForbiddenWord:[self subjectText]]){
//        return;
//    }
//    
//    if (self.commitSeletor != NULL && [self.target respondsToSelector:self.commitSeletor]) {
//        NSSet *shareSet = [self setForShareType];
//        [self.target performSelector:self.commitSeletor withObject:shareSet];
//    }
//    [self dismiss:YES];
//}


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
//
//- (IBAction)clickClose:(id)sender {
//    [self dismiss:YES];
//}
//
//- (IBAction)clickMask:(id)sender {
//    [self dismiss:YES];
//}

//- (void)adjustWithKeyBoardRect:(CGRect)rect
//{
//    [UIView animateWithDuration:0.3 animations:^{
//        CGFloat height = CGRectGetHeight(self.superview.bounds) - CGRectGetHeight(rect);
//        CGFloat widht = CGRectGetWidth(self.bounds);
//        self.frame = CGRectMake(0, 0, widht, height);
//    }];
//}

//- (void)setCanClickCommitButton:(BOOL)can
//{
//    self.confirm.userInteractionEnabled = can;
//    self.confirm.enabled = can;
//}

//- (void)clickConfirm
//{
//    [self clickConfirm:self.confirm];
//}

#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger length = [ConfigManager opusDescMaxLength];
    if ([textView.text length] > length) {
        textView.text = [textView.text substringToIndex:length];
    }
}

#pragma mark - Share SNS Control

- (void)bindSNS:(int)snsType sender:(UIControl*)sender
{    
    PPSNSCommonService* service = [[PPSNSIntegerationService defaultService] snsServiceByType:snsType];
    NSString* name = [service snsName];
    
    [service logout];    
    [service login:^(NSDictionary *userInfo) {
        PPDebug(@"%@ Login Success", name);
        
        [MBProgressHUD showHUDAddedTo:self animated:YES];
        
        [service readMyUserInfo:^(NSDictionary *userInfo) {

            [MBProgressHUD hideHUDForView:self animated:YES];
            
            PPDebug(@"%@ readMyUserInfo Success, userInfo=%@", name, [userInfo description]);
            UserManager* userManager = [UserManager defaultManager];
            [[UserService defaultService] updateUserWithSNSUserInfo:[userManager userId]
                                                           userInfo:userInfo
                                                     viewController:nil];
            
            
            
            
        } failureBlock:^(NSError *error) {

            [MBProgressHUD hideHUDForView:self animated:YES];            
            PPDebug(@"%@ readMyUserInfo Failure", name);
        }];
        
        [sender setSelected:YES];
        
        // follow weibo if NOT followed
        if ([GameSNSService hasFollowOfficialWeibo:service] == NO){
            [service followUser:[service officialWeiboId]
                         userId:[service officialWeiboId]
                   successBlock:^(NSDictionary *userInfo) {
                       [GameSNSService updateFollowOfficialWeibo:service];
                   } failureBlock:^(NSError *error) {
                       PPDebug(@"follow weibo but error=%@", [error description]);
                   }];
        }
        
    } failureBlock:^(NSError *error) {
        PPDebug(@"%@ Login Failure", name);
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUserBindFail") delayTime:2];
    }];
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    if (self.maxInputLen > 0 && range.location >= self.maxInputLen)
//        return NO; // return NO to not change text
//    return YES;
//}
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if (_delegate && [_delegate respondsToSelector:@selector(maxSubjectLen)]) {
//        int maxTitleLen = [_delegate maxSubjectLen];
//        if (range.location >= maxTitleLen)
//            return NO; // return NO to not change text
//    }
//    return YES;
//}

//- (BOOL)hasSubjectText
//{
//    return [self canEditSubject] && (self.subjectText != nil) && self.subjectText.length > 0;
//}

//- (BOOL)canEditSubject
//{
//    return !self.subject.hidden;
//}

@end
