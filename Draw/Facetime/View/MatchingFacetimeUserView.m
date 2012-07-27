//
//  MatchingFacetimeUserView.m
//  Draw
//
//  Created by Orange on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MatchingFacetimeUserView.h"
#import "AnimationManager.h"
#import "ShareImageManager.h"

@implementation MatchingFacetimeUserView
@synthesize avatarView;
@synthesize cancelButton;
@synthesize matchingLabel;
@synthesize contentView;
@synthesize contentViewBackgroundImageView;
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
        if (_delegate && [_delegate respondsToSelector:@selector(clickCancelButton:)]) {
            [_delegate clickCancelButton:self];
        }
        self.hidden = YES;
    }
}


+ (MatchingFacetimeUserView*)createUserInfoView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MatchingFacetimeUserView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <MatchingFacetimeUserView> but cannot find cell object from Nib");
        return nil;
    }
    MatchingFacetimeUserView* view =  (MatchingFacetimeUserView*)[topLevelObjects objectAtIndex:0];
    [view.contentViewBackgroundImageView setImage:[ShareImageManager defaultManager].friendDetailBgImage];
    return view;
}

- (void)showInViewController:(UIViewController<MatchingFacetimeUserViewDelegate>*)superController 
                      inTime:(CFTimeInterval)timeInterval
{
    _runInAnimTime = timeInterval;
    _delegate = superController;
    self.hidden = NO;
    CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:_runInAnimTime delegate:self removeCompeleted:NO];
    [self.contentView.layer addAnimation:runIn forKey:@"runIn"];
}

- (IBAction)clickCancelButton:(id)sender
{
    [self startRunOutAnimation:_runInAnimTime];
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
    [cancelButton release];
    [matchingLabel release];
    [contentView release];
    [contentViewBackgroundImageView release];
    [super dealloc];
}
@end
