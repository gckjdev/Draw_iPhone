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
#import "CustomInfoView.h"

#define TABID 1
#define LIMIT 20

@interface GuessSelectController (){
    PBUserGuessMode _mode;
    BOOL _isRefreshData;
}
@property (retain, nonatomic) NSArray *opuses;
@property (retain, nonatomic) PBGuessContest *contest;

@end

@implementation GuessSelectController


- (void)dealloc{
    [_opuses release];
    [_titleView release];
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
    // Do any additional setup after loading the view from its nib.
    self.supportRefreshHeader = NO;
    if (_mode == PBUserGuessModeGuessModeContest
        || _mode == PBUserGuessModeGuessModeHappy) {
        self.supportRefreshFooter = NO;
        self.supportRefreshHeader = NO;
    }
    
    [self initTabButtons];
    [self clickTab:TABID];
    
    
    [_titleView setTarget:self];
    
    if (_mode == PBUserGuessModeGuessModeHappy) {
        [_titleView setTitle:NSLS(@"kHappGuessMode")];
        [_titleView setRightButtonTitle:NSLS(@"kRestart")];
        [_titleView setRightButtonSelctor:@selector(clickRestartButton:)];
    }else if(_mode == PBUserGuessModeGuessModeGenius){
        [_titleView setTitle:NSLS(@"kGeniusGuessMode")];
        [_titleView setRightButtonTitle:NSLS(@"kRestart")];
        [_titleView setRightButtonSelctor:@selector(clickRestartButton:)];
    }else if(_mode == PBUserGuessModeGuessModeContest){
        [_titleView setTitle:NSLS(@"kContestGuessMode")];
    }
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
        [cell setCurrentGuessIndex:[self guessIndex]];
    }
    return cell;
}


- (void)loadData:(int)offset limit:(int)limit startNew:(BOOL)startNew{
    
    [[GuessService defaultService] getOpusesWithMode:_mode
                                           contestId:_contest.contestId
                                              offset:offset
                                               limit:limit
                                          isStartNew:startNew
                                            delegate:self];
    
}

- (void)didGetOpuses:(NSArray *)opuses resultCode:(int)resultCode{
    
    PPDebug(@"count = %d", [opuses count]);
    if (resultCode == 0) {
        if (_isRefreshData) {
            _isRefreshData = NO;
            [self.currentTab.dataList removeAllObjects];
        }
        [self finishLoadDataForTabID:TABID resultList:opuses];
    }else{
        [self popupUnhappyMessage:NSLS(@"kLoadFailed") title:nil];
    }
}

- (void)didGetGuessRank:(PBGuessRank *)rank resultCode:(int)resultCode{
    if (resultCode == 0) {
    }else{
        [self popupUnhappyMessage:NSLS(@"kLoadFailed") title:nil];
    }
}

- (IBAction)clickRestartButton:(id)sender {
    
    NSArray *titles = @[NSLS(@"kOK"), NSLS(@"kCancel")];
    CustomInfoView *infoView = [CustomInfoView createWithTitle:NSLS(@"kHint") info:NSLS(@"kRestartGuessWarnning") hasCloseButton:NO buttonTitles:titles];
    [infoView setActionBlock:^(UIButton *button, UIView *view){
        if ([button titleForState:UIControlStateNormal] == NSLS(@"kOK")) {
            [self restart];
        }
        [infoView dismiss];
    }];
    
    [infoView showInView:self.view];
}

- (void)restart{
    [self loadData:0 limit:LIMIT startNew:YES];
    [self.currentTab.dataList removeAllObjects];
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
        }else if (pbOpus.guessInfo.isCorrect == NO && index == [self guessIndex]) {
            [self gotoOpusGuessController:pbOpus];
        }else{
            [self popupHappyMessage:NSLS(@"kGuessPreviousOpusFirst") title:nil];
        }
    }else{
        if (pbOpus.guessInfo.isCorrect == YES) {
            [self gotoOpusDetailController:pbOpus];
        }else {
            [self gotoOpusGuessController:pbOpus];
        }
    }
}

- (void)gotoOpusGuessController:(PBOpus *)pbOpus{
    Opus *opus = [Opus opusWithPBOpus:pbOpus];
    DrawGuessController *vc = [[[DrawGuessController alloc] initWithOpus:opus mode:_mode contest:_contest] autorelease];
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
    
    [self award];
}

- (void)didGuessWrong{
    
    if (_mode == PBUserGuessModeGuessModeGenius) {
        [self guessWrongInGenuisMode];
    }
}

- (void)guessWrongInGenuisMode{

    NSArray *titles = [NSArray arrayWithObjects:NSLS(@"kQuit"),
                       NSLS(@"kRestart"), nil];
    CustomInfoView *infoView = [CustomInfoView createWithTitle:NSLS(@"kGuessWrong")
                                                          info:NSLS(@"kGuessGenuisFail")
                                                hasCloseButton:NO
                                                  buttonTitles:titles];

    [infoView setActionBlock:^(UIButton *button, UIView *view){
        if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLS(@"kRestart")]) {
            [self clickRestartButton:nil];
            [infoView dismiss];
        }else{
            [self restart];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];

    [infoView showInView:self.view];
}

