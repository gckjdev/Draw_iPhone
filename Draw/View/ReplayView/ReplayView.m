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
#import "ShareImageManager.h"

#define PLAYER_LOADER_MAX_X (ISIPAD ? 550 : 269)
#define PLAYER_LOADER_MIN_X CGRectGetMinX(self.playProgressLoader.frame)


@interface ReplayView()
{
    NSInteger curPlayIndex;
}
@property (retain, nonatomic) IBOutlet UIView *toolPanel;
@property (retain, nonatomic) IBOutlet UIImageView *playProgressLoader;
@property (retain, nonatomic) IBOutlet UIButton *playProgressPoint;
@property (retain, nonatomic) IBOutlet UIButton *playButton;

- (IBAction)clickRestart:(id)sender;
- (IBAction)clickPlay:(UIButton *)sender;
- (IBAction)clickEnd:(id)sender;

- (IBAction)startDragPlayer:(id)sender forEvent:(UIEvent *)event;

- (IBAction)dragPlayer:(id)sender forEvent:(UIEvent *)event;

- (IBAction)finishDragPlayer:(id)sender forEvent:(UIEvent *)event;

@end

@implementation ReplayView
@synthesize delegate = _delegate;
@synthesize holderView = _holderView;
@synthesize showView = _showView;
@synthesize feed = _feed;

- (void)updateView
{
    [self.playProgressLoader setImage:[[ShareImageManager defaultManager] playProgressLoader]];
}

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
    [view updateView];
    return view;
}
#define ANIMATION_KEY @"ANIMATION_KEY"
#define MISS_ANIMATION_VALUE @"VALUE_MISS"
#define SHOW_ANIMATION_VALUE @"VALUE_SHOW"

#define ANIMATION_DURATION 0.2f

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
            [self.feed parseDrawData];
            NSMutableArray *list =  [NSMutableArray
                                     arrayWithArray:
                                     self.feed.drawData.drawActionList];
            self.showView = [ShowDrawView showViewWithFrame:self.holderView.frame drawActionList:list delegate:self];
            self.showView.autoresizingMask = self.holderView.autoresizingMask;
            
            [self insertSubview:self.showView aboveSubview:self.holderView];
            [self clickPlay:self.playButton];
            [self.holderView removeFromSuperview];
            if ([self.delegate respondsToSelector:@selector(didStartToReplayWithFeed:)]) {
                [self.delegate performSelector:@selector(didStartToReplayWithFeed:) withObject:self.feed];
//                [self.delegate didStartToReplayWithFeed:self.feed];
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
//    self.center = view.center;
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
    [_toolPanel release];
    [_playProgressLoader release];
    [_playProgressPoint release];
    [_playButton release];
    [super dealloc];
}


#pragma mark - play action
- (IBAction)clickRestart:(UIButton *)sender {
    [self.showView resetView];
    [self.playButton setSelected:NO];
    [self updateProgressWithValue:0];
}

- (IBAction)clickPlay:(UIButton *)sender {
    if (![sender isSelected]) {
        //play
        if ([self.showView status] == Pause) {
            [self.showView resume];
        }else{
            [self.showView resetView];
            [self updateProgressWithPoint:CGPointMake(PLAYER_LOADER_MIN_X+1, 0)];
            [self.showView play];
        }
    }else{
        [self.showView pause];
    }
    [sender setSelected:![sender isSelected]];
}

- (IBAction)clickEnd:(UIButton *)sender {
    [self.showView show];
    [self.playButton setSelected:YES];
    [self updateProgressWithValue:1];
}


#pragma mark - play progress


- (void)updateView:(UIView *)view width:(CGFloat)width
{
    CGRect frame = view.frame;
    frame.size = CGSizeMake(width, CGRectGetHeight(frame));
    view.frame = frame;
}

- (void)showDrawViewWithProgressValue:(CGFloat)value
{
    NSInteger index = value *[[self.showView drawActionList] count];
    [self.showView showToIndex:index];
    if ([self.playButton isSelected]) {
        //is playing
        BOOL flag = [self.showView playFromDrawActionIndex:index];
        self.playButton.selected = flag;
    }else{
        
    }
}

- (CGFloat)playProgressValue:(CGPoint)point
{
    return (point.x - PLAYER_LOADER_MIN_X)/ (PLAYER_LOADER_MAX_X - PLAYER_LOADER_MIN_X);
}

- (CGPoint)fixPoint:(CGPoint)point
{
    point.x = MAX(PLAYER_LOADER_MIN_X, point.x);
    point.x = MIN(PLAYER_LOADER_MAX_X, point.x);
    return point;
}

- (void)updateProgressWithPoint:(CGPoint)point
{
    CGFloat minX = PLAYER_LOADER_MIN_X;
    point = [self fixPoint:point];
    CGFloat width = point.x - minX;
    [self updateView:self.playProgressLoader width:width];
    self.playProgressPoint.center = CGPointMake(point.x, CGRectGetMidY(self.playProgressPoint.frame));
}

- (void)updateProgressWithValue:(CGFloat)value
{
    CGFloat x = PLAYER_LOADER_MIN_X + (PLAYER_LOADER_MAX_X - PLAYER_LOADER_MIN_X)*value;
    [self updateProgressWithPoint:CGPointMake(x, 0)];
}

- (CGPoint)touchPointForEvent:(UIEvent *)event
{
     UITouch *touch = [[event allTouches] anyObject];
     return [touch locationInView:self.toolPanel];
}

- (IBAction)startDragPlayer:(id)sender forEvent:(UIEvent *)event {
    CGPoint point = [self touchPointForEvent:event];
    [self updateProgressWithPoint:point];
    [self.showView pause];
}

- (IBAction)dragPlayer:(id)sender forEvent:(UIEvent *)event {
    CGPoint point = [self touchPointForEvent:event];
    [self updateProgressWithPoint:point];
}

- (IBAction)finishDragPlayer:(id)sender forEvent:(UIEvent *)event {
    CGPoint point = [self touchPointForEvent:event];
    [self updateProgressWithPoint:point];
    CGFloat value = [self playProgressValue:[self fixPoint:point]];
    [self showDrawViewWithProgressValue:value];
}

#pragma mark - Show Draw View Delegate

- (void)didPlayDrawView:(ShowDrawView *)showDrawView
{
    [self.playButton setSelected:NO];
}
- (void)didPlayDrawView:(ShowDrawView *)showDrawView
          AtActionIndex:(NSInteger)actionIndex
             pointIndex:(NSInteger)pointIndex
{
    //move progress
    if (curPlayIndex != actionIndex) {
        curPlayIndex = actionIndex;
//        update the progress
        CGFloat value = (actionIndex+1) * 1.0 / [[showDrawView drawActionList] count];
        [self updateProgressWithValue:value];
    }
}


@end
