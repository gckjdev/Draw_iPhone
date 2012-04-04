//
//  RegisterUserController.m
//  Draw
//
//  Created by  on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RegisterUserController.h"
#import "UserManager.h"
#import "DrawGameService.h"
#import "UINavigationController+UINavigationControllerAdditions.h"
#import "UserService.h"
#import "CompleteUserInfoController.h"
#import "StringUtil.h"
#import "PPDebug.h"
#import "SinaSNSService.h"
#import "QQWeiboService.h"
#import "GameNetworkConstants.h"
#import "AccountService.h"

@implementation RegisterUserController
@synthesize userIdTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    // TODO for test
    int i = rand() % 100;
    self.userIdTextField.text = [NSString stringWithFormat:@"mark_%d@21cn.com", i];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    
    [self setUserIdTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

+ (void)showAt:(UIViewController*)superViewController
{
    RegisterUserController* userController = [[RegisterUserController alloc] init];
    [superViewController.navigationController pushViewController:userController animated:NO];
    [userController release];
}

- (void)addTestUser
{
    NSArray* randomAvatar = [NSArray arrayWithObjects:
                             @"http://file11.joyes.com/other/2010/01/25/ad7440f6997c48de85fed5a0527e05c0.jpg", 
                             @"http://img03.taobaocdn.com/sns_logo/i3/T1ZC81Xc8yXXb1upjX_100x100.jpg",
                             @"http://img06.taobaocdn.com/sns_logo/i6/T1vY4pXhlDXXartXjX_100x100.jpg",
                             @"http://img01.taobaocdn.com/sns_logo/i1/T1uBFLXc4IXXaCwpjX_100x100.jpg",
                             @"http://www.hampoo.com/files/public/member/2011/06/20/142/images/20110704095135_thumb2.jpg",
                             nil];
    
    srand(time(0));
    
    NSString* avatar = [randomAvatar objectAtIndex:random() % [randomAvatar count]];
    
    NSString* userId = self.userIdTextField.text;
    [[UserManager defaultManager] saveUserId:userId 
                                       email:@"" 
                                    password:@""     
                                    nickName:userId 
                                   avatarURL:avatar];
    [[DrawGameService defaultService] setUserId:userId];
    [[DrawGameService defaultService] setNickName:userId];
    [[DrawGameService defaultService] setAvatar:avatar];
}

- (BOOL)verifyField
{
    if ([userIdTextField.text length] == 0){
        // [UIUtils alert:@"电子邮件地址不能为空"];
        [UIUtils alert:NSLS(@"kEmailEmpty")];
        [userIdTextField becomeFirstResponder];
        return NO;
    }
    
    if (NSStringIsValidEmail(userIdTextField.text) == NO){
        // @"输入的电子邮件地址不合法，请重新输入"
        [UIUtils alert:NSLS(@"kInvalidEmail")];
        [userIdTextField becomeFirstResponder];
        return NO;        
    }
    
//    if ([loginPasswordTextField.text length] == 0){
//        [UIUtils alert:@"密码不能为空"];
//        [loginPasswordTextField becomeFirstResponder];
//        return NO;
//    }         
    
    return YES;
}


- (IBAction)clickSubmit:(id)sender
{    
    _currentLoginType = REGISTER_TYPE_EMAIL;
    
    NSString* userId = self.userIdTextField.text;    
    if ([self verifyField] == NO){        
        return;
    }    
    [[UserService defaultService] registerUser:userId password:@"" viewController:self];    
}

- (IBAction)clickSinaLogin:(id)sender
{
    _currentLoginType = REGISTER_TYPE_SINA;
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationItem.title = NSLS(@"微博授权");
    [[SinaSNSService defaultService] startLogin:self];
}

- (IBAction)clickQQLogin:(id)sender
{
    _currentLoginType = REGISTER_TYPE_QQ;
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationItem.title = NSLS(@"微博授权");
    [[QQWeiboService defaultService] startLogin:self];
}

- (void)dealloc {
    [userIdTextField release];
    [super dealloc];
}

- (void)didUserRegistered:(int)resultCode
{
    self.navigationController.navigationBarHidden = YES;

    // go to next view
    PPDebug(@"<didUserRegistered> result code = %d", resultCode);
    if (resultCode == 0){
        
        [[AccountService defaultService] syncAccountAndItem];
        
        if (_currentLoginType == REGISTER_TYPE_EMAIL){
            CompleteUserInfoController* controller = [[[CompleteUserInfoController alloc] init] autorelease];
            [self.navigationController pushViewController:controller animated:NO];    
        }
        else{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    else{
        // TODO show error code?
        [self.navigationController popToViewController:self animated:YES];
    }
}

- (void)didLogin:(int)result userInfo:(NSDictionary*)userInfo
{        
    if (result == 0){
        [[UserService defaultService] registerUserWithSNSUserInfo:userInfo viewController:self];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
