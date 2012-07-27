//
//  FacetimeUserInfoView.m
//  Draw
//
//  Created by Orange on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FacetimeUserInfoView.h"
#import "AnimationManager.h"
#import "ShareImageManager.h"
#import "GameBasic.pb.h"
#import "StableView.h"

#define AVATAR_VIEW_TAG 20120727

@implementation FacetimeUserInfoView
@synthesize avatarView;
@synthesize nickNameLabel;
@synthesize genderLabel;
@synthesize locationLabel;
@synthesize followStatusLabel;
@synthesize followButton;
@synthesize startFacetimeButton;
@synthesize changeButton;
@synthesize contentView;
@synthesize contentBackgroundImageView;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)startRunOutAnimation:(CFTimeInterval)timeInterval
{
    CAAnimation *runOut = [AnimationManager scaleAnimationWithFromScale:1 toScale:0.1 duration:timeInterval delegate:self removeCompeleted:NO];
    [runOut setValue:@"runOut" forKey:@"AnimationKey"];
    [self.contentView.layer addAnimation:runOut forKey:@"runOut"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* value = [anim valueForKey:@"AnimationKey"];
    if ([value isEqualToString:@"runOut"]) {
        self.hidden = YES;
    }
}


+ (FacetimeUserInfoView*)createUserInfoView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FacetimeUserInfoView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <FacetimeUserInfoView> but cannot find cell object from Nib");
        return nil;
    }
    FacetimeUserInfoView* view =  (FacetimeUserInfoView*)[topLevelObjects objectAtIndex:0];
    [view.contentBackgroundImageView setImage:[ShareImageManager defaultManager].friendDetailBgImage];
    return view;
}

- (void)showInViewController:(UIViewController<FacetimeUserInfoViewDelegate>*)superController 
                      inTime:(CFTimeInterval)timeInterval
{
    _runInAnimTime = timeInterval;
    _delegate = superController;
    CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:_runInAnimTime delegate:self removeCompeleted:NO];
    [self.contentView.layer addAnimation:runIn forKey:@"runIn"];
}
- (void)showFacetimeUser:(PBGameUser*)user 
        inViewController:(UIViewController<FacetimeUserInfoViewDelegate>*)superController 
                  inTime:(CFTimeInterval)timeInterval
{
    self.hidden = NO;
    //set avatar
    if (![self.contentView viewWithTag:AVATAR_VIEW_TAG]) {
        AvatarView* view = [[[AvatarView alloc] initWithUrlString:user.avatar
                                                            frame:self.avatarView.frame
                                                           gender:user.gender
                                                            level:0] autorelease];
        [self.contentView addSubview:view];
    }
    AvatarView* avatar = (AvatarView*)[self.contentView viewWithTag:AVATAR_VIEW_TAG];
    [avatar setAvatarUrl:user.avatar 
                  gender:user.gender ];
    
    [self.nickNameLabel setText:user.nickName];
    [self.locationLabel setText:user.location];
    [self.genderLabel setText:(user.gender)?NSLS(@"kMale"):NSLS(@"kFemale")];
    
}

- (IBAction)clickStart:(id)sender
{
    [self startRunOutAnimation:_runInAnimTime];
}

- (IBAction)clickChange:(id)sender
{
    
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
    [avatarView release];
    [nickNameLabel release];
    [genderLabel release];
    [locationLabel release];
    [followStatusLabel release];
    [followButton release];
    [startFacetimeButton release];
    [changeButton release];
    [contentView release];
    [contentBackgroundImageView release];
    [super dealloc];
}
@end
