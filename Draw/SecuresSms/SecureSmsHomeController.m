//
//  SecureSmsHomeController.m
//  Draw
//
//  Created by haodong on 13-5-21.
//
//

#import "SecureSmsHomeController.h"
#import "UserManager.h"
#import "RegisterUserController.h"
#import "ConfigManager.h"
#import "UserDetailViewController.h"
#import "SelfUserDetail.h"
#import "FriendController.h"
#import "StatisticManager.h"
#import "ChatListController.h"
#import "SecureSmsUserSettingController.h"
#import "UserManager.h"
#import "UIViewUtils.h"
#import "AdService.h"

@interface SecureSmsHomeController ()

@property (assign, nonatomic) PureChatType type;
@property (retain, nonatomic) UIView  *adView;

@end

@implementation SecureSmsHomeController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_adView release];
    [_chatButton release];
    [_friendsButton release];
    [_meButton release];
    [_supportButton release];
    [super dealloc];
}

- (void)viewDidUnload {
    [[AdService defaultService] clearAdView:_adView];
    [self setAdView:nil];
    [self setChatButton:nil];
    [self setFriendsButton:nil];
    [self setMeButton:nil];
    [self setSupportButton:nil];
    [super viewDidUnload];
}

- (id)initWithType:(PureChatType)type
{
    self = [super init];
    if (self) {
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIEdgeInsets imageEdgeInsets; 
    UIEdgeInsets titleEdgeInsets;
    if ([DeviceDetection isIPAD]) {
        imageEdgeInsets = UIEdgeInsetsMake(0, 24, 0, 0);
        titleEdgeInsets = UIEdgeInsetsMake(0, 46, 0, 0);
    } else {
       imageEdgeInsets = UIEdgeInsetsMake(7, 13, 8, 188);
       titleEdgeInsets = UIEdgeInsetsMake(0, -18, 0, 0);
    }
    
    [self.chatButton setImageEdgeInsets:imageEdgeInsets];
    [self.meButton setImageEdgeInsets:imageEdgeInsets];
    
    [self.chatButton setTitleEdgeInsets:titleEdgeInsets];
    [self.meButton setTitleEdgeInsets:titleEdgeInsets];
    
    if (_type == PureChatTypeSecureSms) {
        [self.chatButton setImage:[UIImage imageNamed:@"secure_sms_chat@2x.png"] forState:UIControlStateNormal];
        [self.chatButton setTitle:NSLS(@"kSecureSmsChat") forState:UIControlStateNormal];
        [self.meButton setImage:[UIImage imageNamed:@"secure_sms_me2@2x.png"] forState:UIControlStateNormal];
    } else {
        [self.chatButton setImage:[UIImage imageNamed:@"secure_sms_locate@2x.png"] forState:UIControlStateNormal];
        [self.chatButton setTitle:NSLS(@"kSecureSmsLocate") forState:UIControlStateNormal];
        [self.meButton setImage:[UIImage imageNamed:@"secure_sms_me1@2x.png"] forState:UIControlStateNormal];
    }
    [self.friendsButton setTitle:NSLS(@"kSecureSmsFirends") forState:UIControlStateNormal];
    [self.meButton setTitle:NSLS(@"kSecureSmsMe") forState:UIControlStateNormal];
    [self.supportButton setTitle:NSLS(@"kSecureSmsSupport") forState:UIControlStateNormal];
    
    self.adView = [[AdService defaultService] createAdInView:self
                                                       frame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 70, 320, 50)
                                                   iPadFrame:CGRectMake((768-320)/2, 914, 320, 50)
                                                     useLmAd:NO];
    
    [self showInputView:nil];
}

- (BOOL)isRegistered
{
    return [[UserManager defaultManager] hasUser];
}

- (void)toRegister
{
    RegisterUserController *ruc = [[RegisterUserController alloc] init];
    [self.navigationController pushViewController:ruc animated:YES];
    [ruc release];
}

- (IBAction)clickChatButton:(id)sender {
    if (![self isRegistered]) {
        [self toRegister];
        return;
    } else {
        ChatListController *controller = [[ChatListController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
}

- (IBAction)clickFriendsButton:(id)sender {
    if (![self isRegistered]) {
        [self toRegister];
        return;
    } else {
        FriendController *mfc = [[FriendController alloc] init];
        if ([[StatisticManager defaultManager] fanCount] > 0) {
            [mfc setDefaultTabIndex:FriendTabIndexFan];
        }
        [self.navigationController pushViewController:mfc animated:YES];
        [mfc release];
    }
}

- (IBAction)clickMeButton:(id)sender {
    if (![self isRegistered]) {
        [self toRegister];
        return;
    } else {
//        UserDetailViewController* us = [[UserDetailViewController alloc] initWithUserDetail:[SelfUserDetail createDetail]];
//        [self.navigationController pushViewController:us animated:YES];
//        [us release];
        
        [self.navigationController pushViewController:[[[SecureSmsUserSettingController alloc] init] autorelease] animated:YES];
    }
}

- (IBAction)clickSupportButton:(id)sender {
    NSArray *list = [ConfigManager getLearnDrawFeedbackEmailList];
    if ([list count] == 0) {
        return;
    }
    NSString *subject = [NSString stringWithFormat:@"%@ %@", [UIUtils getAppName], NSLS(@"kFeedback")];
    [self sendEmailTo:list ccRecipients:nil bccRecipients:nil subject:subject body:@"" isHTML:NO delegate:nil];
}


- (void)showInputView:(NSString *)placeholder
{
    if (_type == PureChatTypeSecureSms) {
        
        if ([[UserManager defaultManager] isPasswordEmpty]) {
            return;
        }
        
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        NSArray *subViewList = keyWindow.subviews;
        for(UIView *subView in subViewList) {
            if ([subView isKindOfClass:[InputDialog class]]) {
                return;
            }
        }
        
        NSString *customPlaceholder = placeholder;
        if (customPlaceholder == nil) {
            customPlaceholder = NSLS(@"kEnterPassword");
        }
        
        InputDialog *dialog = [InputDialog dialogWith:NSLS(@"kUserLogin") delegate:self];
        dialog.cancelButton.hidden = YES;
        [dialog.okButton updateCenterX:dialog.okButton.superview.frame.size.width/2];
        [dialog.targetTextField setPlaceholder:customPlaceholder];
        [dialog showInView:keyWindow];
    }
}

#pragma mark - InputDialogDelegate methods
- (void)didClickOk:(InputDialog *)dialog targetText:(NSString *)targetText
{
    PPDebug(@"didClickOk:targetText:");
    if (NO == [[UserManager defaultManager] isPasswordCorrect:targetText]) {
        [self performSelector:@selector(showInputView:) withObject:NSLS(@"kEnterCorrectPassword") afterDelay:0.6];
    }
}

@end
