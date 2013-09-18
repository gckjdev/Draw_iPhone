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
#define OPUS_COUNT_PER_TIME 20

@interface GuessSelectController (){
    PBUserGuessMode _mode;
    int _countDown;
    BOOL _firstLoad;
    BOOL _pop;
}
@property (retain, nonatomic) NSMutableDictionary *guessInfoDic;    // 每幅作品是否被猜过的信息。

@property (retain, nonatomic) PBGuessContest *contest;
@property (assign, nonatomic) int guessIndex;  // 表示当前合法的猜的关卡，仅对天才模式有用，因为天才模式需要一关关闯关，对于其他两种模式，这个值为-1。当这个值为-1时，表示当前合法的猜的关卡是任意的。
@end

@implementation GuessSelectController


- (void)dealloc{
    [_contest release];
    [_countDownLabel release];
    [_guessInfoDic release];
    PPRelease(_shareAction);
    [super dealloc];
}


- (id)initWithMode:(PBUserGuessMode)mode contest:(PBGuessContest *)contest{
    
    if (self  = [super init]) {
        _mode = mode;
        self.contest = contest;
        
        self.guessInfoDic = [NSMutableDictionary dictionary];
        _firstLoad = YES;
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
    
    self.countDownLabel.textColor = COLOR_GREEN;
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
        self.countDownLabel.text = NSLS(@"kContestPassed");
    }else{
        self.countDownLabel.hidden = YES;
    }
}

- (void)startCountDown{
    
    [self stopCountDown];
    
    _countDown = [GuessManager getTimeIntervalUtilExpire:_mode contest:_contest];
    if (_countDown > 0) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountDownInfo) userInfo:nil repeats:YES];
    }else{
        [self changeGuessState:GuessStateExpire];
    }
}

- (void)stopCountDown{
    
    [self.timer invalidate];
    self.timer = nil;
}

