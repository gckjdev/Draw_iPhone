//
//  GuessRankListController.m
//  Draw
//
//  Created by 王 小涛 on 13-7-24.
//
//

#import "GuessRankListController.h"
#import "GuessRankCell.h"
#import "KxMenu.h"
#import "TimeUtils.h"
#import "Opus.pb.h"
#import "ShareImageManager.h"
#import "GuessManager.h"
#import "PPPopTableView.h"
#import "ViewUserDetail.h"
#import "UserDetailViewController.h"
#import "ConfigManager.h"

#define GENIUS_DAY NSLS(@"kGeniusRankDay")
#define GENIUS_WEEK NSLS(@"kGeniusRankWeek")
#define GENIUS_YEAR NSLS(@"kGeniusRankYear")

#define CONTEST_TODAY NSLS(@"kContestRankToday")
#define CONTEST_YESTODAY NSLS(@"kContestRankYesterday")
#define CONTEST_BEFOREYESTODAY NSLS(@"kContestRankBeforeYesterday")
#define CONTEST_THREE_DAYS_AGO NSLS(@"kContestRankThreeDaysAgo")
#define CONTEST_FOUR_DAYS_AGO NSLS(@"kContestRankFourDaysAgo")
#define CONTEST_FIVE_DAYS_AGO NSLS(@"kContestRankFiveDaysAgo")
#define CONTEST_SIX_DAYS_AGO NSLS(@"kContestRankSixDaysAgo")

#define RANK_DAY NSLS(@"kDay")
#define RANK_WEEK NSLS(@"kWeek")                                // not used yet
#define RANK_YEAR NSLS(@"kYear")

#define TODAY NSLS(@"kToday")
#define YESTERDAY NSLS(@"kYesterday")
#define BEFOREYESTERDAY NSLS(@"kBeforeYesterday")
#define THREEDAYSAGO NSLS(@"kThreeDaysAgo")
#define FOURDAYSAGO NSLS(@"kFourDaysAgo")
#define FIVEDAYSAGO NSLS(@"kFiveDaysAgo")
#define SIXDAYSAGO NSLS(@"kSixDaysAgo")

typedef enum{
    TabTypeGeniusHot = 50,
    TabTypeGeniusAllTime,
    
    TabTypeContestToday = 100,
    TabTypeContestYestoday,
    TabTypeContestBeforeYestoday,
    TabTypeContestThreeDaysAgo,
    TabTypeContestFourDaysAgo,
    TabTypeContestFiveDaysAgo,
    TabTypeContestSixDaysAgo,
}TabType;

//static NSArray * gContestSelectList = @[TODAY, YESTERDAY, BEFOREYESTERDAY, THREEDAYSAGO, FOURDAYSAGO, FIVEDAYSAGO, SIXDAYSAGO, SEVENDAYSAGO];




@interface GuessRankListController ()

@property (retain, nonatomic) NSArray *contests;
@property (copy, nonatomic) NSString *currentSelect;
@property (retain, nonatomic) PPPopTableView *popView;

@property (retain, nonatomic) NSArray *contestDayList;
@property (retain, nonatomic) NSArray *contestTitleList;
@property (retain, nonatomic) NSArray *geniusRankTypeList;
@property (retain, nonatomic) NSArray *geniusTitleList;

//@property (retain, nonatomic) NSArray *geniusTabTypeList;
//@property (retain, nonatomic) NSArray *contestTabTypeList;
@end

@implementation GuessRankListController

- (void)dealloc{
    
    [_geniusButton release];
    [_contestButton release];
    [_contests release];
    [_currentSelect release];
    [_popView release];
    [_contestDayList release];
    [_contestTitleList release];
    [_geniusRankTypeList release];
    [_geniusTitleList release];
//    [_geniusTabTypeList release];
//    [_contestTabTypeList release];
    [super dealloc];
}

