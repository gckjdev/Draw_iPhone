//
//  DiceBetView.m
//  Draw
//
//  Created by 小涛 王 on 12-9-18.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceBetView.h"
#import "DiceImageManager.h"

@interface DiceBetView()
{
    int _second;
}

@property (retain, nonatomic) NSTimer *timer;

@end


@implementation DiceBetView
@synthesize timer = _timer;
@synthesize bgImageView;
@synthesize titleLabel;
@synthesize noteLabel;
@synthesize anteLabel;
@synthesize anteCoinsLabel;
@synthesize winLabel;
@synthesize winOddsLabel;
@synthesize loseLabel;
@synthesize loseOddsLabel;

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
           winOdds:(CGFloat)windOdds
          loseOdds:(CGFloat)loseOdds
{
    DiceBetView *betView = [DiceBetView createDiceBetView];
    [betView initWithDuration:duration 
                     openUser:nickName 
                         ante:ante
                      winOdds:windOdds 
                     loseOdds:loseOdds];
    [view addSubview:betView];
}

- (void)initWithDuration:(int)duration
                openUser:(NSString *)nickName
                    ante:(int)ante
                 winOdds:(CGFloat)windOdds
                loseOdds:(CGFloat)loseOdds
{
    _second = duration;
    bgImageView.image = [[DiceImageManager defaultManager] popupBackgroundImage];
    
    titleLabel.text = [NSString stringWithFormat:NSLS(@"kBetViewTitle"), _second];
    noteLabel.text = [NSString stringWithFormat:NSLS(@"kBetNote"), nickName];
    anteLabel.text = NSLS(@"kAnte");
    anteCoinsLabel.text = [NSString stringWithFormat:NSLS(@"kAnteCoins"), ante];
    winLabel.text = NSLS(@"kWin");
    loseLabel.text = NSLS(@"kLose");
    winOddsLabel.text = NSLS(@"kOdds");
    loseOddsLabel.text = NSLS(@"kOdds");
}

- (IBAction)clickCloseButton:(id)sender {
    [self killTimer];
    [self removeFromSuperview];
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
        [self removeFromSuperview];
    }
}


@end
