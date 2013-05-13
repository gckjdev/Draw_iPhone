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

@interface InputAlertView ()
{

}

@property (retain, nonatomic) IBOutlet UIImageView *contentBg;
@property (retain, nonatomic) IBOutlet UILabel *title;
@property (retain, nonatomic) IBOutlet UITextView *content;
@property (retain, nonatomic) IBOutlet UITextField *subject;

@property (retain, nonatomic) IBOutlet UIButton *cancel;
@property (retain, nonatomic) IBOutlet UIButton *confirm;
@property (assign, nonatomic) id target;
@property (assign, nonatomic) SEL cancelSeletor;
@property (assign, nonatomic) SEL commitSeletor;
@property (retain, nonatomic) IBOutlet UILabel *shareToSina;
@property (retain, nonatomic) IBOutlet UILabel *shareToQQ;

- (IBAction)clickCancel:(id)sender;
- (IBAction)clickConfirm:(id)sender;
- (IBAction)clickSinaCheckBox:(UIButton *)sender;
- (IBAction)clickQQCheckBox:(UIButton *)sender;
- (IBAction)clickClose:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *sinaCheckBox;
@property (retain, nonatomic) IBOutlet UIButton *qqCheckBox;

@end


@implementation InputAlertView

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

- (void)updateView
{
    //update the font...
    [self.cancel setTitle:NSLS(@"kTwoSpaceCancel") forState:UIControlStateNormal];
    [self.confirm setTitle:NSLS(@"kTwoSpaceConfirm") forState:UIControlStateNormal];

    [self addTarget:self action:@selector(clickMask:) forControlEvents:UIControlEventTouchUpInside];

    [self.sinaCheckBox setSelected:[self canShareViaSina]];
    [self.qqCheckBox setSelected:[self canShareViaQQ]];

    [self.shareToSina setText:NSLS(@"kSinaWeibo")];
    [self.shareToQQ setText:NSLS(@"kTencentWeibo")];
//    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
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

+ (id)inputAlertViewWith:(NSString *)title
                 content:(NSString *)content
                  target:(id)target
           commitSeletor:(SEL)commitSeletor
           cancelSeletor:(SEL)cancelSeletor
                  hasSNS:(BOOL)hasSNS
{
    return [self inputAlertViewWith:title content:content target:target commitSeletor:commitSeletor cancelSeletor:cancelSeletor hasSNS:hasSNS hasSubject:NO];
}

+ (id)inputAlertViewWith:(NSString *)title
                 content:(NSString *)content
                  target:(id)target
           commitSeletor:(SEL)commitSeletor
           cancelSeletor:(SEL)cancelSeletor
                  hasSNS:(BOOL)hasSNS
              hasSubject:(BOOL)hasSubject
{
    InputAlertView *view = [self createView];
    [view.title setText:title];
    [view.content setText:content];
    view.target = target;
    view.commitSeletor = commitSeletor;
    view.cancelSeletor = cancelSeletor;
    
    if (!hasSNS) {
        CGRect inputRect = view.content.frame;
        [view.contentBg setFrame:CGRectMake(inputRect.origin.x, inputRect.origin.y, inputRect.size.width, view.qqCheckBox.center.y - inputRect.origin.y)];
        //        [view.contentBg setFrame:view.content.frame];
        [view.content setCenter:view.contentBg.center];
        [view.qqCheckBox setHidden:YES];
        [view.sinaCheckBox setHidden:YES];
        [view.shareToQQ setHidden:YES];
        [view.shareToSina setHidden:YES];
    }
    
    if (hasSubject) {
        [view.subject setBackground:[[ShareImageManager defaultManager] inputDialogInputBgImage]];
        view.subject.delegate = view;
        [view.subject setPlaceholder:NSLS(@"kLittleGeeDrawTitle")];
        [view.subject setHidden:NO];
        CGRect inputRect = view.content.frame;
        [view.contentBg setFrame:CGRectMake(inputRect.origin.x, inputRect.origin.y + view.subject.frame.size.height, inputRect.size.width, view.contentBg.frame.size.height - view.subject.frame.size.height)];
        [view.content setFrame:view.contentBg.frame];
    }
    return view;
}


- (NSString *)contentText
{
    return self.content.text;
}

- (NSString *)setContentText:(NSString *)text
{
    [self.content setText:text];
    return self.content.text;
}

- (void)dealloc {
    PPDebug(@"%@ dealloc", self);
    PPRelease(_title);
    PPRelease(_content);
    PPRelease(_cancel);
    PPRelease(_confirm);
    PPRelease(_shareToSina);
    PPRelease(_shareToQQ);
    PPRelease(_sinaCheckBox);
    PPRelease(_qqCheckBox);
    PPRelease(_subject);
    [_contentBg release];
    [super dealloc];
}


#define DismissTimeInterval 0.5

- (CGPoint)hideCenter
{
    return CGPointMake(CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds));
}

- (void)showInView:(UIView *)view animated:(BOOL)animated
{
    if (_maxInputLen > 0 && [self.content.text length] >= _maxInputLen) {
        NSString* text = [self.content.text substringToIndex:_maxInputLen];
        [self.content setText:text];
    }
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

- (NSSet *)setForShareType
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

- (IBAction)clickConfirm:(id)sender {
    if (!_subject.hidden && [_subject.text length] == 0) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kMustHaveTitle") delayTime:1.5];
        return;
    }
    if (self.commitSeletor != NULL && [self.target respondsToSelector:self.commitSeletor]) {
        NSSet *shareSet = [self setForShareType];
        [self.target performSelector:self.commitSeletor withObject:shareSet];
    }
    [self dismiss:YES];
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

- (IBAction)clickClose:(id)sender {
    [self dismiss:YES];
}

- (IBAction)clickMask:(id)sender {
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

- (void)setCanClickCommitButton:(BOOL)can
{
    self.confirm.userInteractionEnabled = can;
    self.confirm.enabled = can;
}

- (void)clickConfirm
{
    [self clickConfirm:self.confirm];
}
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.maxInputLen > 0 && range.location >= self.maxInputLen)
        return NO; // return NO to not change text
    return YES;
}

@end
