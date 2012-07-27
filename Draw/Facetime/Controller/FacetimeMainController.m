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

typedef enum {
    FacetimeChatRequestTypeOnlyMale = 0,
    FacetimeChatRequestTypeOnlyFemale = 1,
    FacetimeChatRequestTypeRandom = 2
}FacetimeChatRequestType;

@implementation FacetimeMainController

- (void)dealloc
{
    [_matchingFacetimeView release];
    [_facetimeUserInfoView release];
    [super dealloc];
}

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
    _matchingFacetimeView = nil;
    _facetimeUserInfoView = nil;
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

- (void)showMatchingView
{
    if (_matchingFacetimeView == nil) {
        _matchingFacetimeView = [[MatchingFacetimeUserView createUserInfoView] retain];
        [self.view addSubview:_matchingFacetimeView];
    }
    [_matchingFacetimeView showInViewController:self inTime:0.1];
}
- (void)showFacetimeUserView:(PBGameUser*)user
{
    if (!_facetimeUserInfoView) {
        _facetimeUserInfoView = [[FacetimeUserInfoView createUserInfoView] retain];
        [self.view addSubview:_facetimeUserInfoView];
    }
    [_facetimeUserInfoView showFacetimeUser:user 
                           inViewController:self 
                                     inTime:0.1];
}

- (IBAction)chatToMale:(id)sender
{
    [self showMatchingView];
    _requestType = FacetimeChatRequestTypeOnlyMale;
    [[FacetimeService defaultService] connectServer:self];
    //[[FacetimeService defaultService] sendFacetimeRequestWithGender:YES delegate:self];
}

- (IBAction)chatToFemale:(id)sender
{
    [self showMatchingView];
    _requestType = FacetimeChatRequestTypeOnlyFemale;
    [[FacetimeService defaultService] connectServer:self];
    //[[FacetimeService defaultService] sendFacetimeRequestWithGender:NO delegate:self];
}

- (IBAction)chatToAnyOne:(id)sender
{
    [self showMatchingView];
    _requestType = FacetimeChatRequestTypeRandom;
    [[FacetimeService defaultService] connectServer:self];
    //[[FacetimeService defaultService] sendFacetimeRequest:self];
}

- (IBAction)clickBack:(id)sender
{
    [[FacetimeService defaultService] disconnectServer];
    [[FacetimeService defaultService] setMatchDelegate:nil];
    [[FacetimeService defaultService] setConnectionDelegate:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - facetimeservice delegate
- (void)didConnected
{
    PPDebug(@"<FacetimeMainController> start matching, type = %d",_requestType);
    //[_matchingFacetimeView.matchingLabel setText:NSLS(@"kMatching")];
    switch (_requestType) {
        case FacetimeChatRequestTypeOnlyMale: {
            [[FacetimeService defaultService] sendFacetimeRequestWithGender:YES delegate:self];
        }break;
        case FacetimeChatRequestTypeOnlyFemale: {
            [[FacetimeService defaultService] sendFacetimeRequestWithGender:NO delegate:self];
        }break;
        case FacetimeChatRequestTypeRandom:
        default: {
            [[FacetimeService defaultService] sendFacetimeRequest:self];
        } break;
    }
}
- (void)didBroken
{
    [[CommonMessageCenter defaultCenter] postMessageWithText:@"broken" delayTime:1];
}
- (void)didMatchUser:(NSArray *)userList
{
    _matchingFacetimeView.hidden = YES;
    PBGameUser* user = [userList objectAtIndex:0];
    //[[CommonMessageCenter defaultCenter] postMessageWithText:@"recieve message" delayTime:1];
    [self showFacetimeUserView:user];
}
- (void)didMatchUserFailed:(MatchUserFailedType)type
{
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kMatchUserFailed") delayTime:1 isHappy:NO];
}

#pragma mark - MatchingFacetimeUserViewDelegate
- (void)clickCancelButton:(MatchingFacetimeUserView *)view
{
    [[FacetimeService defaultService] disconnectServer];
}

#pragma mark - FacetimeUserInfoViewDelegate
- (void)clickStartChat:(FacetimeUserInfoView *)view
{
    [[FacetimeService defaultService] disconnectServer];
}
- (void)clickChange:(FacetimeUserInfoView *)view
{
    
}
@end
