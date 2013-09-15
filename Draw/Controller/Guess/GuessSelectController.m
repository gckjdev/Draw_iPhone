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
    int _countDown;
    int _guessIndex;  // 表示当前合法的猜的关卡，仅对天才模式有用，因为天才模式需要一关关闯关，对于其他两种模式，这个值为-1。当这个值为-1时，表示当前合法的猜的关卡是任意的。

}
@property (retain, nonatomic) NSMutableDictionary *guessInfoDic;    // 每幅作品是否被猜过的信息。

@property (retain, nonatomic) PBGuessContest *contest;

@end

@implementation GuessSelectController


- (void)dealloc{
    [_contest release];
    [_countDownLabel release];
    [_guessInfoDic release];
    [super dealloc];
}


- (id)initWithMode:(PBUserGuessMode)mode contest:(PBGuessContest *)contest{
    
    if (self  = [super init]) {
        _mode = mode;
        self.contest = contest;
        
        self.guessInfoDic = [NSMutableDictionary dictionary];

    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated{

    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.dataTableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setCanDragBack:NO];
    // Do any additional setup after loading the view from its nib.
    
    self.supportRefreshHeader = NO;
    self.supportRefreshFooter = [GuessManager isSupportRefreshFooterWithMode:_mode];
    
    self.countDownLabel.textColor = COLOR_BROWN;
    self.view.backgroundColor = COLOR_WHITE;
    
    [self.titleView setTarget:self];
    [self.titleView setBackButtonSelector:@selector(clickBack)];
    [self.titleView setTitle:[GuessManager getTitleWithMode:_mode]];
    [self.titleView setRightButtonTitle:[GuessManager getRightButtonTitleWithMode:_mode]];
    [self.titleView setRightButtonSelector:[GuessManager getRightButtonSelectorWithMode:_mode]];

    [self initTabButtons];
    [self clickTab:TABID];
    
    GuessState state = [GuessManager getGuessStateWithMode:_mode contestId:_contest.contestId];
    if (state == GuessStateBeing) {
        [self startCountDown];
    }else if (state == GuessStateExpire) {
        self.countDownLabel.text = NSLS(@"kTimeout");
    }else if (state == GuessStateFail) {
        self.countDownLabel.text = NSLS(@"kGuessWrong");
    }else{
        self.countDownLabel.hidden = YES;
    }
    
    if (_mode == PBUserGuessModeGuessModeContest) {
        self.countDownLabel.hidden = YES;
    }
}

- (void)startCountDown{
    
    [self stopCountDown];
    
    self.countDownLabel.hidden = NO;
    _countDown = [GuessManager getTimeIntervalUtilExpire:_mode];
    if (_countDown > 0) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountDownInfo) userInfo:nil repeats:YES];
    }
}

- (void)stopCountDown{
    
    [self.timer invalidate];
    self.timer = nil;
}

- (void)updateCountDownInfo{
    
    _countDown --;
    
    if (_countDown <= 0) {
        [self stopCountDown];
        [GuessManager setGuessState:GuessStateExpire mode:_mode contestId:_contest.contestId];
        self.countDownLabel.text = NSLS(@"kTimeout");
        return;
    }
    
    int hours = _countDown / 3600;
    int minus = _countDown /60 % 60;
    int second = _countDown % 60;
    _countDownLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minus, second];
}



#define KEY_NO_REMIND_HAPPY_GUESS_RULE @"KEY_NO_REMIND_HAPPY_GUESS_RULE"
#define KEY_NO_REMIND_GENIUS_GUESS_RULE @"KEY_NO_REMIND_GENIUS_GUESS_RULE"
#define KEY_NO_REMIND_CONTEST_GUESS_RULE @"KEY_NO_REMIND_CONTEST_GUESS_RULE"

- (void)showRuleMessage{
    
    NSString *title = @"";
    NSString *message = @"";
    NSString *key = @"";
    if (_mode == PBUserGuessModeGuessModeHappy) {
        title = NSLS(@"kHappyGuessRules");
        message = [NSString stringWithFormat:NSLS(@"kHappyGuessRulesDetil"),
                   [GuessManager getDeductCoins:PBUserGuessModeGuessModeHappy],
                   [GuessManager awardCoins:[GuessManager getCountHappyModeAwardOnce] mode:PBUserGuessModeGuessModeHappy],
                   [GuessManager getCountHappyModeAwardOnce],
                   [GuessManager getGuessExpireTime:_mode]];
        key = KEY_NO_REMIND_HAPPY_GUESS_RULE;
    }else if(_mode == PBUserGuessModeGuessModeGenius){
        title = NSLS(@"kGeniusGuessRules");
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
        title = NSLS(@"kContestGuessRules");
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
    [self setCountDownLabel:nil];
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
    
    NSArray *arr = [self getGuessedInfoListWithLocation:location length:length];
    [cell setCellInfo:arr];
    [cell setIndexPath:indexPath];
    
    
    if ([GuessManager getGuessStateWithMode:_mode contestId:_contest.contestId] == GuessStateBeing) {
        if (_mode == PBUserGuessModeGuessModeGenius) {
            [cell setCurrentGuessIndex:_guessIndex];
        }else{
            [cell setNotGuessFlash];
        }
    }else{
        [cell setNothingFlash];
    }
    
    return cell;
}

- (NSArray *)getGuessedInfoListWithLocation:(int)location length:(int)length{
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int index = location; index < location + length; index ++) {
        
        NSString *key = [self getGuessInfoKeyFormIndex:index];
        NSNumber *isGuessed = [self.guessInfoDic objectForKey:key];
        [arr addObject:isGuessed];
    }
    
    return arr;
}

