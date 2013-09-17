//
//  GuessModesController.m
//  Draw
//
//  Created by 王 小涛 on 13-7-19.
//
//

#import "GuessModesController.h"
#import "GuessSelectController.h"
#import "GuessRankListController.h"
#import "CommonMessageCenter.h"
#import "JDDateCountdownFlipView.h"
#import "GuessManager.h"
#import "SoundPlayer.h"
#import "UIButton+Sound.h"
#import "ShareImageManager.h"
#import "CommonDialog.h"
#import "UIViewUtils.h"
#import "AnimationManager.h"
#import "TimeUtils.h"

#define TAG_COUNT_DOWN_VIEW 101

@interface GuessModesController (){
    int _countDown;
    CGRect _contestModeLabelOriginFrame;
}
@property (retain, nonatomic) PBGuessContest *contest;

@end

@implementation GuessModesController


- (void)dealloc {
    [_happyModeButton unregisterSound];
    [_geniusModeButton unregisterSound];
    [_contestModeButton unregisterSound];
    [_rankButton unregisterSound];
    [_rulesButton unregisterSound];
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
    [_titleView release];
    [_happyModeButton release];
    [_geniusModeButton release];
    [_rankButton release];
    [_rulesButton release];
    [_contentModeHolderView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _contestModeLabelOriginFrame = self.contestModeLabel.frame;
    
    [_titleView setTitle:NSLS(@"kSelectGuessMode")];
    [_titleView setTarget:self];
    
    _happyModeLabel.text = NSLS(@"kHappGuessMode");
    _genuisModeLabel.text = NSLS(@"kGeniusGuessMode");
    _contestModeLabel.text = NSLS(@"kVS");
    _rankListLabel.text = NSLS(@"kGuessRank");
    _rulesLabel.text = NSLS(@"kGuessRules");
    
    [_happyModeButton registerSound:SOUND_EFFECT_BUTTON_DOWN];
    [_geniusModeButton registerSound:SOUND_EFFECT_BUTTON_DOWN];
    [_contestModeButton registerSound:SOUND_EFFECT_BUTTON_DOWN];
    [_rankButton registerSound:SOUND_EFFECT_BUTTON_DOWN];
    [_rulesButton registerSound:SOUND_EFFECT_BUTTON_DOWN];
    
    [[GuessService defaultService] getGuessContestListWithDelegate:self];
    
    SET_VIEW_BG(self.view);
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
    [self setTitleView:nil];
    [self setHappyModeButton:nil];
    [self setGeniusModeButton:nil];
    [self setRankButton:nil];
    [self setRulesButton:nil];
    [self setContentModeHolderView:nil];
    [super viewDidUnload];
}

- (void)didGetGuessContestList:(NSArray *)list resultCode:(int)resultCode{
    if (resultCode == 0) {
        self.contest = [list objectAtIndex:0];
        [self reload];
    }else{
        POSTMSG(NSLS(@"kLoadFailed"));
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
        
        [[self.contentModeHolderView viewWithTag:TAG_COUNT_DOWN_VIEW] setAlpha:0];
//        self.countDownImageView.alpha = 0;
//        self.hourLabel.alpha = 0;
//        self.minusLabel.alpha = 0;
//        self.secondLabel.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
//    [self killTimer];
}

- (void)contesting{
    
    [UIView animateWithDuration:1 animations:^{
        self.contestModeLabel.center = _contestModeButton.center;
        
        [[self.contentModeHolderView viewWithTag:TAG_COUNT_DOWN_VIEW] setAlpha:0];
//        self.countDownImageView.alpha = 0;
//        self.hourLabel.alpha = 0;
//        self.minusLabel.alpha = 0;
//        self.secondLabel.alpha = 0;
    } completion:^(BOOL finished) {

    }];
    
    CABasicAnimation * animation = [CABasicAnimation
                                    animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithInt:1];
    animation.toValue = [NSNumber numberWithInt:0];
    animation.duration = 0.5 ;    
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VAL;
    
    [self.contestModeLabel.layer addAnimation:animation forKey:nil];
    
    [self killTimer];
}

- (void)contestNotStart{
    
    [UIView animateWithDuration:1 animations:^{
        self.contestModeLabel.frame = _contestModeLabelOriginFrame;
    } completion:^(BOOL finished) {

    }];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_contest.startTime];
    PPDebug(@"contest start time is: %@", dateToLocaleStringWithFormat(date, @"yy-MM-dd HH:mm:ss"));
    JDDateCountdownFlipView *flipView = [[[JDDateCountdownFlipView alloc] initWithHMSTargetDate:date] autorelease];
    [self.contentModeHolderView addSubview:flipView];
    flipView.frame = (ISIPAD ? CGRectMake(34,152,172,48) : CGRectMake(17,77,87,24));
    flipView.tag = TAG_COUNT_DOWN_VIEW;
    [self startTimer];
}

- (IBAction)clickHappyModeButton:(id)sender {
    
    GuessSelectController *vc = [[[GuessSelectController alloc] initWithMode:PBUserGuessModeGuessModeHappy contest:nil]  autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickGeniusModeButton:(id)sender {
    GuessSelectController *vc = [[[GuessSelectController alloc] initWithMode:PBUserGuessModeGuessModeGenius contest:nil] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showContestIsNotStartTip{
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kContestIsNotStart") delayTime:3 isHappy:NO];
}

- (void)showContestIsOverTip{
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kContestIsOver") delayTime:3 isHappy:NO];
}

- (IBAction)clickContestModeButton:(id)sender {
    
#if DEBUG
    
    if ([_contest.contestId length] > 0) {
        GuessSelectController *vc = [[[GuessSelectController alloc] initWithMode:PBUserGuessModeGuessModeContest contest:_contest] autorelease];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
#else
    
    if ([GuessManager isContestNotStart:_contest]) {
        [self showContestIsNotStartTip];
        return;
    }
    if ([GuessManager isContestOver:_contest]) {
        [self showContestIsOverTip];
        return;
    }
#endif
}

- (IBAction)clickRankButton:(id)sender {
    GuessRankListController *vc = [[[GuessRankListController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)clickRuleButton:(id)sender {
//    static int i = 0;
//    [WQPlaySound playVibrate];
//    [WQPlaySound playSystemSoundEffectWithName:nil loopCount:5];
//    [SoundPlayer playAlertSoundEffectWithName:nil loopCount:3];
//    if (i % 3 == 0) {
//        [WQPlaySound playVibrate];
//    }else if (i % 3 == 1){
//        [WQPlaySound playSystemSoundEffectWithName:nil];
//    }else{
//        [WQPlaySound playSoundEffectWithName:nil];
//    }
//    
//    i++;
    
//    "kGuessRulesDetail" = "欢乐模式\n规则：参加需花%d金币\n奖励：每猜中%d幅作品则可以获得%d金币\n\n天才模式\n规则：参加需花%d金币\n奖励：连续猜中%d幅作品可获得%d金币奖励，连续猜中%d幅可获得%d金币奖励，连续猜中%d幅可获得%d金币奖励，以此类推\n\n比赛模式\n规则：参加需花%d金币\n奖励：当天比赛总奖金是70*N，其中N是参赛人数。第1名获得金币＝总奖金*50%，第2到第4名每人获得金币＝总奖金*30%/3，第5名到第10名每人获得金币＝总奖金*10%/6，10名以后前15%的人每人获得的金币＝总奖金*10%/(N*15%-10)";
    
    NSString *message = [NSString stringWithFormat:NSLS(@"kGuessRulesDetail"),
                        [GuessManager getDeductCoins:PBUserGuessModeGuessModeHappy],
                        [GuessManager getCountHappyModeAwardOnce],
                        [GuessManager awardCoins:[GuessManager getCountHappyModeAwardOnce] mode:PBUserGuessModeGuessModeHappy],
                         
                        [GuessManager getDeductCoins:PBUserGuessModeGuessModeGenius],
                        [GuessManager getCountGeniusModeAwardOnce],
                        [GuessManager awardCoins:[GuessManager getCountHappyModeAwardOnce] mode:PBUserGuessModeGuessModeGenius],
                         
                        [GuessManager getCountGeniusModeAwardOnce] * 2,
                        [GuessManager awardCoins:[GuessManager getCountHappyModeAwardOnce] * 2 mode:PBUserGuessModeGuessModeGenius],
                         
                        [GuessManager getCountGeniusModeAwardOnce] * 3,
                        [GuessManager awardCoins:[GuessManager getCountHappyModeAwardOnce] * 3 mode:PBUserGuessModeGuessModeGenius],
                         
                        [GuessManager getDeductCoins:PBUserGuessModeGuessModeContest]];
    
    __block GuessModesController *cp = self;
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kGuessRules") message:message style:CommonDialogStyleCross];
    dialog.messageLabel.font = [UIFont systemFontOfSize:(ISIPAD ? 28 : 14)];
    [dialog setClickCloseBlock:^(id infoView){
        [cp setCanDragBack:YES];
    }];
    [self setCanDragBack:NO];
    [dialog showInView:self.view];

}

- (void)clickBack:(id)sender{
    [self killTimer];
    [super clickBack:sender];
}



@end
