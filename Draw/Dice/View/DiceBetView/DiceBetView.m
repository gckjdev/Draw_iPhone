//
//  DiceBetView.m
//  Draw
//
//  Created by 小涛 王 on 12-9-18.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceBetView.h"
#import "DiceImageManager.h"
#import "LocaleUtils.h"

@interface DiceBetView()
{
    int _second;
    id<DiceBetViewDelegate> _delegate;
    int _ante;
    CGFloat _winOdds;
    CGFloat _loseOdds;
}

@property (retain, nonatomic) NSTimer *timer;
@property (assign, nonatomic) id<DiceBetViewDelegate> delegate;

@end


@implementation DiceBetView
@synthesize timer = _timer;
@synthesize delegate = _delegate;
@synthesize bgImageView;
@synthesize titleLabel;
@synthesize noteLabel;
@synthesize anteLabel;
@synthesize anteCoinsLabel;
@synthesize winLabel;
@synthesize winOddsLabel;
@synthesize loseLabel;
@synthesize loseOddsLabel;
@synthesize betWinButton;
@synthesize betLoseButton;

- (void)dealloc {
    [_timer release];
    [titleLabel release];
    [noteLabel release];
    [anteLabel release];
    [anteCoinsLabel release];
    [winLabel release];
    [winOddsLabel release];
    [loseLabel release];
    [loseOddsLabel release];
    [bgImageView release];
    [betWinButton release];
    [betLoseButton release];
    [super dealloc];
}

+ (id)createDiceBetView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DiceBetView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:0];
}

+ (void)showInView:(UIView *)view
          duration:(int)duration
          openUser:(NSString *)nickName
              ante:(int)ante
           winOdds:(float)winOdds
          loseOdds:(float)loseOdds
          delegate:(id<DiceBetViewDelegate>)delegate
{
    DiceBetView *betView = [DiceBetView createDiceBetView];
    [betView initWithDuration:duration 
                     openUser:nickName 
                         ante:ante
                      winOdds:winOdds 
                     loseOdds:loseOdds];
    betView.center = CGPointMake(view.center.x, view.center.y + view.frame.size.height/4);
    betView.delegate = delegate;
    betView.alpha = 0;
    [view addSubview:betView];
    
    betView.userInteractionEnabled = YES;
    [UIView animateWithDuration:1 animations:^{
        betView.alpha = 1;
    }];
}


- (void)initWithDuration:(int)duration
                openUser:(NSString *)nickName
                    ante:(int)ante
                 winOdds:(CGFloat)winOdds
                loseOdds:(CGFloat)loseOdds
{
    [self createTimer];
    _second = duration;
    bgImageView.image = [[DiceImageManager defaultManager] popupBackgroundImage];
    
    titleLabel.text = [NSString stringWithFormat:NSLS(@"kBetViewTitle"), _second];
    noteLabel.text = [NSString stringWithFormat:NSLS(@"kBetNote"), nickName];
    noteLabel.numberOfLines = 0;
    if ([LocaleUtils isChina]) {
        noteLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    }else {
        noteLabel.lineBreakMode = UILineBreakModeWordWrap;
    }
    anteLabel.text = NSLS(@"kAnte");
    anteCoinsLabel.text = [NSString stringWithFormat:@"%d", ante];
    winLabel.text = NSLS(@"kWin");
    loseLabel.text = NSLS(@"kLose");
    
    winOddsLabel.text = [NSString stringWithFormat:NSLS(@"kOdds"), winOdds];
    winOddsLabel.textColor = [UIColor redColor];
    loseOddsLabel.text = [NSString stringWithFormat:NSLS(@"kOdds"), loseOdds];
    loseOddsLabel.textColor = [UIColor redColor];
    _ante = ante;
    _winOdds = winOdds;
    _loseOdds = loseOdds;
    
    [betWinButton setBackgroundImage:[[DiceImageManager defaultManager] commonDialogLeftBtnImage] forState:UIControlStateNormal];
    [betLoseButton setBackgroundImage:[[DiceImageManager defaultManager] commonDialogLeftBtnImage] forState:UIControlStateNormal];
    
//    [betWinButton setRoyButtonWithColor:[UIColor yellowColor]];
//    [betLoseButton setRoyButtonWithColor:[UIColor yellowColor]];
}

- (void)dismiss
{
    self.userInteractionEnabled= NO;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)clickCloseButton:(id)sender {
    [self killTimer];
    [self dismiss];
}

- (IBAction)clickBetWinButton:(id)sender {
    [self killTimer];

    if ([_delegate respondsToSelector:@selector(didBetOpenUserWin:ante:odds:)]) {
        [_delegate didBetOpenUserWin:YES
                                ante:_ante 
                                odds:_winOdds];
    }
    
    [self dismiss];
}

- (IBAction)clickBetLoseButton:(id)sender {
    [self killTimer];
    
    if ([_delegate respondsToSelector:@selector(didBetOpenUserWin:ante:odds:)]) {
        [_delegate didBetOpenUserWin:NO 
                                ante:_ante
                                odds:_loseOdds];
    }
    
    [self dismiss];
    
}
#pragma mark - Timer manage

- (void)createTimer
{
    [self killTimer];
    
    PPDebug(@"self count: %d", self.retainCount);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self 
                                                selector:@selector(handleTimer:)
                                                userInfo:nil 
                                                 repeats:YES];
    
    PPDebug(@"self count: %d", self.retainCount);
}

- (void)killTimer
{
    if ([_timer isValid]) {
        [_timer invalidate];        
    }
    self.timer = nil;
}

- (void)handleTimer:(NSTimer *)timer
{
    _second--;
    
    titleLabel.text = [NSString stringWithFormat:NSLS(@"kBetViewTitle"), _second];

    if (_second <= 0) {
        [self killTimer];
        [self dismiss];
    }
}



@end
