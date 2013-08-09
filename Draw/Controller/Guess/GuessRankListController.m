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


#define GENIUS_WEEK NSLS(@"kGeniusRankWeek")
#define GENIUS_YEAR NSLS(@"kGeniusRankYear")
#define CONTEST_TODAY NSLS(@"kContestRankToday")
#define CONTEST_YESTODAY NSLS(@"kContestRankYesterday")
#define CONTEST_BEFOREYESTODAY NSLS(@"kContestRankBeforeYesterday")

#define WEEK NSLS(@"kWeek")
#define YEAR NSLS(@"kYear")
#define TODAY NSLS(@"kToday")
#define YESTERDAY NSLS(@"kYesterday")
#define BEFOREYESTERDAY NSLS(@"kBeforeYesterday")


@interface GuessRankListController ()

@property (retain, nonatomic) NSArray *contests;
@property (copy, nonatomic) NSString *currentSelect;

@end

@implementation GuessRankListController

- (void)dealloc{
    
    [_geniusButton release];
    [_contestButton release];
    [_titleView release];
    [_contests release];
    [_currentSelect release];
    [super dealloc];
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    
    [_titleView setTitle:NSLS(@"kGuessRank")];
    [_titleView setTarget:self];

    [self initTabButtons];
    
    [[GuessService defaultService] getRecentGuessContestListWithDelegate:self];
    
    [_geniusButton setBackgroundColor:COLOR_ORANGE];
    [_contestButton setBackgroundColor:COLOR_ORANGE];
    
    self.currentSelect = WEEK;
    [_contestButton setTitle:CONTEST_TODAY forState:UIControlStateNormal];
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
    
    if ([_currentSelect isEqualToString:WEEK]) {
        [_geniusButton setTitle:GENIUS_WEEK forState:UIControlStateNormal];
        [self clickTab:TabTypeGeniusHot];
    }else if ([_currentSelect isEqualToString:YEAR]) {
        [_geniusButton setTitle:GENIUS_YEAR forState:UIControlStateNormal];
        [self clickTab:TabTypeGeniusAllTime];
    }else if ([_currentSelect isEqualToString:TODAY]) {
        [_contestButton setTitle:CONTEST_TODAY forState:UIControlStateNormal];
        [self clickTab:TabTypeContestToday];
    }else if ([_currentSelect isEqualToString:YESTERDAY]) {
        [_contestButton setTitle:CONTEST_YESTODAY forState:UIControlStateNormal];
        [self clickTab:TabTypeContestYestoday];
    }else if ([_currentSelect isEqualToString:BEFOREYESTERDAY]) {
        [_contestButton setTitle:CONTEST_BEFOREYESTODAY forState:UIControlStateNormal];
        [self clickTab:TabTypeContestBeforeYestoday];
    }
}

- (IBAction)clickGeniusSelectButton:(UIButton *)sender {
    
    // TODO: set pull down list to select
    
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:WEEK
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:YEAR
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)]
      ];
    
    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}

- (IBAction)clickGeniusButton:(UIButton *)sender {

    if ([[sender titleForState:UIControlStateNormal] isEqualToString:GENIUS_WEEK]) {
        self.currentSelect = WEEK;
    }else{
        self.currentSelect = YEAR;
    }
}

- (IBAction)clickContestSelectButton:(UIButton *)sender {
    
    // TODO: set pull down list to select
    
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:TODAY
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:YESTERDAY
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:BEFOREYESTERDAY
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)]
      ];
    
    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}

- (IBAction)clickContestButton:(id)sender {
    
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:CONTEST_TODAY]) {
        self.currentSelect = TODAY;
    }else if ([[sender titleForState:UIControlStateNormal] isEqualToString:CONTEST_YESTODAY]){
        self.currentSelect = YESTERDAY;
    }else if ([[sender titleForState:UIControlStateNormal] isEqualToString:CONTEST_BEFOREYESTODAY]){
        self.currentSelect = BEFOREYESTERDAY;
    }
}

- (void) pushMenuItem:(KxMenuItem *)item
{
    self.currentSelect = item.title;
}

- (void)didGetGuessRankList:(NSArray *)list resultCode:(int)resultCode{
    
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
    
    return cell;
}

SET_CELL_BG


#pragma mark - CommonTabController delegate
- (NSInteger)tabCount{
    return 5;
}

- (NSInteger)currentTabIndex{
    return 0;
}

- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index{
    return 20;
}

typedef enum{
    TabTypeGeniusHot = 100,
    TabTypeGeniusAllTime = 101,
    TabTypeContestToday = 102,
    TabTypeContestYestoday = 103,
    TabTypeContestBeforeYestoday = 104,
}TabType;

- (NSInteger)tabIDforIndex:(NSInteger)index{
    
    NSInteger tabId[] = {TabTypeGeniusHot, TabTypeGeniusAllTime, TabTypeContestToday,
    TabTypeContestYestoday, TabTypeContestBeforeYestoday};
    
    return tabId[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index{
    return nil;
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID{
    
    TableTab *tab = [_tabManager tabForID:tabID];
    NSString *contestId = nil;
    
    switch (tabID) {
        case TabTypeGeniusHot:
            [[GuessService defaultService] getGuessRankListWithType:HOT_RANK mode:PBUserGuessModeGuessModeGenius contestId:nil offset:tab.offset limit:tab.limit delegate:self];
            break;
            
        case TabTypeGeniusAllTime:
            [[GuessService defaultService] getGuessRankListWithType:ALL_TIME_RANK mode:PBUserGuessModeGuessModeGenius contestId:nil offset:tab.offset limit:tab.limit delegate:self];
            break;
            
        case TabTypeContestToday:
            contestId = [[_contests objectAtIndex:0] contestId];
            [[GuessService defaultService] getGuessRankListWithType:0 mode:PBUserGuessModeGuessModeContest contestId:contestId offset:tab.offset limit:tab.limit delegate:self];
            break;
            
        case TabTypeContestYestoday:
            contestId = [[_contests objectAtIndex:1] contestId];
            [[GuessService defaultService] getGuessRankListWithType:0 mode:PBUserGuessModeGuessModeContest contestId:contestId offset:tab.offset limit:tab.limit delegate:self];
            break;
            
        case TabTypeContestBeforeYestoday:
            contestId = [[_contests objectAtIndex:2] contestId];
            [[GuessService defaultService] getGuessRankListWithType:0 mode:PBUserGuessModeGuessModeContest contestId:contestId offset:tab.offset limit:tab.limit delegate:self];
            break;
            
        default:
            break;
    }
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index{
    
    return NSLS(@"kNoData");
}


- (void)didGetGuessContestList:(NSArray *)list resultCode:(int)resultCode{
    
    if (resultCode == 0) {
        self.contests = list;
    }else{
        [self popupHappyMessage:NSLS(@"kLoadFailed") title:nil];
    }
}


@end
