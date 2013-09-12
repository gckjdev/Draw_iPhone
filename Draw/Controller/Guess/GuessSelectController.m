//
//  GuessSelectController.m
//  Draw
//
//  Created by 王 小涛 on 13-7-19.
//
//

#import "GuessSelectController.h"
#import "Opus.h"

#import "CommonMessageCenter.h"
#import "GuessSelectCell.h"
#import "ShowFeedController.h"
#import "PBOpus+Extend.h"
#import "UseItemScene.h"
#import "CustomInfoView.h"
#import "AccountService.h"
#import "ConfigManager.h"
#import "GuessManager.h"
#import "ContestRankView.h"

#define TABID 1
#define LIMIT 20

@interface GuessSelectController (){
    PBUserGuessMode _mode;
}
@property (retain, nonatomic) NSArray *opuses;
@property (retain, nonatomic) PBGuessContest *contest;

@end

@implementation GuessSelectController


- (void)dealloc{
    [_opuses release];
    [_contest release];
    [super dealloc];
}


- (id)initWithMode:(PBUserGuessMode)mode contest:(PBGuessContest *)contest{
    
    if (self  = [super init]) {
        _mode = mode;
        self.contest = contest;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated{

    
    [super viewWillAppear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setCanDragBack:NO];
    // Do any additional setup after loading the view from its nib.
    self.supportRefreshHeader = NO;
    if (_mode == PBUserGuessModeGuessModeContest
        || _mode == PBUserGuessModeGuessModeHappy) {
        self.supportRefreshFooter = NO;
        self.supportRefreshHeader = NO;
    }
    
    [self initTabButtons];
    [self clickTab:TABID];
    
    [self.titleView setTarget:self];
    
    NSString *title = nil;
    NSString *rightButtonTitle = nil;
    if (_mode == PBUserGuessModeGuessModeHappy) {
        title = NSLS(@"kHappGuessMode");
        rightButtonTitle = NSLS(@"kRestart");
        [self.titleView setRightButtonSelector:@selector(clickRestartButton:)];
    }else if(_mode == PBUserGuessModeGuessModeGenius){
        title = NSLS(@"kGeniusGuessMode");
        rightButtonTitle = NSLS(@"kRestart");
        [self.titleView setRightButtonSelector:@selector(clickRestartButton:)];

    }else if(_mode == PBUserGuessModeGuessModeContest){
        title = NSLS(@"kContestGuessMode");
        rightButtonTitle = NSLS(@"kRanking");
        [self.titleView setRightButtonSelector:@selector(clickRankingButton:)];

    }
    
    [self.titleView setTitle:title];
    [self.titleView setRightButtonTitle:rightButtonTitle];
    
    self.view.backgroundColor = COLOR_WHITE;
    
    [GuessManager deductCoins:_mode contestId:_contest.contestId force:NO];
    
    
    [self showRuleMessageWithTitle:title];
    
    BOOL startNew = [GuessManager isLastGuessDateExpire:_mode];    
    if (startNew) {
        NSString *message = [NSString stringWithFormat:NSLS(@"kGuessDateExpire"), [GuessManager getGuessExpireTime:_mode]];
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kHint") message:message style:CommonDialogStyleSingleButton];
        [dialog.oKButton setTitle:NSLS(@"kIGotIt") forState:UIControlStateNormal];
        [dialog setClickOkBlock:^(id infoView){
            [self startNew];
        }];
        
        [dialog showInView:self.view];
    }
}

#define KEY_NO_REMIND_HAPPY_GUESS_RULE @"KEY_NO_REMIND_HAPPY_GUESS_RULE"
#define KEY_NO_REMIND_GENIUS_GUESS_RULE @"KEY_NO_REMIND_GENIUS_GUESS_RULE"
#define KEY_NO_REMIND_CONTEST_GUESS_RULE @"KEY_NO_REMIND_CONTEST_GUESS_RULE"

- (void)showRuleMessageWithTitle:(NSString *)title{
    
    NSString *message = @"";
    NSString *key = @"";
    if (_mode == PBUserGuessModeGuessModeHappy) {
        message = [NSString stringWithFormat:NSLS(@"kHappyGuessRulesDetil"),
                   [GuessManager getDeductCoins:PBUserGuessModeGuessModeHappy],
                   [GuessManager awardCoins:[GuessManager getCountHappyModeAwardOnce] mode:PBUserGuessModeGuessModeHappy],
                   [GuessManager getCountHappyModeAwardOnce],
                   [GuessManager getGuessExpireTime:_mode]];
        key = KEY_NO_REMIND_HAPPY_GUESS_RULE;
    }else if(_mode == PBUserGuessModeGuessModeGenius){
        message = [NSString stringWithFormat:NSLS(@"kGeniusGuessRulesDetil"),
                   [GuessManager getDeductCoins:PBUserGuessModeGuessModeGenius],
                   [GuessManager getCountGeniusModeAwardOnce],
                   [GuessManager awardCoins:[GuessManager getCountHappyModeAwardOnce] mode:PBUserGuessModeGuessModeGenius],
                   
                   [GuessManager getCountGeniusModeAwardOnce] * 2,
                   [GuessManager awardCoins:[GuessManager getCountHappyModeAwardOnce] * 2 mode:PBUserGuessModeGuessModeGenius],
                   
                   [GuessManager getCountGeniusModeAwardOnce] * 3,
                   [GuessManager awardCoins:[GuessManager getCountHappyModeAwardOnce] * 3 mode:PBUserGuessModeGuessModeGenius],
                   
                   [GuessManager getGuessExpireTime:_mode]];
        key = KEY_NO_REMIND_GENIUS_GUESS_RULE;

    }else if(_mode == PBUserGuessModeGuessModeContest){
        message = [NSString stringWithFormat:NSLS(@"kContestGuessRulesDetil"),
                   [GuessManager getDeductCoins:PBUserGuessModeGuessModeContest]];
        key = KEY_NO_REMIND_CONTEST_GUESS_RULE;
    }
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key] != nil) {
        return;
    }
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:title message:message style:CommonDialogStyleDoubleButton];
    [dialog.oKButton setTitle:NSLS(@"kNoMoreShowIt") forState:UIControlStateNormal];
    [dialog.cancelButton setTitle:NSLS(@"kIGotIt") forState:UIControlStateNormal];
    
    [dialog setClickOkBlock:^(id infoView){
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
    [dialog showInView:self.view];
}

- (void)viewDidUnload {
    [self setTitleView:nil];
    [super viewDidUnload];
}


- (NSInteger)tabCount{
    return 1;
}

- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index{
    return LIMIT;
}

- (NSInteger)tabIDforIndex:(NSInteger)index{
    return TABID;
}

- (NSString *)tabTitleforIndex:(NSInteger)index{
    return nil;
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID{
    
    [self loadData:self.currentTab.offset limit:LIMIT startNew:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger number = [super tableView:tableView numberOfRowsInSection:section];

    int count = number / LIMIT + ((number % LIMIT != 0) ? 1 : 0);
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [GuessSelectCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GuessSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:[GuessSelectCell getCellIdentifier]];
    if (cell == nil) {
        cell = [GuessSelectCell createCell:self];
    }
    
    int location = indexPath.row * LIMIT;
    int leftLen = [self.currentTab.dataList count] - location;
    int length = MIN(LIMIT, leftLen);
    NSArray *arr = [self.currentTab.dataList subarrayWithRange:NSMakeRange(location, length)];
    [cell setCellInfo:arr];
    [cell setIndexPath:indexPath];
    if (_mode == PBUserGuessModeGuessModeGenius) {
        [cell setCurrentGuessIndex:[GuessManager guessIndex:self.currentTab.dataList]];
    }
    return cell;
}


- (void)loadData:(int)offset limit:(int)limit startNew:(BOOL)startNew{
    
    if (startNew) {
        [GuessManager setLastGuessDateDate:_mode];
    }
    
    [self showActivityWithText:NSLS(@"kLoading")];
    [[GuessService defaultService] getOpusesWithMode:_mode
                                           contestId:_contest.contestId
                                              offset:offset
                                               limit:limit
                                          isStartNew:startNew
                                            delegate:self];
}

- (void)didGetOpuses:(NSArray *)opuses resultCode:(int)resultCode isStartNew:(BOOL)isStartNew{
    
    PPDebug(@"count = %d", [opuses count]);
    [self hideActivity];

    if (resultCode == 0) {
        
        [self finishLoadDataForTabID:TABID resultList:opuses];
        
    }else{
       POSTMSG(NSLS(@"kLoadFailed"));
    }
}

- (IBAction)clickRestartButton:(id)sender {
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kHint") message:NSLS(@"kRestartGuessWarnning") style:CommonDialogStyleDoubleButton];
    [dialog showInView:self.view];
    
    [dialog setClickOkBlock:^(UILabel *label){
        [self startNew];
    }];
}

- (void)clickRankingButton:(id)sender{
    [[GuessService defaultService] getGuessRankWithType:0
                                                   mode:_mode
                                              contestId:_contest.contestId
                                               delegate:self];
}

- (void)startNew{
    
    [GuessManager deductCoins:_mode contestId:_contest.contestId force:YES];
    self.currentTab.offset = 0;
    [self loadData:self.currentTab.offset limit:LIMIT startNew:YES];
}

- (IBAction)clickShareButton:(id)sender {
    
}

- (void)didClickOpusWithIndex:(int)index{
    
    if (index >= [self.currentTab.dataList count]) {
        PPDebug(@"<didClickOpusIndex> index = %d, large than datalist count %d", index, [self.currentTab.dataList count]);
        return;
    }
    
    PBOpus *pbOpus = [self.currentTab.dataList objectAtIndex:index];
    
    if (_mode == PBUserGuessModeGuessModeGenius) {
        if (pbOpus.guessInfo.isCorrect == YES) {
            [self gotoOpusDetailController:pbOpus];
        }else if (pbOpus.guessInfo.isCorrect == NO && index == [GuessManager guessIndex:self.currentTab.dataList]) {
            [self gotoOpusGuessController:pbOpus index:index];
        }else{
            POSTMSG(NSLS(@"kGuessPreviousOpusFirst"));
        }
    }else{
        if (pbOpus.guessInfo.isCorrect == YES) {
            [self gotoOpusDetailController:pbOpus];
        }else {
            [self gotoOpusGuessController:pbOpus index:index];
        }
    }
}

- (void)gotoOpusGuessController:(PBOpus *)pbOpus  index:(int)index{
    Opus *opus = [Opus opusWithPBOpus:pbOpus];
    DrawGuessController *vc = [[[DrawGuessController alloc] initWithOpus:opus mode:_mode contest:_contest] autorelease];
    vc.index = index;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoOpusDetailController:(PBOpus *)pbOpus{
    DrawFeed *feed = [pbOpus toDrawFeed];
    UseItemScene *scene = [UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:feed];
    ShowFeedController *vc = [[[ShowFeedController alloc] initWithFeed:feed scene:scene] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didGuessCorrect{
    
    [self refreshData];

    int count = [GuessManager passCount:self.currentTab.dataList] + 1;
    
    if ([GuessManager canAwardNow:count mode:_mode]) {
        [self awardWithCount:count];
    }else{
        [self showTipsWithCount:count];
    }
}

- (void)didGuessWrong{
    
    if (_mode == PBUserGuessModeGuessModeGenius) {
        [self guessWrongInGenuisMode];
    }
}

- (void)guessWrongInGenuisMode{
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kGuessWrong") message:NSLS(@"kGuessGenuisFail") style:CommonDialogStyleDoubleButton];
    [dialog.oKButton setTitle:NSLS(@"kRestart") forState:UIControlStateNormal];
    [dialog.cancelButton setTitle:NSLS(@"kQuit") forState:UIControlStateNormal];
    
    [dialog setClickOkBlock:^(UILabel *label){
        
        [self startNew];
    }];
    
    [dialog setClickCancelBlock:^(NSString *inputStr){
        
        [self startNew];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [dialog showInView:self.view];
}

- (void)awardWithCount:(int)count{
    
    int awardCoins = [GuessManager awardCoins:count mode:_mode];

    if (_mode == PBUserGuessModeGuessModeHappy) {
        
        [self awardInHappyMode:count award:awardCoins];
    }else if (_mode == PBUserGuessModeGuessModeGenius){
        
        [self awardInGeniusMode:count award:awardCoins];        
    }else if (_mode == PBUserGuessModeGuessModeContest){

    }
}

- (void)showTipsWithCount:(int)count{
    
    if (_mode == PBUserGuessModeGuessModeHappy) {
        [self showTipInHappyMode:count];
    }else if (_mode == PBUserGuessModeGuessModeGenius){
        [self showTipInGeniusMode:count];
    }else if (_mode == PBUserGuessModeGuessModeContest){
        // TODO: show tip in contest mode.
        [[GuessService defaultService] getGuessRankWithType:0 mode:PBUserGuessModeGuessModeContest contestId:_contest.contestId delegate:self];
    }
}

- (void)didGetGuessRank:(PBGuessRank *)rank resultCode:(int)resultCode{
    
    if (resultCode == 0) {
        
        if ([GuessManager countNeedToGuessToAward:rank.pass mode:_mode] == 0) {
            [self showTipInContestModeWhenContestOver:rank];
        }else{
            [self showTipInContestMode:rank];
        }
    }
}

- (void)awardInHappyMode:(int)passCount
                   award:(int)award{
    
    // chage account
    [[AccountService defaultService] chargeCoin:award source:AwardCoinType];
    
    // tip
    NSString *info = [NSString stringWithFormat:NSLS(@"kGuessHappyModeAwardTips"), passCount, award];
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kAward") message:info style:CommonDialogStyleDoubleButton];
    [dialog.oKButton setTitle:NSLS(@"kGoOn") forState:UIControlStateNormal];
    [dialog.cancelButton setTitle:NSLS(@"kQuit") forState:UIControlStateNormal];
    
    [dialog setClickOkBlock:^(UILabel *label){
        if (passCount >= 20) {
            [self startNew];
        }
    }];
    
    [dialog setClickCancelBlock:^(NSString *inputStr){
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [dialog showInView:self.view];
}

- (void)awardInGeniusMode:(int)passCount
                    award:(int)award{
    
    [[AccountService defaultService] chargeCoin:award source:AwardCoinType];
    
    NSString *info = [NSString stringWithFormat:NSLS(@"kGuessGenuisModeAwardTips"), passCount,award];
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kAward") message:info style:CommonDialogStyleDoubleButton];
    [dialog.oKButton setTitle:NSLS(@"kGoOn") forState:UIControlStateNormal];
    [dialog.cancelButton setTitle:NSLS(@"kQuit") forState:UIControlStateNormal];
    
    [dialog setClickCancelBlock:^(NSString *inputStr){
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [dialog showInView:self.view];
}

- (void)showTipInHappyMode:(int)count{
    
    int predictAwardCoins = [GuessManager predictAwardCoins:count mode:_mode];
    int needToGuess = [GuessManager countNeedToGuessToAward:count mode:_mode];
    
    NSString *info = [NSString stringWithFormat:NSLS(@"kGuessHappyModeTips"), count, needToGuess, predictAwardCoins];
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kHint") message:info style:CommonDialogStyleSingleButton];
    [dialog.oKButton setTitle:NSLS(@"kIGotIt") forState:UIControlStateNormal];
    [dialog showInView:self.view];
}


- (void)showTipInGeniusMode:(int)count{
    
    int predictAwardCoins = [GuessManager predictAwardCoins:count mode:_mode];
    int needToGuess = [GuessManager countNeedToGuessToAward:count mode:_mode];
    
    NSString *info = [NSString stringWithFormat:NSLS(@"kGuessGenuisModeTips"), count, needToGuess, predictAwardCoins];
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kHint") message:info style:CommonDialogStyleDoubleButton];
    [dialog.oKButton setTitle:NSLS(@"kGoOn") forState:UIControlStateNormal];
    [dialog.cancelButton setTitle:NSLS(@"Back") forState:UIControlStateNormal];
    
    [dialog setClickCancelBlock:^(id infoView){
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [dialog showInView:self.view];
}

- (void)showTipInContestMode:(PBGuessRank *)rank{
    
//    NSString *info = [NSString stringWithFormat:NSLS(@"kGuessContestModeTips"), rank.pass, rank.ranking, rank.earn, rank.totalPlayer];
//    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kHint") message:info style:CommonDialogStyleSingleButton];
//    [dialog.oKButton setTitle:NSLS(@"kIGotIt") forState:UIControlStateNormal];
//    [dialog showInView:self.view];
    
    ContestRankView *v = [ContestRankView createViewWithRank:rank];
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kGuessContestModeTips") customView:v style:CommonDialogStyleSingleButton];
    [dialog.oKButton setTitle:NSLS(@"kIGotIt") forState:UIControlStateNormal];
    [dialog showInView:self.view];
}

- (void)showTipInContestModeWhenContestOver:(PBGuessRank *)rank{
    
//    NSString *info = [NSString stringWithFormat:NSLS(@"kGuessContestModeOverTips"), rank.totalPlayer, rank.ranking, rank.earn];
//    
//    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kHint") message:info style:CommonDialogStyleSingleButton];
//    [dialog.oKButton setTitle:NSLS(@"kIGotIt") forState:UIControlStateNormal];
//    [dialog showInView:self.view];
    
    ContestRankView *v = [ContestRankView createViewWithRank:rank];
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kGuessContestModeOverTips") customView:v style:CommonDialogStyleSingleButton];
    [dialog.oKButton setTitle:NSLS(@"kIGotIt") forState:UIControlStateNormal];
    [dialog showInView:self.view];
}

- (void)refreshData{
    
    self.currentTab.offset = 0;
    int count = [self.currentTab.dataList count];
    [self loadData:self.currentTab.offset limit:count startNew:NO];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index{
    return NSLS(@"kNoData");
}

@end
