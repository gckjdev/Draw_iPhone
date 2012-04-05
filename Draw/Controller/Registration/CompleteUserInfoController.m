//
//  CompleteUserInfoController.m
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CompleteUserInfoController.h"
#import "UserManager.h"
#import "UserService.h"
#import "ShareImageManager.h"

@implementation CompleteUserInfoController
@synthesize maleSelectImageView;
@synthesize femaleSelectImageView;
@synthesize avatarLabel;
@synthesize nickNameLabel;
@synthesize maleAvatarButton;
@synthesize nickNameTextField;
@synthesize submitButton;
@synthesize skipButton;
@synthesize changeAvatarMenu = _changeAvatarMenu;
@synthesize avatarImage = _avatarImage;
@synthesize femaleAvatarButton;

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

- (void)updateSelectImageView
{
    if (_isFemale == NO){
        [self.maleSelectImageView setImage:[[ShareImageManager defaultManager] avatarSelectImage]];
        [self.femaleSelectImageView setImage:[[ShareImageManager defaultManager] avatarUnSelectImage]];
    }
    else{
        [self.maleSelectImageView setImage:[[ShareImageManager defaultManager] avatarUnSelectImage]];
        [self.femaleSelectImageView setImage:[[ShareImageManager defaultManager] avatarSelectImage]];
    }
}

- (void)updateAvatarButton
{
    if (_isFemale){
        // set male background to default
        [self.maleAvatarButton setBackgroundImage:[[ShareImageManager defaultManager] maleDefaultAvatarImage]
                                         forState:UIControlStateNormal];
    }
    else{
        // set female background to default
        [self.maleAvatarButton setBackgroundImage:[[ShareImageManager defaultManager] femaleDefaultAvatarImage]
                                         forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.nickNameTextField.text = [[UserManager defaultManager] nickName];
        
//    self.avatarImage = [[UserManager defaultManager] avatarImage];
//    [self.maleAvatarButton setBackgroundImage:_avatarImage forState:UIControlStateNormal];
    [self.maleAvatarButton setBackgroundImage:[[ShareImageManager defaultManager] maleDefaultAvatarImage]
                                     forState:UIControlStateNormal];
    [self.femaleAvatarButton setBackgroundImage:[[ShareImageManager defaultManager] femaleDefaultAvatarImage]
                                     forState:UIControlStateNormal];
    
    [self.nickNameTextField setPlaceholder:NSLS(@"kInputNickName")];
    [self.nickNameTextField setBackground:[[ShareImageManager defaultManager] inputImage]];
    //    userIdTextField.delegate = self;
    
    [self.submitButton setTitle:NSLS(@"kSubmit") forState:UIControlStateNormal];
    [self.submitButton setBackgroundImage:[[ShareImageManager defaultManager] orangeImage] 
                                 forState:UIControlStateNormal];
    
    [self.skipButton setTitle:NSLS(@"Skip") forState:UIControlStateNormal];
    [self.skipButton setBackgroundImage:[[ShareImageManager defaultManager] woodImage] 
                                 forState:UIControlStateNormal];
    
    [self updateSelectImageView];
}

- (void)viewDidUnload
{
    [self setAvatarLabel:nil];
    [self setNickNameLabel:nil];
    [self setMaleAvatarButton:nil];
    [self setNickNameTextField:nil];
    [self setSubmitButton:nil];
    [self setSkipButton:nil];
    [self setFemaleAvatarButton:nil];
    [self setMaleSelectImageView:nil];
    [self setFemaleSelectImageView:nil];
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
    [_avatarImage release];
    [_changeAvatarMenu release];
    [avatarLabel release];
    [nickNameLabel release];
    [maleAvatarButton release];
    [nickNameTextField release];
    [submitButton release];
    [skipButton release];
    [femaleAvatarButton release];
    [maleSelectImageView release];
    [femaleSelectImageView release];
    [super dealloc];
}

- (NSString*)getGender
{
    if (_isFemale)
        return @"f";
    else
        return @"m";
}

- (IBAction)clickSkip:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)clickSubmit:(id)sender
{
    if ([self.nickNameTextField.text length] <= 0){
        [UIUtils alert:NSLS(@"kNickNameEmpty")];
        [self.nickNameTextField becomeFirstResponder];
        return;
    }
    
    [self.nickNameTextField endEditing:YES];    
    [[UserService defaultService] updateUserAvatar:_avatarImage 
                                          nickName:self.nickNameTextField.text
                                            gender:[self getGender]
                                    viewController:self];
}

- (IBAction)clickMaleAvatar:(id)sender
{
    _isFemale = NO;
    [self updateSelectImageView];
    
    self.changeAvatarMenu = [[[ChangeAvatar alloc] init] autorelease];
    [self.changeAvatarMenu setAutoRoundRect:NO];
    [self.changeAvatarMenu showSelectionView:self];
}

- (IBAction)clickFemaleAvatar:(id)sender
{
    _isFemale = YES;
    [self updateSelectImageView];
    
    self.changeAvatarMenu = [[[ChangeAvatar alloc] init] autorelease];
    [self.changeAvatarMenu setAutoRoundRect:NO];
    [self.changeAvatarMenu showSelectionView:self];    
}

- (void)didImageSelected:(UIImage *)image
{    
    if (_isFemale){
        [self.femaleAvatarButton setBackgroundImage:image forState:UIControlStateNormal];
    }
    else{
        [self.maleAvatarButton setBackgroundImage:image forState:UIControlStateNormal];
    }
    
    [self updateAvatarButton];

    self.avatarImage = image;
}

- (void)didUserUpdated:(int)resultCode
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
