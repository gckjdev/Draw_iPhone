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

@interface GuessRankListController ()

@property (retain, nonatomic) NSArray *contests;

@end

@implementation GuessRankListController

- (void)dealloc{
    
    [[GuessService defaultService] setDelegate:nil];
    [_geniusButton release];
    [_contestButton release];
    [_titleView release];
    [_contests release];
    [super dealloc];
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    
    [_titleView setTitle:NSLS(@"kGuessRank")];
    [_titleView setTarget:self];

    [self initTabButtons];
    
    [self clickTab:TabTypeGeniusHot];
    [[GuessService defaultService] getRecentGuessContestList];
    [[GuessService defaultService] setDelegate:self];
}

- (void)viewDidUnload {
    [self setGeniusButton:nil];
    [self setContestButton:nil];
    [self setTitleView:nil];
    [super viewDidUnload];
}

#define GENIUS_WEEK NSLS(@"kWeek")
#define GENIUS_YEAR NSLS(@"kYear")
#define CONTEST_TODAY NSLS(@"kToday")
#define CONTEST_YESTODAY NSLS(@"kYestoday")
#define CONTEST_BEFOREYESTODAY NSLS(@"kBeforeYestoday")

- (IBAction)clickGeniusButton:(UIButton *)sender {
    
    // TODO: set pull down list to select
        
    NSArray *menuItems =
    @[

        [KxMenuItem menuItem:GENIUS_WEEK
                       image:nil
                      target:self
                      action:@selector(pushMenuItem:)],

        [KxMenuItem menuItem:GENIUS_YEAR
                       image:nil
                      target:self
                      action:@selector(pushMenuItem:)]
    ];

    [KxMenu showMenuInView:self.view
    fromRect:sender.frame
    menuItems:menuItems];

}

- (IBAction)clickContestButton:(UIButton *)sender {
    
    // TODO: set pull down list to select
    
    NSArray *menuItems =
    @[
        [KxMenuItem menuItem:CONTEST_TODAY
                       image:nil
                      target:self
                      action:@selector(pushMenuItem:)],

        [KxMenuItem menuItem:CONTEST_YESTODAY
                       image:nil
                      target:self
                      action:@selector(pushMenuItem:)],

        [KxMenuItem menuItem:CONTEST_BEFOREYESTODAY
                       image:nil
                      target:self
                      action:@selector(pushMenuItem:)]
    ];

    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}
      
- (void) pushMenuItem:(KxMenuItem *)item
{
    if ([item.title isEqualToString:GENIUS_WEEK]) {
        [_geniusButton setTitle:item.title forState:UIControlStateNormal];
        [self clickTab:TabTypeGeniusHot];
    }else if ([item.title isEqualToString:GENIUS_YEAR]) {
        [_geniusButton setTitle:item.title forState:UIControlStateNormal];
        [self clickTab:TabTypeGeniusAllTime];
    }else if ([item.title isEqualToString:CONTEST_TODAY]) {
        [_contestButton setTitle:item.title forState:UIControlStateNormal];
        [self clickTab:TabTypeContestToday];
    }else if ([item.title isEqualToString:CONTEST_YESTODAY]) {
        [_contestButton setTitle:item.title forState:UIControlStateNormal];
        [self clickTab:TabTypeContestYestoday];
    }else if ([item.title isEqualToString:CONTEST_BEFOREYESTODAY]) {
        [_contestButton setTitle:item.title forState:UIControlStateNormal];
        [self clickTab:TabTypeContestBeforeYestoday];
    }
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
            [[GuessService defaultService] getGuessRankListWithType:HOT_RANK mode:PBUserGuessModeGuessModeGenius contestId:nil offset:tab.offset limit:tab.limit];
            [[GuessService defaultService] setDelegate:self];
            break;
            
        case TabTypeGeniusAllTime:
            [[GuessService defaultService] getGuessRankListWithType:ALL_TIME_RANK mode:PBUserGuessModeGuessModeGenius contestId:nil offset:tab.offset limit:tab.limit];
            [[GuessService defaultService] setDelegate:self];
            break;
            
        case TabTypeContestToday:
            contestId = [[_contests objectAtIndex:0] contestId];
            [[GuessService defaultService] getGuessRankListWithType:0 mode:PBUserGuessModeGuessModeContest contestId:contestId offset:tab.offset limit:tab.limit];
            [[GuessService defaultService] setDelegate:self];
            break;
            
        case TabTypeContestYestoday:
            contestId = [[_contests objectAtIndex:1] contestId];
            [[GuessService defaultService] getGuessRankListWithType:0 mode:PBUserGuessModeGuessModeContest contestId:contestId offset:tab.offset limit:tab.limit];
            [[GuessService defaultService] setDelegate:self];
            break;
            
        case TabTypeContestBeforeYestoday:
            contestId = [[_contests objectAtIndex:2] contestId];
            [[GuessService defaultService] getGuessRankListWithType:0 mode:PBUserGuessModeGuessModeContest contestId:contestId offset:tab.offset limit:tab.limit];
            [[GuessService defaultService] setDelegate:self];
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
