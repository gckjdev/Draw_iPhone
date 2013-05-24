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

@interface SecureSmsHomeController ()

@property (assign, nonatomic) PureChatType type;

@end

@implementation SecureSmsHomeController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_chatButton release];
    [_friendsButton release];
    [_meButton release];
    [_supportButton release];
    [super dealloc];
}

- (void)viewDidUnload {
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
    
    if (_type == PureChatTypeSecureSms) {
        [self.chatButton setTitle:NSLS(@"kSecureSmsChat") forState:UIControlStateNormal];
    } else {
        [self.chatButton setTitle:NSLS(@"kSecureSmsLocate") forState:UIControlStateNormal];
    }

    [self.friendsButton setTitle:NSLS(@"kSecureSmsFirends") forState:UIControlStateNormal];
    [self.meButton setTitle:NSLS(@"kSecureSmsMe") forState:UIControlStateNormal];
    [self.supportButton setTitle:NSLS(@"kSecureSmsSupport") forState:UIControlStateNormal];
    
    [self showInputView];
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
        UserDetailViewController* us = [[UserDetailViewController alloc] initWithUserDetail:[SelfUserDetail createDetail]];
        [self.navigationController pushViewController:us animated:YES];
        [us release];
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


- (void)showInputView
{
    if (_type == PureChatTypeSecureSms) {
        
        NSArray *subViewList = self.view.subviews;
        for(UIView *subView in subViewList) {
            if ([subView isKindOfClass:[InputDialog class]]) {
                return;
            }
        }
        
        InputDialog *dialog = [InputDialog dialogWith:NSLS(@"kUserLogin") delegate:self];
        [dialog.targetTextField setPlaceholder:NSLS(@"kEnterPassword")];
        [dialog showInView:self.view];
    }
}

#pragma mark - InputDialogDelegate methods
- (void)didClickOk:(InputDialog *)dialog targetText:(NSString *)targetText
{
    
}

@end
