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
    
}

- (IBAction)clickFriendsButton:(id)sender {
    
}

- (IBAction)clickMeButton:(id)sender {
    if (![self isRegistered]) {
        [self toRegister];
        return;
    } else {
        
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

@end