- (void)loadData:(int)offset limit:(int)limit startNew:(BOOL)startNew{
    
    [self showActivityWithText:NSLS(@"kLoading")];
    [[GuessService defaultService] getOpusesWithMode:_mode
                                           contestId:_contest.contestId
                                              offset:offset
                                               limit:limit
                                          isStartNew:startNew
                                            delegate:self];
}

- (void)updateGuessInfo{
    
    [self.guessInfoDic removeAllObjects];
    
    for (int index = 0; index < [self.currentTab.dataList count]; index ++) {
        
        PBOpus *pbOpus = [self.currentTab.dataList objectAtIndex:index];
        [self.guessInfoDic setObject:@(pbOpus.guessInfo.isCorrect) forKey:[self getGuessInfoKeyFormIndex:index]];
    }
}

- (NSString *)getGuessInfoKeyFormIndex:(int)index{
    
    return [NSString stringWithFormat:@"%d", index];
}

- (void)setIndexAsGuessed:(int)index{
    
    NSString *key = [self getGuessInfoKeyFormIndex:index];
    [self.guessInfoDic setObject:@(YES) forKey:key];
}

- (BOOL)isIndexGuessed:(int)index{
    
    NSString *key = [self getGuessInfoKeyFormIndex:index];
    NSNumber *isGuessed = [self.guessInfoDic objectForKey:key];
    return isGuessed.boolValue;
}

- (int)getGuessedCount{
    
    int count = 0;
    for (int index = 0; index < [[self.guessInfoDic allValues] count]; index ++) {
        if ([self isIndexGuessed:index]) {
            count++;
        }
    }
    return count;
}



- (void)didGetOpuses:(NSArray *)opuses resultCode:(int)resultCode isStartNew:(BOOL)isStartNew{
    
    PPDebug(@"count = %d", [opuses count]);
    [self hideActivity];

    if (resultCode == 0) {
        
        [self finishLoadDataForTabID:TABID resultList:opuses];
        [self updateGuessInfo];
        _guessIndex = [GuessManager getGuessIndexWithMode:_mode guessList:self.currentTab.dataList];
        
    }else{
       POSTMSG2(NSLS(@"kLoadFailed"), 2);
    }
}

- (IBAction)clickRestartButton:(id)sender {
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kHint") message:NSLS(@"kRestartGuessWarnning") style:CommonDialogStyleDoubleButton];
    [dialog showInView:self.view];
    
    [dialog setClickOkBlock:^(UILabel *label){
        [self startNew];
    }];
}

- (void)clickRankingButton:(UIButton *)button{
    
    [self showActivityWithText:NSLS(@"kLoading")];
    [[GuessService defaultService] getGuessRankWithType:0
                                                   mode:_mode
                                              contestId:_contest.contestId
                                               delegate:self];
}

- (void)startNew{
    
    [GuessManager setGuessState:GuessStateNotStart mode:_mode contestId:_contest.contestId];
    
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
        
    if ([self isIndexGuessed:index]) {
        [self gotoOpusDetailControllerWithIndex:index];
    }else{
        if ([self isGuessIndexValid:index]) {
            [self handleIndexThatNotGuessed:index];
        }else{
            POSTMSG2(NSLS(@"kGuessPreviousOpusFirst"), 2);
        }
    }
}


- (void)handleIndexThatNotGuessed:(int)index{
    
    GuessState state = [GuessManager getGuessStateWithMode:_mode contestId:_contest.contestId];
    switch (state) {
        case GuessStateNotStart:
            [self handleWithNotStart:index];
            break;
            
        case GuessStateBeing:
            [self gotoOpusGuessControllerWithIndex:index];
            break;
            
        case GuessStateExpire:
            [self handleWithExpire:index];
            break;
            
        case GuessStateFail:
            [self handleWithFail:index];
            break;
            
        default:
            break;
    }
}


- (void)handleWithNotStart:(int)index{
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:[GuessManager getGuessRulesTitleWithModex:_mode] message:[GuessManager getGuessRulesWithModex:_mode] style:CommonDialogStyleDoubleButton];
    
    [dialog setClickOkBlock:^(id infoView){
       
        [GuessManager setGuessState:GuessStateBeing mode:_mode contestId:_contest.contestId];
        [GuessManager setLastGuessDateDate:_mode];
        [GuessManager deductCoins:_mode contestId:_contest.contestId];
        POSTMSG2([GuessManager getDeductCoinsPopMessageWithMode:_mode], 2);
        [self startCountDown];
        
        [self gotoOpusGuessControllerWithIndex:index];
    }];
    
    [dialog showInView:self.view];
}

