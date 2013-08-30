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
#import "ConfigManager.h"

@implementation ReplayObject

+ (id)obj
{
    return [[ReplayObject alloc] autorelease];
}

- (void)dealloc
{
    PPRelease(_actionList);
    PPRelease(_bgImage);
    PPRelease(_layers);
    [super dealloc];
}

@end


@implementation DrawPlayer


- (CGFloat)speedWithRate:(CGFloat)rate
{
    CGFloat maxSpeed = 0.1;//[ConfigManager getMaxPlayDrawSpeed];
    CGFloat minSpeed = 0;//[ConfigManager getMinPlayDrawSpeed];
    CGFloat speed = maxSpeed -  rate *(maxSpeed - minSpeed);
    PPDebug(@"speed with rate, rate = %f, speed = %f", rate, speed);
    return speed;
    
}


- (void)updateView
{
    self.showView = [ShowDrawView showViewWithFrame:CGRectFromCGSize(_replayObj.canvasSize)
                                     drawActionList:_replayObj.actionList
                                           delegate:self];
    
    [self.showView updateLayers:_replayObj.layers];
    
    if (_replayObj.bgImage) {
        [self.showView setBGImage:_replayObj.bgImage];
    }
    
    
    [self.showView setPressEnable:YES];
    
    self.playSlider.minValue = 0;
    self.playSlider.maxValue = [[_replayObj actionList] count];
    self.playSlider.value = 0;
    self.playPanel.backgroundColor = COLOR255(0, 0, 0, 60);
    self.playSlider.bgColor = self.speedSlider.bgColor = COLOR255(0, 0, 0, 45);
    self.playSlider.loaderColor = self.speedSlider.loaderColor = COLOR255(28, 243, 230, 80);
    self.playSlider.pointColor = self.speedSlider.pointColor = COLOR_YELLOW;
    
    self.playSlider.pointImage = [[ShareImageManager defaultManager] playProgressPoint];

    self.speedSlider.pointImage = [[ShareImageManager defaultManager] speedProgressPoint];

    self.showView.playSpeed = [self speedWithRate:self.speedSlider.value];
 
    //update close button
//    [self updateCloseButton];
//    [self updatePlayButton];
}

- (void)drawRoundAtContext:(CGContextRef)context inRect:(CGRect)rect
{
    [COLOR_YELLOW setFill];
    [[UIBezierPath bezierPathWithOvalInRect:rect] fill];    
    rect = CGRectInset(rect, CGRectGetWidth(rect)/8, CGRectGetHeight(rect)/8);
    [COLOR_ORANGE setFill];
    [[UIBezierPath bezierPathWithOvalInRect:rect] fill];
    CGContextSetLineWidth(context, CGRectGetWidth(rect)/8);
    [COLOR_WHITE setStroke];
    [COLOR_WHITE setFill];
}


- (void)updatePlayButton
{
    UIImage *image = nil;
    UIImage *image1 = nil;
    [self.playButton setImage:nil forState:UIControlStateNormal];
    UIGraphicsBeginImageContext(self.playButton.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = self.playButton.bounds;
    [self drawRoundAtContext:context inRect:rect];
    rect = CGRectInset(rect, CGRectGetWidth(rect)/3.3, CGRectGetHeight(rect)/3.3);
    rect = CGRectOffset(rect, CGRectGetWidth(rect)/7, 0);
    
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMidY(rect));
    CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextClosePath(context);
    CGContextFillPath(context);
    image = UIGraphicsGetImageFromCurrentImageContext();

    rect = self.playButton.bounds;
    [self drawRoundAtContext:context inRect:rect];
    rect = CGRectInset(rect, CGRectGetWidth(rect)/2.8, CGRectGetWidth(rect)/2.8);
    CGPoint points[] = {
        CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect)),
        CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect)),
        
        CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect)),
        CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect)),
        
    };
    CGContextStrokeLineSegments(context, points, 4);

    image1 = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self.playButton setImage:image forState:UIControlStateNormal];
    [self.playButton setImage:image1 forState:UIControlStateSelected];
}

- (void)updateCloseButton
{
    UIImage *image = nil;
    [self.closeButton setImage:nil forState:UIControlStateNormal];
    UIGraphicsBeginImageContext(self.closeButton.bounds.size);
    CGRect rect = self.closeButton.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawRoundAtContext:context inRect:rect];
    rect = CGRectInset(rect, CGRectGetWidth(rect)/3, CGRectGetHeight(rect)/3);
    CGPoint points[] = {CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect)),
                        CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect)),
                        CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect)),
                        CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect)),
    };
    CGContextStrokeLineSegments(context, points, 4);
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.closeButton setImage:image forState:UIControlStateNormal];
    
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
    DrawHolderView *holderView = (id)self.showView.superview;
    if (holderView == nil) {
        holderView = [DrawHolderView drawHolderViewWithFrame:self.bounds contentView:self.showView];
    }
    [self insertSubview:holderView atIndex:0];
    [controller.view addSubview:self];

    if (_replayObj.isNewVersion) {
        [controller popupMessage:NSLS(@"kNewDrawVersionTip") title:nil];
    }
    [self start];
    [self performSelector:@selector(autoHidePanel) withObject:nil afterDelay:2];
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
//    [self.showView setStatus:Pause];
    [self.showView showToIndex:[index integerValue]];
    if (status == Playing) {
        [self play];
    }else{
        [self pause];
    }
    [self.playButton setSelected:(status == Playing)];

}

- (IBAction)changeProcess:(CustomSlider *)sender {
    [(PPViewController *)[self theViewController] showActivityWithText:NSLS(@"kBuffering")];
    NSInteger index = sender.value;
    [self performSelector:@selector(playToIndex:) withObject:@(index) afterDelay:0.1];
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
}
- (void)stop
{
    [self.showView stop];
    [self.playButton setSelected:NO];    
}
- (void)start
{
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
