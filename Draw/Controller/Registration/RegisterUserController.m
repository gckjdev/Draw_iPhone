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
#import "GameNetworkConstants.h"
#import "AccountService.h"
#import "ShareImageManager.h"
#import "UserManager.h"
#import "RemoteDrawView.h"
#import "GameBasic.pb.h"
#import "ShowRemoteDrawController.h"
#import "DeviceDetection.h"
#import "CommonMessageCenter.h"
#import "PPSNSCommonService.h"
#import "PPSNSIntegerationService.h"
#import "PPSNSConstants.h"
#import "GameSNSService.h"

@implementation RegisterUserController
@synthesize backgroundImageView;
@synthesize userIdTextField;
@synthesize submitButton;
@synthesize promptLabel;
@synthesize titleLabel;
@synthesize facebookButton;
@synthesize sinaButton;
@synthesize qqButton;
@synthesize inviteLabel;
@synthesize remoteDrawArray;

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
//    int i = rand() % 100;
//    self.userIdTextField.text = [NSString stringWithFormat:@"mark_%d@21cn.com", i];

    [super viewDidLoad];
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kFirstGame") delayTime:1.5 isHappy:NO];
    // Do any additional setup after loading the view from its nib.
    
    self.inviteLabel.hidden =YES;
    self.inviteLabel.text = NSLS(@"kRegisterToEnter");
    self.promptLabel.text = NSLS(@"kRegisterPromptLabel");
    self.titleLabel.text = [UIUtils getAppName];
    self.userIdTextField.placeholder = NSLS(@"kEnterEmail");
    [self.userIdTextField setBackground:[[ShareImageManager defaultManager] inputImage]];
    userIdTextField.delegate = self;
    
    [self.submitButton setTitle:NSLS(@"kStartGame") forState:UIControlStateNormal];
    [self.submitButton setBackgroundImage:[[ShareImageManager defaultManager] orangeImage] 
                                 forState:UIControlStateNormal];
    
    [self.backgroundImageView setImage:[UIImage imageNamed:[GameApp background]]];
    
    if ([LocaleUtils isChina]){
        sinaButton.hidden = NO;
        qqButton.hidden = NO;
        facebookButton.hidden = YES;
    }
    else{
        sinaButton.hidden = YES;
        qqButton.hidden = YES;
        facebookButton.hidden = NO;        
    }
    
    [self addRemoteDraw];    
    [self.userIdTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{    
    self.navigationController.navigationBarHidden = YES;
    [self hideActivity];
    [self.userIdTextField becomeFirstResponder];
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    
    [self setUserIdTextField:nil];
    [self setSubmitButton:nil];
    [self setPromptLabel:nil];
    [self setTitleLabel:nil];
    [self setFacebookButton:nil];
    [self setSinaButton:nil];
    [self setQqButton:nil];
    [self setInviteLabel:nil];
    [self setRemoteDrawArray:nil];
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.remoteDrawArray = nil;
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
    
    [self.view endEditing:YES];    
    [[UserService defaultService] registerUser:userId password:@"" viewController:self];    
}

- (void)snsLogin:(PPSNSType)snsType
{
    PPSNSCommonService* service = [[PPSNSIntegerationService defaultService] snsServiceByType:snsType];
    NSString* name = [service snsName];
    
    [service login:^(NSDictionary *userInfo) {
        PPDebug(@"%@ Login Success", name);
        
        [self showActivityWithText:NSLS(@"Loading")];
        
        [service readMyUserInfo:^(NSDictionary *userInfo) {
            [self hideActivity];
            PPDebug(@"%@ readMyUserInfo Success, userInfo=%@", name, [userInfo description]);
            if (userInfo == nil){
                return;
            }
            
            [[UserService defaultService] registerUserWithSNSUserInfo:userInfo viewController:self];
        }
        failureBlock:^(NSError *error) {
            PPDebug(@"%@ readMyUserInfo Failure", name);
            [self hideActivity];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
    } failureBlock:^(NSError *error) {
        PPDebug(@"%@ Login Failure", name);
    }];
}

- (IBAction)clickSinaLogin:(id)sender
{
    [self.view endEditing:YES];
    
//    _currentLoginType = REGISTER_TYPE_SINA;
//    [[SinaSNSService defaultService] startLogin:self];

    [self snsLogin:TYPE_SINA];
}

- (IBAction)clickQQLogin:(id)sender
{
    [self.view endEditing:YES];
//    _currentLoginType = REGISTER_TYPE_QQ;
//    
//    self.navigationController.navigationBarHidden = NO;
//    self.navigationController.navigationItem.title = NSLS(@"微博授权");
//    [[QQWeiboService defaultService] startLogin:self];

    [self snsLogin:TYPE_QQ];

}

- (IBAction)clickFacebookLogin:(id)sender
{
    [self.view endEditing:YES];
//    _currentLoginType = REGISTER_TYPE_FACEBOOK;
//    [[FacebookSNSService defaultService] startLogin:self];

    [self snsLogin:TYPE_FACEBOOK];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self clickSubmit:textField];
    return NO;
}

- (IBAction)textFieldDone:(id)sender
{
    [self clickSubmit:sender];
}

- (IBAction)backgroundTap:(id)sender
{
    [userIdTextField resignFirstResponder];
}

- (void)dealloc {
    [userIdTextField release];
    [submitButton release];
    [promptLabel release];
    [titleLabel release];
    [facebookButton release];
    [sinaButton release];
    [qqButton release];
    [remoteDrawArray release];
    [inviteLabel release];
    [backgroundImageView release];
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
        else if (_currentLoginType == REGISTER_TYPE_SINA && 
                 [[[UserManager defaultManager] nickName] hasPrefix:@"新浪微博"]){
            CompleteUserInfoController* controller = [[[CompleteUserInfoController alloc] init] autorelease];
            [self.navigationController pushViewController:controller animated:NO];    
        }
        else{
            [self.navigationController popToRootViewControllerAnimated:YES];            
        }

        PPSNSType snsType = TYPE_EMAIL;
        switch (_currentLoginType) {
            case REGISTER_TYPE_QQ:
            {
                snsType = TYPE_QQ;
            }
                break;
            case REGISTER_TYPE_SINA:
            {
                snsType = TYPE_SINA;
            }
                break;
                
            default:
                break;
        }
        
        [GameSNSService askFollowOfficialWeibo:snsType];
    }
    else{        
        // do nothing here
    }
}

- (void)didUserLogined:(int)resultCode
{
    self.navigationController.navigationBarHidden = YES;
    
    // go to next view
    PPDebug(@"<didUserRegistered> result code = %d", resultCode);
    if (resultCode == 0){
        
        [[AccountService defaultService] syncAccountAndItem];
        
        [self.navigationController popToRootViewControllerAnimated:YES]; 
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

#pragma mark - input idalog delegate
- (void)didClickOk:(InputDialog *)dialog targetText:(NSString *)targetText
{
    [[UserService defaultService] loginUserByEmail:userIdTextField.text 
                                          password:[targetText encodeMD5Base64:PASSWORD_KEY]
                                    viewController:self];
}
- (void)didClickCancel:(InputDialog *)dialog
{
    
}


#define DRAW_VIEW_COUNT 6
#define DRAW_VIEW_START_Y_IPHONE 210
#define DRAW_VIEW_START_Y_IPAD 440

- (void)addRemoteDraw
{
    CGFloat yStart;
    if ([DeviceDetection isIPAD]) {
        yStart = DRAW_VIEW_START_Y_IPAD;
    }else {
        yStart = DRAW_VIEW_START_Y_IPHONE;
    }
    
    for (int i= 0 ; i < [self.remoteDrawArray count] && i<DRAW_VIEW_COUNT ; i++) {
        RemoteDrawView *remoteDrawView  = [RemoteDrawView creatRemoteDrawView];
        PBDraw *draw = [self.remoteDrawArray objectAtIndex:i];
        [remoteDrawView setViewByRemoteDrawData:draw index:i];
        remoteDrawView.delegate = self;
        
        CGFloat xSpace, ySpace , x, y;
        xSpace = (self.view.frame.size.width - 3 * remoteDrawView.frame.size.width)/4;
        ySpace = xSpace;
        x = ((i % 3) + 1) * xSpace + (i % 3) * (remoteDrawView.frame.size.width);
        y = yStart + (i / 3) * (remoteDrawView.frame.size.height);
        
        remoteDrawView.frame = (CGRect){CGPointMake(x, y), remoteDrawView.frame.size};
        [self.view addSubview:remoteDrawView];
        
        [remoteDrawView.showDrawView play];
    }
}

#pragma mark - DrawDataServiceDelegate method
- (void)didFindRecentDraw:(NSArray *)remoteDrawDataList result:(int)resultCode
{
    self.remoteDrawArray = remoteDrawDataList;
    
    [self addRemoteDraw];
}

#pragma mark - RemoteDrawViewDelegate method
- (void)didClickPlaybackButton:(int)index
{
    PPDebug(@"<didClickPlaybackButton> index:%d",index);
    PBDraw *draw = [self.remoteDrawArray objectAtIndex:index];
    ShowRemoteDrawController *controller = [[ShowRemoteDrawController alloc] initWithPBDraw:draw];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}


@end
