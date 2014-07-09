//
//  DrawPlayer.m
//  Draw
//
//  Created by Gamy on 13-8-30.
//
//

#import "DrawPlayer.h"
#import "DrawHolderView.h"
#import "ShowDrawView.h"
#import "PPConfigManager.h"


@implementation ReplayObject

+ (id)obj
{
    return [[[ReplayObject alloc] init] autorelease];
}

- (void)dealloc
{
    PPRelease(_actionList);
    PPRelease(_bgImage);
    PPRelease(_layers);
    [super dealloc];
}

@end

@interface DrawPlayer ()
{
    BOOL superControllerCanDragBack;
}

@end

@implementation DrawPlayer


- (CGFloat)speedWithRate:(CGFloat)rate
{
    CGFloat maxSpeed = [PPConfigManager getMaxPlayDrawSpeed];
    CGFloat minSpeed = 0;//[PPConfigManager getMinPlayDrawSpeed];
    CGFloat speed = maxSpeed -  rate *(maxSpeed - minSpeed);
    PPDebug(@"speed with rate, rate = %f, speed = %f", rate, speed);
    return speed;
    
}


- (void)updateView
{
    self.showView = [ShowDrawView showViewWithFrame:CGRectFromCGSize(_replayObj.canvasSize)
                                     drawActionList:nil
                                           delegate:self];
    
    [self.showView updateLayers:_replayObj.layers];
    [self.showView setDrawActionList:_replayObj.actionList];
    
    if (_replayObj.bgImage) {
        [self.showView setBGImage:_replayObj.bgImage];
    }
    
    
    [self.showView setPressEnable:YES];
    
    self.playSlider.minValue = 0;
    self.playSlider.maxValue = [[_replayObj actionList] count];
    self.playSlider.value = 0;
    self.playPanel.backgroundColor = COLOR255(0, 0, 0, 0.6*255);
    self.playSlider.bgColor = self.speedSlider.bgColor = COLOR255(0, 0, 0, 0.45*255);
    self.playSlider.loaderColor = self.speedSlider.loaderColor = COLOR255(28, 243, 230, 0.8*255);
    self.playSlider.pointColor = self.speedSlider.pointColor = COLOR_YELLOW;
    
    self.playSlider.pointImage = [[ShareImageManager defaultManager] playProgressPoint];

    self.speedSlider.pointImage = [[ShareImageManager defaultManager] speedProgressPoint];

    self.showView.playSpeed = [self speedWithRate:self.speedSlider.value];
    
    self.showView.maxPlaySpeed = [PPConfigManager getMaxPlayDrawSpeed];
    
 

}

+ (DrawPlayer *)playerWithReplayObj:(ReplayObject *)obj
{
    DrawPlayer *player = [DrawPlayer createViewWithXibIdentifier:@"DrawPlayer" ofViewIndex:ISIPAD];
    player.replayObj = obj;
    [player updateView];
    return player;
}



- (void)showInController:(PPViewController *)controller
{
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    self.frame = CGRectOffset([[UIScreen mainScreen] bounds], 0, -20);
    DrawHolderView *holderView = (id)self.showView.superview;
    holderView.autoresizingMask = (1<<6)-1;
    if (holderView == nil) {
        holderView = [DrawHolderView drawHolderViewWithFrame:self.bounds contentView:self.showView];
        [holderView addTarget:self action:@selector(clickHolderView:) forControlEvents:UIControlEventTouchUpInside];
        [holderView updateOriginY:STATUSBAR_DELTA];
    }
    [self insertSubview:holderView atIndex:0];
    [controller.view addSubview:self];
    self.frame = controller.view.bounds;

    if (_replayObj.isNewVersion) {
        POSTMSG(NSLS(@"kNewDrawVersionTip"));
    }
    [self start];
    [self performSelector:@selector(autoHidePanel) withObject:nil afterDelay:4];
    superControllerCanDragBack = controller.canDragBack;
    [controller setCanDragBack:NO];
}


