//
//  CommonUserInfoView.m
//  Draw
//
//  Created by Orange on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonUserInfoView.h"
#import "ShareImageManager.h"
#import "AnimationManager.h"
#import "LocaleUtils.h"
#define RUN_OUT_TIME 0.2
#define RUN_IN_TIME 0.4

@implementation CommonUserInfoView
@synthesize backgroundImageView;
@synthesize mask;
@synthesize contentView;
@synthesize userName;
@synthesize snsTagImageView;
@synthesize genderLabel;
@synthesize locationLabel;
@synthesize playWithUserLabel;
@synthesize chatToUserLabel;
@synthesize drawToUserButton;
@synthesize exploreUserFeedButton;
@synthesize chatToUserButton;
@synthesize followUserButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initTitle
{
    [self.playWithUserLabel setText:NSLS(@"kPlayWithHim")];
    [self.chatToUserLabel setText:NSLS(@"kChatToHim")];
}

- (void)initAvatar
{
    
}

- (void)initButton
{
    [self.chatToUserButton setTitle:NSLS(@"kChat") forState:UIControlStateNormal];
    [self.chatToUserButton setBackgroundImage:[ShareImageManager defaultManager].orangeImage forState:UIControlStateNormal];
    [self.drawToUserButton setTitle:NSLS(@"kDrawToHim") forState:UIControlStateNormal];
    [self.drawToUserButton setBackgroundImage:[ShareImageManager defaultManager].orangeImage forState:UIControlStateNormal];
    [self.exploreUserFeedButton setTitle:NSLS(@"kExploreHim") forState:UIControlStateNormal];
    [self.exploreUserFeedButton setBackgroundImage:[ShareImageManager defaultManager].orangeImage forState:UIControlStateNormal];
}

- (void)initView
{
    [self.backgroundImageView setImage:[ShareImageManager defaultManager].friendDetailBgImage];
    [self initAvatar];
    [self initTitle];
    [self initButton];
    
}

+ (CommonUserInfoView*)createUserInfoView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CommonUserInfoView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <CommonUserInfoView> but cannot find cell object from Nib");
        return nil;
    }
    CommonUserInfoView* view =  (CommonUserInfoView*)[topLevelObjects objectAtIndex:0];
    [view initView];
    
    CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:RUN_IN_TIME delegate:self removeCompeleted:NO];
    [view.contentView.layer addAnimation:runIn forKey:@"runIn"];
    
    return view;
}

+ (void)showUserInfoInView:(UIViewController*)superController
{
    CommonUserInfoView* view = [CommonUserInfoView createUserInfoView];
    [superController.view addSubview:view];
}

- (void)startRunOutAnimation
{
    CAAnimation *runOut = [AnimationManager scaleAnimationWithFromScale:1 toScale:0.1 duration:RUN_OUT_TIME delegate:self removeCompeleted:NO];
    [runOut setValue:@"runOut" forKey:@"AnimationKey"];
    [self.contentView.layer addAnimation:runOut forKey:@"runOut"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* value = [anim valueForKey:@"AnimationKey"];
    if ([value isEqualToString:@"runOut"]) {
        [self setHidden:YES];
        [self removeFromSuperview];
    }
}

- (IBAction)clickMask:(id)sender
{
    [self startRunOutAnimation];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [backgroundImageView release];
    [mask release];
    [contentView release];
    [userName release];
    [snsTagImageView release];
    [genderLabel release];
    [locationLabel release];
    [playWithUserLabel release];
    [chatToUserLabel release];
    [drawToUserButton release];
    [exploreUserFeedButton release];
    [chatToUserButton release];
    [followUserButton release];
    [super dealloc];
}
@end
