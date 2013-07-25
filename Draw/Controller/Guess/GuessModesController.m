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
@property (retain, nonatomic) PBGuessContest *contest;

@end

@implementation GuessModesController


- (void)dealloc {
    [[GuessService defaultService] setDelegate:nil];
    [_contest release];
    [_happyModeLabel release];
    [_contestModeLabel release];
    [_genuisModeLabel release];
    [_rankListLabel release];
    [_rulesLabel release];
    [_hourLabel release];
    [_minusLabel release];
    [_secondLabel release];
    [_countDownImageView release];
    [_contestModeButton release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _contestModeLabelOriginFrame = self.contestModeLabel.frame;
    
    [self.view addSubview:[CommonTitleView createWithTitle:NSLS(@"kSelectGuessMode") delegate:self]];
    
    [[GuessService defaultService] getGuessContestList];
    [[GuessService defaultService] setDelegate:self];
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

- (void)didGetGuessContestList:(NSArray *)list resultCode:(int)resultCode{
    if (resultCode == 0) {
        self.contest = [list objectAtIndex:0];
        [self reload];
    }else{
        [self popupHappyMessage:NSLS(@"kLoadFailed") title:nil];
    }
}

- (void)reload{
    switch (_contest.state) {
        case PBGuessContestStateGuessContestStateNotStart:
            _countDown = _contest.startTime - [[NSDate date] timeIntervalSince1970];
            [self contestNotStart];
            break;
            
        case PBGuessContestStateGuessContestStateEnd:
            [self contestEnd];
            break;
            
        case PBGuessContestStateGuessContestStateIng:
            [self contesting];
            break;
            
        default:
            break;
    }
}

- (void)startTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeout:) userInfo:nil repeats:YES];
}

- (void)killTimer{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timeout:(id)sender{
    
    _countDown--;
    
    if (_countDown <= 0) {
        [self contesting];
        
    }else{
        int hour =  _countDown / 3600;
        int minus = (_countDown % 3600) / 60;
        int second = _countDown % 60;
        
        self.hourLabel.text = [NSString stringWithFormat:@"%02d", hour];
        self.minusLabel.text = [NSString stringWithFormat:@"%02d", minus];
        self.secondLabel.text = [NSString stringWithFormat:@"%02d", second];
    }
}

- (void)contestEnd{
    
    [UIView animateWithDuration:1 animations:^{
        _contestModeLabel.center = _contestModeButton.center;
        self.countDownImageView.alpha = 0;
        self.hourLabel.alpha = 0;
        self.minusLabel.alpha = 0;
        self.secondLabel.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    [self killTimer];
}

- (void)contesting{
    
    [UIView animateWithDuration:1 animations:^{
        self.contestModeLabel.center = _contestModeButton.center;
        
        self.countDownImageView.alpha = 0;
        self.hourLabel.alpha = 0;
        self.minusLabel.alpha = 0;
        self.secondLabel.alpha = 0;
    } completion:^(BOOL finished) {

    }];
    
    [self killTimer];
}

- (void)contestNotStart{
    
    [UIView animateWithDuration:1 animations:^{
        self.contestModeLabel.frame = _contestModeLabelOriginFrame;
    } completion:^(BOOL finished) {

    }];
    
    [self startTimer];
}

- (IBAction)clickHappyModeButton:(id)sender {
    
    GuessSelectController *vc = [[[GuessSelectController alloc] initWithMode:PBUserGuessModeGuessModeHappy] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickGeniusModeButton:(id)sender {
    GuessSelectController *vc = [[[GuessSelectController alloc] initWithMode:PBUserGuessModeGuessModeGenius] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickContestModeButton:(id)sender {
    
}

- (IBAction)clickRankButton:(id)sender {
}


- (IBAction)clickRuleButton:(id)sender {
}

- (void)clickBack:(id)sender{
    [self killTimer];
    [super clickBack:sender];
}


@end
