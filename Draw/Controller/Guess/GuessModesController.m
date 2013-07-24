//
//  GuessModesController.m
//  Draw
//
//  Created by 王 小涛 on 13-7-19.
//
//

#import "GuessModesController.h"
#import "GuessSelectController.h"
#import "CommonTitleView.h"

@interface GuessModesController (){
    int _countDown;
    CGRect _contestModeLabelOriginFrame;
}

@end

@implementation GuessModesController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _contestModeLabelOriginFrame = self.contestModeLabel.frame;
    
    [self.view addSubview:[CommonTitleView createWithTitle:NSLS(@"kSelectGuessMode") delegate:self]];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeout:) userInfo:nil repeats:YES];
}

- (void)killTimer{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timeout:(id)sender{
    
    int pre = _countDown;
    int cur = _countDown - 1;
    
    if (pre > 0 && cur <= 0) {
        [self openContestMode];        
    }
        
    else{
        
        int hour =  _countDown / 3600;
        int minus = (_countDown % 3600) / 60;
        int second = _countDown % 60;
        
        self.hourLabel.text = [NSString stringWithFormat:@"%d", hour];
        self.minusLabel.text = [NSString stringWithFormat:@"%d", minus];
        self.secondLabel.text = [NSString stringWithFormat:@"%d", second];
    }
}

- (void)openContestMode{
    
    [UIView animateWithDuration:1 animations:^{
        _contestModeLabel.center = _contestModeButton.center;
    } completion:^(BOOL finished) {
        self.countDownImageView.hidden = YES;
        self.hourLabel.hidden = YES;
        self.minusLabel.hidden = YES;
        self.secondLabel.hidden = YES;
    }];
}

- (void)closeContestMode{
    
    [UIView animateWithDuration:1 animations:^{
        self.contestModeLabel.frame = _contestModeLabelOriginFrame;
    } completion:^(BOOL finished) {
        self.countDownImageView.hidden = NO;
        self.hourLabel.hidden = NO;
        self.minusLabel.hidden = NO;
        self.secondLabel.hidden = NO;
    }];
}

- (IBAction)clickHappyModeButton:(id)sender {
    
    GuessSelectController *vc = [[[GuessSelectController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickGeniusModeButton:(id)sender {
    
}

- (IBAction)clickContestModeButton:(id)sender {
    
}

- (IBAction)clickRankButton:(id)sender {
}


- (IBAction)clickRuleButton:(id)sender {
}

- (void)dealloc {
    [_happyModeLabel release];
    [_contestModeLabel release];
    [_genuisModeLabel release];
    [_rankListLabel release];
    [_rulesLabel release];
    [_hourLabel release];
    [_hourLabel release];
    [_minusLabel release];
    [_secondLabel release];
    [_countDownImageView release];
    [_contestModeButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setHappyModeLabel:nil];
    [self setContestModeLabel:nil];
    [self setGenuisModeLabel:nil];
    [self setRankListLabel:nil];
    [self setRulesLabel:nil];
    [self setHourLabel:nil];
    [self setHourLabel:nil];
    [self setMinusLabel:nil];
    [self setSecondLabel:nil];
    [self setCountDownImageView:nil];
    [self setContestModeButton:nil];
    [super viewDidUnload];
}
@end
