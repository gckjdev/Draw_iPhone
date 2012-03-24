//
//  CompleteUserInfoController.m
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CompleteUserInfoController.h"
#import "UserManager.h"

@implementation CompleteUserInfoController
@synthesize avatarLabel;
@synthesize nickNameLabel;
@synthesize avatarButton;
@synthesize nickNameTextField;
@synthesize submitButton;
@synthesize skipButton;
@synthesize changeAvatarMenu = _changeAvatarMenu;

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.nickNameTextField.text = [[UserManager defaultManager] nickName];
    
}

- (void)viewDidUnload
{
    [self setAvatarLabel:nil];
    [self setNickNameLabel:nil];
    [self setAvatarButton:nil];
    [self setNickNameTextField:nil];
    [self setSubmitButton:nil];
    [self setSkipButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_changeAvatarMenu release];
    [avatarLabel release];
    [nickNameLabel release];
    [avatarButton release];
    [nickNameTextField release];
    [submitButton release];
    [skipButton release];
    [super dealloc];
}

- (IBAction)clickSkip:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)clickSubmit:(id)sender
{
    
}

- (IBAction)clickAvatar:(id)sender
{
    self.changeAvatarMenu = [[ChangeAvatar alloc] init];
    [self.changeAvatarMenu showSelectionView:self];
}

- (void)didImageSelected:(UIImage *)image
{
    [self.avatarButton setBackgroundImage:image forState:UIControlStateNormal];
}

@end