- (void)updateCountDownInfo{
    
    _countDown --;
    
    if (_countDown <= 0) {
        [self changeGuessState:GuessStateExpire];
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
    
    TableTab *tab = [_tabManager tabForID:tabID];
    
    
    if(_firstLoad && _mode == PBUserGuessModeGuessModeGenius){

        int guessIndex = [GuessManager getGeniusGuessIndex];
        int limit = (guessIndex / OPUS_COUNT_PER_TIME + 1) * OPUS_COUNT_PER_TIME;
        tab.limit = limit;
        [self loadData:self.currentTab.offset limit:limit startNew:NO];

    }else{
        tab.limit = LIMIT;
        [self loadData:self.currentTab.offset limit:LIMIT startNew:NO];
    }

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
    
    
    if ([GuessManager getGuessStateWithMode:_mode contestId:_contest.contestId] == GuessStateBeing
        || [GuessManager getGuessStateWithMode:_mode contestId:_contest.contestId] == GuessStateNotStart) {
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
        self.guessIndex = [GuessManager getGuessIndexWithMode:_mode guessList:self.currentTab.dataList];
        
        if(_firstLoad && _mode == PBUserGuessModeGuessModeGenius){
            _firstLoad = NO;
            NSInteger row = [self tableView:self.dataTableView numberOfRowsInSection:0];
            if (row!=0) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:(row-1) inSection:0];
                [self.dataTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
        
    }else{
       POSTMSG2(NSLS(@"kLoadFailed"), 3);
    }
}

- (void)setGuessIndex:(int)guessIndex{
    
    _guessIndex = guessIndex;
    
    if (_mode == PBUserGuessModeGuessModeGenius) {
        [GuessManager saveGeniusGuessIndex:_guessIndex];
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
    _pop = NO;
    [[GuessService defaultService] getGuessRankWithType:0
                                                   mode:_mode
                                              contestId:_contest.contestId
                                               delegate:self];
}

- (void)startNew{
    
    if (_mode == PBUserGuessModeGuessModeContest) {
        return;
    }
    
    [self changeGuessState:GuessStateNotStart];
    
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
//        if ([self isGuessIndexValid:index]) {
            [self handleIndexThatNotGuessed:index];
//        }else{
//            POSTMSG2(NSLS(@"kGuessPreviousOpusFirst"), 3);
//        }
    }
}


- (void)handleIndexThatNotGuessed:(int)index{
    
    GuessState state = [GuessManager getGuessStateWithMode:_mode contestId:_contest.contestId];
    switch (state) {
        case GuessStateNotStart:
            [self handleWithNotStart:index];
            break;
            
        case GuessStateBeing:
            if ([self isGuessIndexValid:index]) {
                [self gotoOpusGuessControllerWithIndex:index];
            }else{
                POSTMSG2(NSLS(@"kGuessPreviousOpusFirst"), 3);
            }
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
    
    [dialog.oKButton setTitle:NSLS(@"kStart") forState:UIControlStateNormal];
    
    [dialog setClickOkBlock:^(id infoView){
        
        [self changeGuessState:GuessStateBeing];
        POSTMSG2([GuessManager getDeductCoinsPopMessageWithMode:_mode], 3);
        [self gotoOpusGuessControllerWithIndex:index];
    }];
    
    [dialog showInView:self.view];
}

- (void)handleWithExpire:(int)index{
        
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:[GuessManager getExpireTitleWithMode:_mode] message:[GuessManager getExpireMessageWithMode:_mode] style:CommonDialogStyleDoubleButtonWithCross];

    if (_mode != PBUserGuessModeGuessModeContest) {
        [dialog.oKButton setTitle:NSLS(@"kRestart") forState:UIControlStateNormal];
    }
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
    
    self.guessIndex ++;
    
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
    
    [self changeGuessState:GuessStateFail];
    POSTMSG2(NSLS(@"kGuessWrong"), 3);
}

- (void)changeGuessState:(GuessState)state{
    
    [GuessManager setGuessState:state mode:_mode contestId:_contest.contestId];

    switch (state) {
        case GuessStateNotStart:
            [self stopCountDown];
            self.countDownLabel.hidden = YES;
            
            break;
            
        case GuessStateBeing:
            self.countDownLabel.hidden = NO;
            [GuessManager setLastGuessDateDate:_mode];
            [GuessManager deductCoins:_mode contestId:_contest.contestId];
            [self startCountDown];
            
            break;
            
        case GuessStateExpire:
            [self stopCountDown];
            self.countDownLabel.hidden = NO;
            self.countDownLabel.text = NSLS(@"kTimeout");
            
        case GuessStateFail:
            [self stopCountDown];
            self.countDownLabel.hidden = NO;
            self.countDownLabel.text = NSLS(@"kContestPassed");
            
        default:
            break;
    }
    

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
        _pop = YES;
        [[GuessService defaultService] getGuessRankWithType:0 mode:PBUserGuessModeGuessModeContest contestId:_contest.contestId delegate:self];
    }
}

- (void)didGetGuessRank:(PBGuessRank *)rank resultCode:(int)resultCode{
    
    [self hideActivity];
    
    if (resultCode == 0) {
        
//        if ([GuessManager countNeedToGuessToAward:rank.pass mode:_mode] == 0) {
//            [self showTipInContestModeWhenContestOver:rank];
//        }else{
            [self showTipInContestMode:rank];
//        }
    }
}

- (void)awardInHappyMode:(int)passCount
                   award:(int)award{
    
    // chage account
    [[AccountService defaultService] chargeCoin:award source:happyGuessAward];
    
    // tip
    NSString *info = [NSString stringWithFormat:NSLS(@"kGuessHappyModeAwardTips"), passCount, award];
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kAward") message:info style:CommonDialogStyleSingleButton];
    [dialog.oKButton setTitle:NSLS(@"kGoOn") forState:UIControlStateNormal];
//    [dialog.cancelButton setTitle:NSLS(@"kQuit") forState:UIControlStateNormal];
    
    [dialog setClickOkBlock:^(UILabel *label){
        if (passCount >= OPUS_COUNT_PER_TIME) {
            [self startNew];
        }
    }];
    
    [dialog setClickCancelBlock:^(NSString *inputStr){
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [dialog showInView:self.view];
}

- (void)clickShareAction:(int)passCount view:(UIView*)view
{
    
    PPDebug(@"clickShareAction");
    
    if (_shareAction == nil) {
        _shareAction = [[CommonShareAction alloc] initWithOpus:nil];
    }
    
    NSString* string = [ConfigManager guessContestShareTitleText];
    NSString* shareText = [NSString stringWithFormat:string, passCount, [GuessService geniusTitle:passCount]];
    [_shareAction popActionTags:@[@(ShareActionTagSinaWeibo), @(ShareActionTagWxTimeline)]
                      shareText:shareText viewController:self
                         onView:[CommonTitleView titleView:self.view]
          allowClickMaskDismiss:NO];
}

- (void)awardInGeniusMode:(int)passCount
                    award:(int)award{
    
    [[AccountService defaultService] chargeCoin:award source:geniusGuessAward];
    
    NSString *info = [NSString stringWithFormat:NSLS(@"kGuessGenuisModeAwardTips"), passCount,award, [GuessService geniusTitle:passCount]];
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kAward") message:info style:CommonDialogStyleDoubleButton];
    [dialog.oKButton setTitle:NSLS(@"kGoOn") forState:UIControlStateNormal];
    [dialog.cancelButton setTitle:NSLS(@"kGoShare") forState:UIControlStateNormal];
    
    [dialog setClickCancelBlock:^(NSString *inputStr){
        [self clickShareAction:passCount view:dialog];
    }];
    
    [dialog showInView:self.view];
}

- (void)showTipInHappyMode:(int)count{
    
    int predictAwardCoins = [GuessManager predictAwardCoins:count mode:_mode];
    int needToGuess = [GuessManager countNeedToGuessToAward:count mode:_mode];
    
    NSString *info = [NSString stringWithFormat:NSLS(@"kGuessHappyModeTips"), count, needToGuess, predictAwardCoins];
    
    POSTMSG2(info, 3);
}


- (void)showTipInGeniusMode:(int)count{
    
    int predictAwardCoins = [GuessManager predictAwardCoins:count mode:_mode];
    int needToGuess = [GuessManager countNeedToGuessToAward:count mode:_mode];
    
    NSString *info = [NSString stringWithFormat:NSLS(@"kGuessGenuisModeTips"), count, needToGuess, predictAwardCoins];
    
    POSTMSG2(info, 3);
}

- (void)showTipInContestMode:(PBGuessRank *)rank{
    
    
    if (_pop) {
        
        NSString *tip = [NSString stringWithFormat:NSLS(@"kGuessContestModeTipsMessage"), rank.ranking, rank.pass, rank.spendTime];
        
        POSTMSG2(tip, 3);
        
    }else{
        ContestRankView *v = [ContestRankView createViewWithTitle:NSLS(@"kGuessContestModeTips") rank:rank];

        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kGuessContestModeTips") customView:v style:CommonDialogStyleSingleButton];
        [dialog.oKButton setTitle:NSLS(@"kIGotIt") forState:UIControlStateNormal];
        [dialog showInView:self.view];
    }
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
