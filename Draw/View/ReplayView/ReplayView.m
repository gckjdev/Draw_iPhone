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
#import "ConfigManager.h"
#import "AccountService.h"
#import "ItemType.h"
#import "UserGameItemService.h"
#import "BuyItemView.h"
#import "UserGameItemManager.h"
#import "GameItemManager.h"
#import "DrawHolderView.h"
#import "CommonDialog.h"
#import "LearnDrawService.h"
#import "ShareAction.h"

#define PLAYER_LOADER_MAX_X (ISIPAD ? 638 : 266)
#define PLAYER_LOADER_MIN_X (ISIPAD ? 76 : 26)

#define SPEED_LOADER_MIN_Y (ISIPAD ? 30 : 14)
#define SPEED_LOADER_MAX_Y (ISIPAD ? 160 : 79)

#define PLAYER_PROGRESSBAR_FRAME (ISIPAD ? CGRectMake(76, 15, 638, 60) :CGRectMake(26, 5, 266, 25))


@interface ReplayView()
{
    NSInteger curPlayIndex;
    UIView *_maskView;
}

@property(nonatomic, retain) IBOutlet DrawHolderView *holderView;
@property(nonatomic, retain) ShowDrawView *showView;
@property(nonatomic, assign) PPViewController *superController;
@property (retain, nonatomic) IBOutlet UIControl *playerToolMask;


@property (retain, nonatomic) IBOutlet UIControl *toolPanel;
@property (retain, nonatomic) IBOutlet UIImageView *playProgressLoader;
@property (retain, nonatomic) IBOutlet UIButton *playProgressPoint;
@property (retain, nonatomic) IBOutlet UIButton *playButton;

@property (retain, nonatomic) IBOutlet UIView *speedPanel;

@property (retain, nonatomic) IBOutlet UIImageView *speedLoader;
@property (retain, nonatomic) IBOutlet UIButton *speedPoint;

- (IBAction)clickRestart:(id)sender;
- (IBAction)clickPlay:(UIButton *)sender;
- (IBAction)clickEnd:(id)sender;
- (IBAction)clickSpeed:(id)sender;
- (IBAction)clickCloseButton:(id)sender;

- (IBAction)startDragPlayer:(id)sender forEvent:(UIEvent *)event;

- (IBAction)dragPlayer:(id)sender forEvent:(UIEvent *)event;

- (IBAction)finishDragPlayer:(id)sender forEvent:(UIEvent *)event;

- (IBAction)dragSpeed:(UIButton *)sender forEvent:(UIEvent *)event;
- (IBAction)finishDragSpeed:(id)sender forEvent:(UIEvent *)event;

- (IBAction)clickPlayerPanel:(id)sender forEvent:(UIEvent *)event;
- (IBAction)clickSpeedPanel:(id)sender forEvent:(UIEvent *)event;
- (IBAction)clickPlayerToolMask:(id)sender;

@end

@implementation ReplayView

@synthesize holderView = _holderView;
@synthesize showView = _showView;

- (BOOL)hasBounghtPlayer
{
    return [[UserGameItemManager defaultManager] hasItem:PaintPlayerItem];
}

- (void)updateView
{
    [self.playProgressLoader setImage:[[ShareImageManager defaultManager] playProgressLoader]];
    [self.speedLoader setImage:[[ShareImageManager defaultManager] speedProgressLoader]];
    [self.speedPanel setHidden:YES];
    if ([self hasBounghtPlayer]) {
        [self.playerToolMask removeFromSuperview];
        self.playerToolMask = nil;
    }
}

+ (id)createReplayView
{
    NSString* identifier = @"ReplayView";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find view object from Nib", identifier);
        return nil;
    }
    ReplayView *view = [topLevelObjects objectAtIndex:0];
    [view updateView];
    return view;
}

- (IBAction)clickCloseButton:(id)sender {
    [self.showView stop];
    [_maskView removeFromSuperview];
    self.showView.delegate = nil;
    [self.showView removeFromSuperview];
    self.showView = nil;
    self.superController = nil;
    [self.holderView setContentView:nil];
    [self.holderView removeFromSuperview];
    self.holderView = nil;
    UIViewController *controller = [self theViewController];
    [self removeFromSuperview];
    
    if (self.popControllerWhenClose) {
        [controller.navigationController popToRootViewControllerAnimated:NO];
    }

}