- (void)handleWithExpire:(int)index{
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:[GuessManager getExpireTitleWithMode:_mode] message:NSLS(@"kGuessGameExpire") style:CommonDialogStyleDoubleButtonWithCross];
    
    [dialog.oKButton setTitle:NSLS(@"kRestart") forState:UIControlStateNormal];
    [dialog.cancelButton setTitle:NSLS(@"kContestFeedDetail") forState:UIControlStateNormal];
    
    [dialog setClickOkBlock:^(id infoView){
        [self startNew];
    }];
    
    [dialog setClickCancelBlock:^(id infoView){
        [self gotoOpusDetailControllerWithIndex:index];
    }];
    
    [dialog showInView:self.view];
}

- (void)handleWithFail:(int)index{
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kGeniusGuessWrongTitle") message:NSLS(@"kGeniusGuessWrongMessage") style:CommonDialogStyleDoubleButtonWithCross];

    [dialog.oKButton setTitle:NSLS(@"kRestart") forState:UIControlStateNormal];
    [dialog.cancelButton setTitle:NSLS(@"kContestFeedDetail") forState:UIControlStateNormal];
    
    
    [dialog setClickOkBlock:^(id infoView){
        
        [self startNew];
    }];
    
    [dialog setClickCancelBlock:^(id infoView){
        
        [self gotoOpusDetailControllerWithIndex:index];
    }];
    
    [dialog showInView:self.view];
}

- (BOOL)isGuessIndexValid:(int)index{
    
    if (_mode == PBUserGuessModeGuessModeGenius) {
        return _guessIndex == index;
    }else{
        return YES;
    }
}

- (void)gotoOpusGuessControllerWithIndex:(int)index{
    
    PBOpus *pbOpus = [self.currentTab.dataList objectAtIndex:index];
    
    Opus *opus = [Opus opusWithPBOpus:pbOpus];
    DrawGuessController *vc = [[[DrawGuessController alloc] initWithOpus:opus mode:_mode contest:_contest] autorelease];
    vc.index = index;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoOpusDetailControllerWithIndex:(int)index{
    
    PBOpus *pbOpus = [self.currentTab.dataList objectAtIndex:index];
    
    DrawFeed *feed = [pbOpus toDrawFeed];
    UseItemScene *scene = [UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:feed];
    ShowFeedController *vc = [[[ShowFeedController alloc] initWithFeed:feed scene:scene] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didGuessCorrect:(Opus *)opus index:(int)index{
    
    _guessIndex ++;
    
    [self setIndexAsGuessed:index];
    int count = [self getGuessedCount];
    
    
    [self.dataTableView reloadData];
    
    if ([GuessManager canAwardNow:count mode:_mode]) {
        [self awardWithCount:count];
    }else{
        [self showTipsWithCount:count];
    }
}

- (void)didGuessWrong:(Opus *)opus index:(int)index{
    
    [GuessManager setGuessState:GuessStateFail mode:_mode contestId:_contest.contestId];
    [self stopCountDown];
    self.countDownLabel.text = NSLS(@"kGuessWrong");
    POSTMSG2(NSLS(@"kGuessWrong"), 3);
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
    
    [self hideActivity];
    
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
    [[AccountService defaultService] chargeCoin:award source:happyGuessAward];
    
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
    
    [[AccountService defaultService] chargeCoin:award source:geniusGuessAward];
    
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
    
    POSTMSG2(info, 2);
    
//    
//    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kHint") message:info style:CommonDialogStyleSingleButton];
//    [dialog.oKButton setTitle:NSLS(@"kIGotIt") forState:UIControlStateNormal];
//    [dialog showInView:self.view];
}


- (void)showTipInGeniusMode:(int)count{
    
    int predictAwardCoins = [GuessManager predictAwardCoins:count mode:_mode];
    int needToGuess = [GuessManager countNeedToGuessToAward:count mode:_mode];
    
    NSString *info = [NSString stringWithFormat:NSLS(@"kGuessGenuisModeTips"), count, needToGuess, predictAwardCoins];
    
    POSTMSG2(info, 2);

    
//    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kHint") message:info style:CommonDialogStyleDoubleButton];
//    [dialog.oKButton setTitle:NSLS(@"kGoOn") forState:UIControlStateNormal];
//    [dialog.cancelButton setTitle:NSLS(@"Back") forState:UIControlStateNormal];
//    
//    [dialog setClickCancelBlock:^(id infoView){
//        [self.navigationController popViewControllerAnimated:YES];
//    }];
//    
//    [dialog showInView:self.view];
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

- (void)clickBack{
    [self stopCountDown];
    [super clickBack:nil];
}

@end