- (void)viewDidLoad
{
    self.contestDayList = @[TODAY, YESTERDAY, BEFOREYESTERDAY, THREEDAYSAGO, FOURDAYSAGO, FIVEDAYSAGO, SIXDAYSAGO];
    self.contestTitleList = @[CONTEST_TODAY, CONTEST_YESTODAY, CONTEST_BEFOREYESTODAY, CONTEST_THREE_DAYS_AGO, CONTEST_FOUR_DAYS_AGO, CONTEST_FIVE_DAYS_AGO, CONTEST_SIX_DAYS_AGO];
    
    self.geniusRankTypeList = @[RANK_DAY, RANK_YEAR];
    self.geniusTitleList = @[GENIUS_DAY, GENIUS_YEAR];
    
    [super viewDidLoad];
    
    [self.titleView setTitle:NSLS(@"kGuessRank")];
    [self.titleView setTarget:self];
    [self.titleView setRightButtonAsRefresh];
    [self.titleView setRightButtonSelector:@selector(clickRefreshButton:)];

    [self initTabButtons];
    
    _geniusButton.backgroundColor = COLOR_ORANGE;
    _contestButton.backgroundColor = COLOR_ORANGE;
    
    [[GuessService defaultService] getRecentGuessContestListWithDelegate:self];
    
    // set tab title
    [self.geniusButton setTitle:GENIUS_DAY forState:UIControlStateNormal];
    [self.contestButton setTitle:CONTEST_TODAY forState:UIControlStateNormal];
}

- (void)viewDidUnload {
    
    [self setGeniusButton:nil];
    [self setContestButton:nil];
    [self setTitleView:nil];
    [super viewDidUnload];
}

- (void)setCurrentSelect:(NSString *)currentSelect{
    [_currentSelect release];
    _currentSelect = nil;
    _currentSelect = [currentSelect copy];
    
    int index = [_geniusRankTypeList indexOfObject:_currentSelect];
    if (index != NSNotFound) {
        [_geniusButton setBackgroundColor:COLOR_ORANGE1];
        [_contestButton setBackgroundColor:COLOR_ORANGE];
        [_geniusButton setTitle:[_geniusTitleList objectAtIndex:index] forState:UIControlStateNormal];
        [self clickTab:(index + TabTypeGeniusHot)];
        return;
    }
    
    index = [_contestDayList indexOfObject:_currentSelect];
    if (index != NSNotFound) {

        [_geniusButton setBackgroundColor:COLOR_ORANGE];
        [_contestButton setBackgroundColor:COLOR_ORANGE1];
        [_contestButton setTitle:[_contestTitleList objectAtIndex:index] forState:UIControlStateNormal];
        [self clickTab:(index + TabTypeContestToday)];
    }
}

- (IBAction)clickGeniusSelectButton:(UIButton *)sender {
    
    __block typeof (self)bself = self;
    
    self.popView = [PPPopTableView popTableViewWithTitles:_geniusRankTypeList icons:nil selectedHandler:^(NSInteger row) {
        
        bself.currentSelect = [_geniusRankTypeList objectAtIndex:row];
    }];
    
    [_popView showInView:self.view atView:sender animated:YES];
}

- (IBAction)clickGeniusButton:(UIButton *)sender {
    
    NSString *title = [sender titleForState:UIControlStateNormal];
    int index = [_geniusTitleList indexOfObject:title];
    
    if (index != NSNotFound) {
        self.currentSelect = [_geniusRankTypeList objectAtIndex:index];
    }
}

- (IBAction)clickContestSelectButton:(UIButton *)sender {
    
    if ([_contests count] == 0) {
        return;
    }

    __block typeof(self) bself = self;
    
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int i=0; i < [_contests count] && i < [_contestDayList count]; i++ ) {
        [arr addObject:[_contestDayList objectAtIndex:i]];
    }
    
    
    self.popView = [PPPopTableView popTableViewWithTitles:arr icons:nil selectedHandler:^(NSInteger row) {
        
        bself.currentSelect = [arr objectAtIndex:row];
    }];
    
    [_popView showInView:self.view atView:sender animated:YES];
}

- (IBAction)clickContestButton:(id)sender {
    
    NSString *title = [sender titleForState:UIControlStateNormal];
    
    int index = [_contestTitleList indexOfObject:title];
    if (index != NSNotFound) {
        self.currentSelect = [_contestDayList objectAtIndex:index];
    }
}

- (void) pushMenuItem:(KxMenuItem *)item
{
    self.currentSelect = item.title;
}