- (int)guessIndex{
    
    int index = 0;
    for (; index < [self.currentTab.dataList count]; index ++) {
        PBOpus *pbOpus = [self.currentTab.dataList objectAtIndex:index];
        if (pbOpus.guessInfo.isCorrect) {
            continue;
        }else{
            break;
        }
    }
    return index;
}

- (int)passCount{
    
    int count = 0;
    for (int index = 0; index < [self.currentTab.dataList count]; index++) {
        PBOpus *pbOpus = [self.currentTab.dataList objectAtIndex:index];
        if (pbOpus.guessInfo.isCorrect) {
            count++;
        }
    }
    return count;
}

- (void)award{
    
    [self refreshData];
    
    int count = [self passCount] + 1;
    
    if (_mode == PBUserGuessModeGuessModeHappy) {
        
        if (count % 10 == 0) {
            int award = [ConfigManager getAwardInHappyMode];
            [self awardInHappyMode:count award:award];
        }else{
            [self showTipInHappyMode:count];
        }
        
    }else if (_mode == PBUserGuessModeGuessModeGenius){
        
        int award = (count - 10) / 10 * 100 + 1000;
        if (count % 10 == 0) {
            [self awardInGeniusMode:count award:award];
        }else{
            [self showTipInGeniusMode:count award:(int)award];
        }
        
    }else if (_mode == PBUserGuessModeGuessModeContest){
        
        if (count == 20) {
            PPDebug(NSLS(@"kCompleteGuessContest"));
        }else{
//            [self showTipOnContestMode];
        }
    }
}

- (void)awardInHappyMode:(int)passCount award:(int)award{
    
    // chage account
    [[AccountService defaultService] chargeCoin:award source:AwardCoinType];
    
    // tip
    NSArray *titles = [NSArray arrayWithObjects:NSLS(@"kQuit"), NSLS(@"kGoOn"), nil];
    NSString *info = [NSString stringWithFormat:NSLS(@"kGuessHappyModeAwardTips"), passCount, award];
    
    CustomInfoView *infoView = [CustomInfoView createWithTitle:NSLS(@"kAward")
                                                          info:info
                                                hasCloseButton:NO
                                                  buttonTitles:titles];
    
    [infoView setActionBlock:^(UIButton *button, UIView *view){
        if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLS(@"kGoOn")]) {
            if (passCount >= 20) {
                [self loadData:0 limit:LIMIT startNew:YES];
                [self.currentTab.dataList removeAllObjects];
            }
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        [infoView dismiss];
    }];
    
    [infoView showInView:self.view];
}

- (void)awardInGeniusMode:(int)passCount
                    award:(int)award{
    
    [[AccountService defaultService] chargeCoin:award source:AwardCoinType];
    
    NSString *info = [NSString stringWithFormat:NSLS(@"kGuessGenuisModeAwardTips"), passCount,award];    
    NSArray *titles = [NSArray arrayWithObjects:NSLS(@"kQuit"), NSLS(@"kGoOn"), nil];
    CustomInfoView *infoView = [CustomInfoView createWithTitle:NSLS(@"kAward")
                                                          info:info
                                                hasCloseButton:NO
                                                  buttonTitles:titles];
    
    [infoView setActionBlock:^(UIButton *button, UIView *view){
        if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLS(@"kQuit")]) {
            [self.navigationController popViewControllerAnimated:YES];

        }
        [infoView dismiss];
    }];
    
    [infoView showInView:self.view];
}

- (void)showTipInHappyMode:(int)count{
    
    NSArray *titles = [NSArray arrayWithObjects:NSLS(@"kIGotIt"), nil];
    NSString *info = [NSString stringWithFormat:NSLS(@"kGuessHappyModeTips"), count, 10 - count%10, [ConfigManager getAwardInHappyMode]];
    CustomInfoView *infoView = [CustomInfoView createWithTitle:NSLS(@"kHint")
                                                          info:info
                                                hasCloseButton:NO
                                                  buttonTitles:titles];
    
    [infoView setActionBlock:^(UIButton *button, UIView *view){
        [infoView dismiss];
    }];
    
    [infoView showInView:self.view];
}


- (void)showTipInGeniusMode:(int)passCount award:(int)award{
    
    NSArray *titles = [NSArray arrayWithObjects:NSLS(@"kIGotIt"), nil];
    NSString *info = [NSString stringWithFormat:NSLS(@"kGuessGenuisModeTips"), passCount, 10 - passCount%10, award];
    CustomInfoView *infoView = [CustomInfoView createWithTitle:NSLS(@"kHint")
                                                          info:info
                                                hasCloseButton:NO
                                                  buttonTitles:titles];
    
    [infoView setActionBlock:^(UIButton *button, UIView *view){
        [infoView dismiss];
    }];
    
    [infoView showInView:self.view];
}

- (void)refreshData{
    
    int count = [self.currentTab.dataList count];
    [self loadData:0 limit:count startNew:NO];
    _isRefreshData = YES;
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index{
    return NSLS(@"kNoData");
}

@end