- (void)updateMaskViewWithFrame:(CGRect)frame
{
    if (_maskView == nil) {
        _maskView = [[UIView alloc] initWithFrame:frame];
        [_maskView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    }
}

- (void)showInController:(PPViewController *)controller
          withActionList:(NSMutableArray *)actionList
            isNewVersion:(BOOL)isNewVersion
                    size:(CGSize)size
{    
    self.superController = controller;
    UIView *view = controller.view;
    [self updateMaskViewWithFrame:view.bounds];
    [view addSubview:_maskView];
    [view addSubview:self];
    self.center = view.center;
    
    self.showView = [ShowDrawView showViewWithFrame:CGRectFromCGSize(size) drawActionList:actionList delegate:self];
    
    [self.showView setPressEnable:YES];

    [self.holderView setContentView:self.showView];
    
    if (isNewVersion) {
        [controller popupMessage:NSLS(@"kNewDrawVersionTip") title:nil];
    }
    
    [self performSelector:@selector(clickPlay:) withObject:self.playButton afterDelay:0.2];
}


- (void)showInController:(PPViewController *)controller
          withActionList:(NSMutableArray *)actionList
            isNewVersion:(BOOL)isNewVersion
{
    [self showInController:controller
            withActionList:actionList
              isNewVersion:isNewVersion
                      size:self.holderView.frame.size];
}

- (void)dealloc {

    
    PPDebug(@"dealloc %@", [self description]);
    _drawFeed.drawImage = nil;
    PPRelease(_drawFeed);
    PPRelease(_holderView);
    PPRelease(_showView);
    PPRelease(_toolPanel);
    PPRelease(_playProgressLoader);
    PPRelease(_playProgressPoint);
    PPRelease(_playButton);
    PPRelease(_speedPanel);
    PPRelease(_speedLoader);
    PPRelease(_speedPoint);
    PPRelease(_maskView);
    PPRelease(_playerToolMask);
    
    [super dealloc];
}


#pragma mark - play action

- (BOOL)isPlaying
{
    return [self.playButton isSelected];
}
- (void)setPlaying
{
    [self.playButton setSelected:YES];
}

- (void)readyToPlay
{
    [self.showView resetView];
    [self.playButton setSelected:NO];
    [self updateProgressWithValue:0];    
}

- (void)endToPlay
{
    [self.playButton setSelected:NO];
    [self updateProgressWithValue:1];
}
- (IBAction)clickRestart:(UIButton *)sender {
    [self readyToPlay];
}

- (IBAction)clickPlay:(UIButton *)sender {
    if (![sender isSelected]) {
        //play
        if ([self.showView status] == Pause) {
            [self.showView resume];
        }else{
            [self readyToPlay];
            [self.showView play];
        }
    }else{
        [self.showView pause];
    }
    [sender setSelected:![sender isSelected]];
}

- (void)playEnd
{
    [self.superController hideActivity];
//    [self.showView show];
    [self.showView showToIndex:[self.showView.drawActionList count]];
    [self endToPlay];
}

- (IBAction)clickEnd:(UIButton *)sender {
    [self.superController showActivityWithText:NSLS(@"kBuffering")];
    [self performSelector:@selector(playEnd) withObject:nil afterDelay:0.001];
}

- (IBAction)clickSpeed:(id)sender {
    self.speedPanel.hidden = !self.speedPanel.hidden;
}


#pragma mark - play progress


- (void)updateView:(UIView *)view width:(CGFloat)width
{
    CGRect frame = view.frame;
    frame.size = CGSizeMake(width, CGRectGetHeight(frame));
    view.frame = frame;
}


- (void)laterShowDrawViewWithProgressValue:(NSNumber *)nValue
{
    CGFloat value = [nValue floatValue];
    NSInteger index = value *[[self.showView drawActionList] count];
    [self.showView showToIndex:index];
    if ([self isPlaying]) {
        //is playing
        BOOL flag = [self.showView playFromDrawActionIndex:index];
        self.playButton.selected = flag;
    }else{
        if (value >= 1) {
            [self.showView setStatus:Stop];
        }else{
            [self.showView setStatus:Pause];
        }
    }
    [self.superController hideActivity];
}
- (void)showDrawViewWithProgressValue:(CGFloat)value
{
    [self.superController showActivityWithText:NSLS(@"kBuffering")];
    [self performSelector:@selector(laterShowDrawViewWithProgressValue:) withObject:@(value) afterDelay:0.001];
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

- (void)setSpeedProgressWithPoint:(CGPoint)point
{
    point.y = MIN(SPEED_LOADER_MAX_Y, point.y);
    point.y = MAX(SPEED_LOADER_MIN_Y, point.y);
    point.x = self.speedPoint.center.x;
    self.speedPoint.center = point;

    CGRect frame = self.speedLoader.frame;
    
    frame.origin.y = point.y;
    frame.size.height = SPEED_LOADER_MAX_Y - point.y;
    [self.speedLoader setFrame:frame];
    
    double value = (point.y - SPEED_LOADER_MIN_Y) / (SPEED_LOADER_MAX_Y - SPEED_LOADER_MIN_Y);

    
    double maxSpeed = [ConfigManager getMaxPlayDrawSpeed];
    double minSpeed = [ConfigManager getMinPlayDrawSpeed];
    double speed = minSpeed + value *(maxSpeed - minSpeed);
    [self.showView setPlaySpeed:speed];
}

- (IBAction)dragSpeed:(UIButton *)sender forEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self.speedPanel];
    [self setSpeedProgressWithPoint:point];
}



