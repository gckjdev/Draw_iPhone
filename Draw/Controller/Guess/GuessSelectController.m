//
//  GuessSelectController.m
//  Draw
//
//  Created by 王 小涛 on 13-7-19.
//
//

#import "GuessSelectController.h"
#import "DrawGuessController.h"
#import "Opus.h"
#import "CommonTitleView.h"
#import "CommonMessageCenter.h"
#import "AnimationManager.h"

#define OPUS_BUTTON_OFFSET 100


@interface GuessSelectController (){
    PBUserGuessMode _mode;
    int _curIndex;
}
@property (retain, nonatomic) NSArray *opuses;

@end

@implementation GuessSelectController

- (id)initWithMode:(PBUserGuessMode)mode{
    
    if (self  = [super init]) {
        _mode = mode;
    }
    
    return self;
}

- (void)dealloc{
    [[GuessService defaultService] setDelegate:nil];
    [_opuses release];
    [_opusesHolderView release];
    [_guessedInfoLabel release];
    [_awardInfoLabel release];
    [_aheadInfoLabel release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [[GuessService defaultService] getOpusesWithMode:_mode
                                           contestId:nil
                                              offset:0
                                               limit:20
                                          isStartNew:NO];
    [super viewWillAppear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view addSubview:[CommonTitleView createWithTitle:NSLS(@"kGuangKa") delegate:self]];

    [[GuessService defaultService] getOpusesWithMode:_mode
                                           contestId:nil
                                              offset:0
                                               limit:20
                                          isStartNew:NO];
    [[GuessService defaultService] getGuessRankWithType:HOT_RANK mode:PBUserGuessModeGuessModeHappy contestId:nil];
    
    [[GuessService defaultService] setDelegate:self];
}

- (void)viewDidUnload {
    [self setOpusesHolderView:nil];
    [self setGuessedInfoLabel:nil];
    [self setAwardInfoLabel:nil];
    [self setAheadInfoLabel:nil];
    [super viewDidUnload];
}

- (IBAction)clickOpusButton:(UIButton *)button {
    
    int index = button.tag - OPUS_BUTTON_OFFSET;
    if (index >= [_opuses count]) {
        return;
    }
    
    if (index > _curIndex) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kPleaseCompletePreviousOpus") delayTime:1.5 isHappy:NO];
        return;
    }
    
    PBOpus *pbOpus = [_opuses objectAtIndex:index];
    
//    if (pbOpus.guessInfo.isCorrect) {
//        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kThisOpusIsGuessed") delayTime:1.5 isHappy:NO];
//        return;
//    }
    
    Opus *opus = [Opus opusWithPBOpus:pbOpus];
    
    DrawGuessController *vc = [[[DrawGuessController alloc] initWithOpus:opus] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didGetOpuses:(NSArray *)opuses resultCode:(int)resultCode{
    
    if (resultCode == 0) {
        self.opuses = opuses;
        [self reload];
    }else{
        [self popupUnhappyMessage:NSLS(@"kLoadFailed") title:nil];
    }
}

- (void)didGetGuessRank:(PBGuessRank *)rank resultCode:(int)resultCode{
    if (resultCode == 0) {
        _aheadInfoLabel.text = [NSString stringWithFormat:NSLS(@"kLead:%d\%"), rank.lead];
    }else{
        [self popupUnhappyMessage:NSLS(@"kLoadFailed") title:nil];
    }
}

- (UIButton *)opusButtonWithIndex:(int)index{
    
    return (UIButton *)[_opusesHolderView viewWithTag:(index + OPUS_BUTTON_OFFSET)];
}

- (void)reload{
    int index = 0;
    for (; index < [_opuses count]; index++) {
        PBOpus *opus = [_opuses objectAtIndex:index];
        if (opus.guessInfo.isCorrect) {
            [[self opusButtonWithIndex:index] setImage:[UIImage imageNamed:@"pine_tree@2x.png"] forState:UIControlStateNormal];
            continue;
        }else{
            break;
        }
    }
    
    _curIndex = index;
    CAAnimation *ani = [AnimationManager scaleTo:CATransform3DMakeScale(1.2, 1.2, 1.2) duration:1 scaleTo:CATransform3DMakeScale(0.8, 0.8, 0.8) duration:1 repeatCount:FLT_MAX];
    [[self opusButtonWithIndex:index].layer addAnimation:ani forKey:nil];
    
    _guessedInfoLabel.text = [NSString stringWithFormat:NSLS(@"kCurGuessOpusIs:%d"), _curIndex];
    _aheadInfoLabel.text = [NSString stringWithFormat:NSLS(@"kAwardIs:%d"), [self getAward]];
}

- (IBAction)clickRestartButton:(id)sender {
    
    [[GuessService defaultService] getOpusesWithMode:_mode
                                           contestId:nil
                                              offset:0
                                               limit:20
                                          isStartNew:YES];
    [[GuessService defaultService] getGuessRankWithType:HOT_RANK mode:PBUserGuessModeGuessModeHappy contestId:nil];
}

- (IBAction)clickShareButton:(id)sender {
    
}

@end
