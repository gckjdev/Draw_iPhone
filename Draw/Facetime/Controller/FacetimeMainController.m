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
#import "UserManager.h"
#import "UIUtils.h"
#import "DiceAvatarView.h"
#import "HKGirlFontLabel.h"
#import "AnimationManager.h"

typedef enum {
    FacetimeChatRequestTypeOnlyMale = 0,
    FacetimeChatRequestTypeOnlyFemale = 1,
    FacetimeChatRequestTypeRandom = 2
}FacetimeChatRequestType;

@interface TestView : UIView   

@end

@implementation TestView

- (void)dealloc
{
    [super dealloc];
}

@end

@implementation FacetimeMainController
@synthesize testDiceAvatar = _testDiceAvatar;
@synthesize test;

- (void)dealloc
{
    [_matchingFacetimeView release];
    [_facetimeUserInfoView release];
    [_testDiceAvatar release];
    [test release];
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
    [self.testDiceAvatar setUrlString:[UserManager defaultManager].avatarURL userId:nil gender:NO level:0 drunkPoint:0 wealth:0];
    [self.testDiceAvatar setProgress:0.4];
    self.testDiceAvatar.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setTestDiceAvatar:nil];

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

- (BOOL)checkFacetimeId
{
    if ([UserManager defaultManager].facetimeId == nil 
        || [UserManager defaultManager].facetimeId.length == 0) {
        InputDialog *dialog = [InputDialog dialogWith:NSLS(@"kFacetimeId") delegate:self];
        [dialog showInView:self.view];
        return NO;
    }
    return YES;
}

- (void)showFacetimeUserView:(PBGameUser*)user 
              isChosenToInit:(BOOL)isChosenToInit
{
    if (!_facetimeUserInfoView) {
        _facetimeUserInfoView = [[FacetimeUserInfoView createUserInfoView] retain];
        [self.view addSubview:_facetimeUserInfoView];
    }
    [_facetimeUserInfoView showFacetimeUser:user 
                             isChosenToInit:isChosenToInit
                           inViewController:self 
                                     inTime:0.1];
}

- (IBAction)chatToMale:(id)sender
{
    _requestType = FacetimeChatRequestTypeOnlyMale;
    if (![self checkFacetimeId]) {
        return;
    }
    [self showMatchingView];    
    [[FacetimeService defaultService] connectServer:self];
}

- (IBAction)chatToFemale:(id)sender
{
    _requestType = FacetimeChatRequestTypeOnlyFemale;
    if (![self checkFacetimeId]) {
        return;
    }
    [self showMatchingView];
    [[FacetimeService defaultService] connectServer:self];

}

- (IBAction)chatToAnyOne:(id)sender
{
    _requestType = FacetimeChatRequestTypeRandom;
    if (![self checkFacetimeId]) {
        return;
    }
    [self showMatchingView];
    [[FacetimeService defaultService] connectServer:self];
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
      isChosenToInit:(BOOL)isChosenToInit
{
    _matchingFacetimeView.hidden = YES;
    PBGameUser* user = [userList objectAtIndex:0];
    //[[CommonMessageCenter defaultCenter] postMessageWithText:@"recieve message" delayTime:1];
    [self showFacetimeUserView:user 
                isChosenToInit:isChosenToInit];
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
    [UIUtils makeFaceTime:view.facetimeId];
}
- (void)clickChange:(FacetimeUserInfoView *)view
{
    [_facetimeUserInfoView setHidden:YES];
    [[FacetimeService defaultService] disconnectServer];
}

#pragma inputdialog delegate
- (void)didClickOk:(InputDialog *)dialog targetText:(NSString *)targetText
{
    [[UserManager defaultManager] setFacetimeId:targetText];
    [self showMatchingView];
    [[FacetimeService defaultService] connectServer:self];
}
- (void)didClickCancel:(InputDialog *)dialog
{
    
}

- (void)didClickOnAvatar:(DiceAvatarView *)view
{
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        view.center = CGPointMake(50, 50);
        view.center = self.view.center;
    } completion:^(BOOL finished) {
        
    }];
    [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionCurveLinear animations:^{
        view.center = CGPointMake(10, 200);
    } completion:^(BOOL finished) {
        
    }];

    //[view setIsBlackAndWhite:NO];
    
}

- (void)reciprocalEnd:(DiceAvatarView *)view
{
    

    
}


@end