- (void)didGetGuessRankList:(NSArray *)list resultCode:(int)resultCode{
    
    [self hideActivity];
    if (resultCode == 0) {
        PPDebug(@"list count = %d", [list count]);
        [self finishLoadDataForTabID:self.currentTab.tabID resultList:list];
    }else{
        [self failLoadDataForTabID:self.currentTab.tabID];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [GuessRankCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GuessRankCell *cell = [tableView dequeueReusableCellWithIdentifier:[GuessRankCell getCellIdentifier]];
    if (cell == nil) {
        cell = [GuessRankCell createCell:nil];
    }
    
    PBGuessRank *rank = [self.currentTab.dataList objectAtIndex:indexPath.row];
    [cell setCellInfo:rank];
    [cell setDelegate:self];
    
    
    if ([self.currentSelect isEqualToString:TODAY] &&
        ![GuessManager isContestOver:[_contests objectAtIndex:0]]) {
        [cell hideAwardInfo];
    }
    
    if (!([self.currentSelect isEqualToString:RANK_DAY]
         || [self.currentSelect isEqualToString:RANK_YEAR])) {
        cell.geniusTitleLabel.hidden = YES;
    }
    
    return cell;
}

SET_CELL_BG_IN_CONTROLLER;


#pragma mark - CommonTabController delegate
- (NSInteger)tabCount{
    
    int count = [_geniusTitleList count] + [_contestTitleList count];
    return count;
}

- (NSInteger)currentTabIndex{
    return 0;
}

- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index{
    return [ConfigManager getGuessRankListCountLoadedAtOnce];
}



- (NSInteger)tabIDforIndex:(NSInteger)index{
    
    NSInteger tabId[] = {TabTypeGeniusHot, TabTypeGeniusAllTime, TabTypeContestToday,
    TabTypeContestYestoday, TabTypeContestBeforeYestoday, TabTypeContestThreeDaysAgo, TabTypeContestFourDaysAgo, TabTypeContestFiveDaysAgo, TabTypeContestSixDaysAgo};
    
    return tabId[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index{
    return nil;
}


- (int)getRankTypeWithTabID:(int)tabID{
    
    if(tabID == TabTypeGeniusHot){
        return HOT_RANK;
    }else{
        return ALL_TIME_RANK;
    }
}

- (NSString *)getContestIdByTabID:(int)tabID{
    
    int index = tabID-TabTypeContestToday;
    if (index < [_contests count]) {
        return[[_contests objectAtIndex:index] contestId];
    }
    
    return nil;
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID{
    
    TableTab *tab = [_tabManager tabForID:tabID];
    NSString *contestId = nil;
    [self showActivityWithText:NSLS(@"kLoading")];
    switch (tabID) {
        case TabTypeGeniusHot:
        case TabTypeGeniusAllTime:
            [[GuessService defaultService] getGuessRankListWithType:[self getRankTypeWithTabID:tabID] mode:PBUserGuessModeGuessModeGenius contestId:nil offset:tab.offset limit:tab.limit delegate:self];
            break;
            
        case TabTypeContestToday:
        case TabTypeContestYestoday:
        case TabTypeContestBeforeYestoday:
        case TabTypeContestThreeDaysAgo:
        case TabTypeContestFourDaysAgo:
        case TabTypeContestFiveDaysAgo:
        case TabTypeContestSixDaysAgo:
            
            contestId = [self getContestIdByTabID:tabID];
            [[GuessService defaultService] getGuessRankListWithType:0 mode:PBUserGuessModeGuessModeContest contestId:contestId offset:tab.offset limit:tab.limit delegate:self];
            break;
            
        default:
            [self hideActivity];
            break;
    }
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index{
    
    return NSLS(@"kNoRank");
}


- (void)didGetGuessContestList:(NSArray *)list resultCode:(int)resultCode{
    
    if (resultCode == 0) {
        self.contests = list;
        PBGuessContest *contest = [_contests objectAtIndex:0];
        if ([GuessManager isContestBeing:contest]) {
            self.currentSelect = TODAY;
        }else{
            self.currentSelect = RANK_DAY;
        }
    }else{
        POSTMSG(NSLS(@"kLoadFailed"));        
    }
}

- (void)didClickAvatar:(PBGuessRank *)rank{

    ViewUserDetail *detail = [ViewUserDetail viewUserDetailWithUserId:rank.user.userId
                                                               avatar:rank.user.avatar
                                                             nickName:rank.user.nickName];
    [UserDetailViewController presentUserDetail:detail
                               inViewController:self];
}


@end