- (IBAction)finishDragSpeed:(id)sender forEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self.speedPanel];
    [self setSpeedProgressWithPoint:point];
}


- (BOOL)touchInPlayProgressBar:(CGPoint)point
{
    return CGRectContainsPoint(PLAYER_PROGRESSBAR_FRAME, point);
}

- (IBAction)clickPlayerPanel:(id)sender forEvent:(UIEvent *)event {
    CGPoint point = [self touchPointForEvent:event];
    if ([self touchInPlayProgressBar:point]) {
        [self updateProgressWithPoint:point];
        CGFloat value = [self playProgressValue:[self fixPoint:point]];
        [self showDrawViewWithProgressValue:value];
    }
}

- (IBAction)clickSpeedPanel:(id)sender forEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self.speedPanel];
    [self setSpeedProgressWithPoint:point];
}

- (IBAction)clickPlayerToolMask:(id)sender {
    PPDebug(@"%d", [self hasBounghtPlayer]);
    if (![self hasBounghtPlayer] && !isLearnDrawApp()) {
            [BuyItemView showOnlyBuyItemView:PaintPlayerItem inView:self resultHandler:^(int resultCode, int itemId, int count, NSString *toUserId) {
            if (resultCode == ERROR_SUCCESS) {
                [self.playerToolMask removeFromSuperview];
                self.playerToolMask = nil;
            }
        }];
    }else{
        [self.playerToolMask removeFromSuperview];
        self.playerToolMask = nil;        
    }
}

- (void)didBuyItem:(int)itemId
            result:(int)result
{
    if (result == 0) {
        [self.playerToolMask removeFromSuperview];
        self.playerToolMask = nil;
    }else{
        PPDebug(@"<didBuyItem> item type = %d, failed",itemId);
    }
}

#pragma mark - Show Draw View Delegate

- (void)didPlayDrawView:(ShowDrawView *)showDrawView
{
    [self endToPlay];
}


- (void)buyAndPlayDraw:(DrawFeed *)feed
{
    __block ReplayView *cp = self;
    [[LearnDrawService defaultService] buyLearnDraw:self.drawFeed.feedId
                                              price:self.drawFeed.learnDraw.price
                                           fromView:self
                                      resultHandler:^(NSDictionary *dict, NSInteger resultCode) {
        if (resultCode == 0) {
            [cp setEndIndex:0];
            [cp setPlayControlsDisable:NO];
            [cp clickPlay:cp.playButton];
            cp.popControllerWhenClose = YES;
            ShareAction *share = [[ShareAction alloc]
                                  initWithFeed:cp.drawFeed
                                        image:cp.drawFeed.drawImage];
            [share saveToLocal];
            [share release];

            
        }else{
            //TODO show error message
        }
    }];
}

- (void)didPlayDrawView:(ShowDrawView *)showDrawView
          AtActionIndex:(NSInteger)actionIndex
             pointIndex:(NSInteger)pointIndex
{
    if (isLearnDrawApp() && actionIndex > self.endIndex && self.endIndex != 0) {
//        [showDrawView stop];
        [self.playButton setEnabled:YES];
        [self clickPlay:self.playButton];
        [self.playButton setEnabled:NO];
        __block ReplayView *cp = self;
        
        [[CommonDialog createDialogWithTitle:NSLS(@"kBuyToPlayTitle") message:NSLS(@"kBuyToPlayMesaage")
                                       style:CommonDialogStyleDoubleButton
                                    delegate:nil
                                clickOkBlock:^{
                                    [cp buyAndPlayDraw:cp.drawFeed];
            
        } clickCancelBlock:^{
            
        }] showInView:[self theTopView]];
         
    }
    //move progress
    if (curPlayIndex != actionIndex) {
        curPlayIndex = actionIndex;
        CGFloat value = (actionIndex+1) * 1.0 / [[showDrawView drawActionList] count];
        [self updateProgressWithValue:value];
    }
}

- (void)didClickShowDrawView:(ShowDrawView *)showDrawView
{
    [self.speedPanel setHidden:YES];
}

- (void)setPlayControlsDisable:(BOOL)disable
{
    for (UIControl *control in self.subviews) {
        if ([control isKindOfClass:[UIControl class]] && control.tag != 123) {
            [control setEnabled:!disable];
            for (UIControl *control2 in control.subviews) {
                [control2 setEnabled:!disable];
            }
        }
    }

}
@end