- (void)dealloc {
    [_playPanel release];
    [_playSlider release];
    [_speedSlider release];
    [_playButton release];
    [_closeButton release];
    PPRelease(_replayObj);
    PPRelease(_showView);    
    [super dealloc];
}

- (IBAction)close:(id)sender {
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [(PPViewController *)[self theViewController] setCanDragBack:superControllerCanDragBack];
    self.showView.delegate = nil;
    [self.showView stop];
    [self.showView removeFromSuperview];
    self.showView = nil;
    [self removeAllSubviews];
    [self removeFromSuperview];
}

- (void)playToIndex:(NSNumber *)index
{
    [(PPViewController *)[self theViewController] hideActivity];
    NSInteger status = self.showView.status;
    [self.showView setStatus:Pause];
    [self.showView showToIndex:[index integerValue]];
    if (status == Playing) {
        [self play];
    }else{
        [self pause];
    }
    [self.playButton setSelected:(status == Playing)];
//    [self.showView performSelector:@selector(setDelegate:) withObject:self afterDelay:0.2];
}

- (IBAction)changeProcess:(CustomSlider *)sender {
    [(PPViewController *)[self theViewController] showActivityWithText:NSLS(@"kBuffering")];
    NSInteger index = sender.value;
    [self performSelector:@selector(playToIndex:) withObject:@(index) afterDelay:0.01];

//    [self playToIndex:index];
}

- (IBAction)changeSpeed:(CustomSlider *)sender {
    PPDebug(@"<changeSpeed> = %f", sender.value);
    self.showView.playSpeed = [self speedWithRate:self.speedSlider.value];
}

- (IBAction)clickPlayButton:(id)sender {
    if (![sender isSelected]) {
        if (self.playSlider.value <= self.playSlider.minValue || self.playSlider.value >= self.playSlider.maxValue) {
            [self start];
        }else{
            [self play];
        }
    }else{
        [self pause];
    }
}

- (void)play
{
    [self.showView resume];
    [self.playButton setSelected:YES];
}
- (void)pause
{
    [self.showView pause];
    [self.playButton setSelected:NO];
    
//    [self stopRecording];
    
}
- (void)stop
{
    [self.showView stop];
    [self.playButton setSelected:NO];
    
}
- (void)start
{    
//    [self startRecording];
    
    [self.showView play];
    [self.playButton setSelected:YES];    
}


- (void)hidePanel:(BOOL)hidden animated:(BOOL)animated
{
    CGFloat alpha = (hidden ? 0 : 1);
    if (animated) {
        [UIView animateWithDuration:0.8 animations:^{
            self.playPanel.alpha = alpha;
            self.closeButton.hidden = hidden;
        } completion:^(BOOL finished) {
            self.playPanel.alpha = alpha;
            self.playPanel.hidden = hidden;
            self.closeButton.hidden = hidden;
            self.closeButton.alpha = alpha;
        }];
        
    }else{
        self.playPanel.alpha = alpha;
        self.playPanel.hidden = hidden;
        
        self.closeButton.hidden = hidden;
        self.closeButton.alpha = alpha;
    }
}

- (void)didPlayDrawView:(ShowDrawView *)showDrawView
          AtActionIndex:(NSInteger)actionIndex
             pointIndex:(NSInteger)pointIndex
{
    if (![self.playSlider isOnTouch]) {
        [self.playSlider setValue:actionIndex];
    }else{
//        showDrawView.delegate = nil;
    }
    
}

- (void)didPlayDrawView:(ShowDrawView *)showDrawView
{
    if (![self.playSlider isOnTouch]) {
        [self.playSlider setValue:self.playSlider.maxValue];
    }
    [self hidePanel:NO animated:NO];
    [self.playButton setSelected:NO];
}

- (void)didClickShowDrawView:(ShowDrawView *)showDrawView
{
    [self clickHolderView:nil];
}

- (void)clickHolderView:(id)sender
{
    if (self.playPanel.alpha < 1) {
        [self hidePanel:NO animated:NO];
    }else{
        [self hidePanel:YES animated:YES];
    }
}


- (void)autoHidePanel
{
    [self hidePanel:YES animated:YES];    
}

@end
