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
    self.userIdTextField.text = [NSString stringWithFormat:@"Mark_%d", i];

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

- (IBAction)clickSubmit:(id)sender
{
    // TODO dummy implementation here
    NSString* userId = self.userIdTextField.text;
    [[UserManager defaultManager] saveUserId:userId 
                                    nickName:userId 
                                   avatarURL:@"http://img03.taobaocdn.com/sns_logo/i3/T1ZC81Xc8yXXb1upjX_100x100.jpg"];
    [[DrawGameService defaultService] setUserId:userId];
    [[DrawGameService defaultService] setNickName:userId];
    [[DrawGameService defaultService] setAvatar:@"http://img03.taobaocdn.com/sns_logo/i3/T1ZC81Xc8yXXb1upjX_100x100.jpg"];
    
    [self.navigationController popViewControllerAnimatedWithTransition:UIViewAnimationTransitionCurlUp];
}

- (void)dealloc {
    [userIdTextField release];
    [super dealloc];
}
@end
