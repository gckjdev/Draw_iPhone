//
//  ReplayView.m
//  Draw
//
//  Created by  on 12-9-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ReplayView.h"
#import "AnimationManager.h"
#import "DrawFeed.h"
#import "ShowDrawView.h"
#import "Draw.h"
#import "DrawAction.h"

@implementation ReplayView
@synthesize delegate = _delegate;
@synthesize holderView = _holderView;
@synthesize showView = _showView;
@synthesize feed = _feed;
+ (id)createReplayView:(id)delegate
{
    NSString* identifier = @"ReplayView";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find view object from Nib", identifier);
        return nil;
    }
    ReplayView *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;    
    return view;

}
#define ANIMATION_KEY @"ANIMATION_KEY"
#define MISS_ANIMATION_VALUE @"VALUE_MISS"
#define SHOW_ANIMATION_VALUE @"VALUE_SHOW"

#define ANIMATION_DURATION 0.8f

- (IBAction)clickCloseButton:(id)sender {
    CAAnimation *animation = [AnimationManager disappearAnimationWithDuration:ANIMATION_DURATION];
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [animation setValue:MISS_ANIMATION_VALUE forKey:ANIMATION_KEY];
    [animation setRemovedOnCompletion:YES];
    self.layer.opacity = 0;
    [self.layer addAnimation:animation forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        NSString *animationValue = [anim valueForKey:ANIMATION_KEY];
        PPDebug(@"animation value =%@", animationValue);
        if ([animationValue isEqualToString:MISS_ANIMATION_VALUE]) {
            PPDebug(@"<animationDidStop>: remove from view");
            [self.showView stop];
            self.showView.hidden = YES;
            [self.showView removeFromSuperview];
            self.showView = nil;
            self.feed.drawData = nil;
            self.feed = nil;
            [self removeFromSuperview];
        }else if ([animationValue isEqualToString:SHOW_ANIMATION_VALUE]) {
            PPDebug(@"<animationDidStop>: start to show draw view.");
            [self.holderView removeFromSuperview];
            [self.feed parseDrawData];
            self.showView = [[[ShowDrawView alloc]
                              initWithFrame:self.holderView.frame] 
                             autorelease];
            
            NSMutableArray *list =  [NSMutableArray
                                     arrayWithArray:
                                     self.feed.drawData.drawActionList];            
            [self.showView setDrawActionList:list];
//            self.showView.speed = PlaySpeedTypeNormal;
            [self addSubview:self.showView];
            [self.showView play];
            if ([self.delegate respondsToSelector:@selector(didStartToReplayWithFeed:)]) {
                [self.delegate didStartToReplayWithFeed:self.feed];
            }
        }
    }
//    anim.delegate = nil;
}

- (void)setViewInfo:(DrawFeed *)feed
{
    self.feed = feed;
}

- (void)showInView:(UIView *)view
{
//    self.center = view.center;
    self.frame = view.frame;
    [view addSubview:self];
    CAAnimation *showAnimation = [AnimationManager scaleAnimationWithFromScale:0.01 
                                                                       toScale:1 
                                                                      duration:ANIMATION_DURATION 
                                                                      delegate:self 
                                                              removeCompeleted:YES];
    showAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [showAnimation setValue:SHOW_ANIMATION_VALUE forKey:ANIMATION_KEY];
    [self.layer addAnimation:showAnimation forKey:nil];
}
- (void)dealloc {
    PPDebug(@"dealloc %@", [self description]);
    PPRelease(_holderView);
    PPRelease(_showView);
    PPRelease(_feed);
    [super dealloc];
}
@end
