//
//  FacetimeMainController.m
//  Draw
//
//  Created by  on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FacetimeMainController.h"
#import "FacetimeService.h"
#import "CommonMessageCenter.h"
#import "CommonUserInfoView.h"
#import "GameBasic.pb.h"

@implementation FacetimeMainController

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[FacetimeService defaultService] connectServer:self];
    [self showActivity];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)chatToMale:(id)sender
{
    [self showActivity];
    [[FacetimeService defaultService] sendFacetimeRequestWithGender:YES delegate:self];
}

- (IBAction)chatToFemale:(id)sender
{
    [self showActivity];
    [[FacetimeService defaultService] sendFacetimeRequestWithGender:NO delegate:self];
}

- (IBAction)chatToAnyOne:(id)sender
{
    [self showActivity];
    [[FacetimeService defaultService] sendFacetimeRequest:self];
}

- (IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - facetimeservice delegate
- (void)didConnected
{
    [self hideActivity];
    [[CommonMessageCenter defaultCenter] postMessageWithText:@"connected" delayTime:1];
}
- (void)didBroken
{
    [[CommonMessageCenter defaultCenter] postMessageWithText:@"broken" delayTime:1];
}
- (void)didMatchUser:(PBGameUser *)user
{
    [self hideActivity];
    [[CommonMessageCenter defaultCenter] postMessageWithText:@"recieve message" delayTime:1];
    NSString* gender = user.gender?@"m":@"f";
    [CommonUserInfoView showUser:user.userId nickName:user.nickName avatar:user.avatar gender:gender location:user.location level:user.userLevel hasSina:NO hasQQ:NO hasFacebook:NO infoInView:self];
}
@end
