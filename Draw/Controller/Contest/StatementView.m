//
//  StatementView.m
//  Draw
//
//  Created by  on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StatementView.h"
#import "Contest.h"
#import "AnimationManager.h"

@implementation StatementView
@synthesize webView = _webView;
@synthesize delegate = _delegate;

+ (id)createStatementView:(id)delegate
{
    NSString* identifier = @"StatementView";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find view object from Nib", identifier);
        return nil;
    }
    StatementView *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;    
    return view;
}

- (void)dealloc {
    PPRelease(_webView);
    [_playProgressLoad release];
    [super dealloc];
}


#define MISS_ANIMATION_KEY @"KEY_MISS"
#define MISS_ANIMATION_VALUE @"VALUE_MISS"
#define ANIMATION_DURATION 0.8f

- (IBAction)clickCloseButton:(id)sender {
    CAAnimation *animation = [AnimationManager disappearAnimationWithDuration:ANIMATION_DURATION];
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [animation setValue:MISS_ANIMATION_VALUE forKey:MISS_ANIMATION_KEY];
    [animation setRemovedOnCompletion:YES];
    self.layer.opacity = 0;
    [self.layer addAnimation:animation forKey:nil];
 
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{

    NSString *value = [anim valueForKey:MISS_ANIMATION_KEY];
    if ([value isEqualToString:MISS_ANIMATION_VALUE]) 
    {
        PPDebug(@"<animationDidStop>: remove from view");
        [self removeFromSuperview];
    }

}

- (void)setViewInfo:(Contest *)contest
{
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:contest.statementUrl]];    
    [self.webView loadRequest:request];
}

- (void)showInView:(UIView *)view
{
    self.frame = view.frame;
    //    self.center = view.center;
    [view addSubview:self];
    CAAnimation *showAnimation = [AnimationManager scaleAnimationWithFromScale:0.01 
                                                                       toScale:1 
                                                                      duration:ANIMATION_DURATION 
                                                                      delegate:nil 
                                                              removeCompeleted:YES];
    showAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:showAnimation forKey:nil];
    
}
@end
