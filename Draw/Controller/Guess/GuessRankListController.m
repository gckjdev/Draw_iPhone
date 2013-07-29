//
//  GuessRankListController.m
//  Draw
//
//  Created by 王 小涛 on 13-7-24.
//
//

#import "GuessRankListController.h"
#import "CommonTitleView.h"
#import "GuessRankCell.h"
#import "KxMenu.h"

@interface GuessRankListController ()

@end

@implementation GuessRankListController

- (void)dealloc{
    
    [[GuessService defaultService] setDelegate:nil];
    [super dealloc];
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    [self.view addSubview:[CommonTitleView createWithTitle:NSLS(@"kGuessRank") delegate:self]];
    // Do any additional setup after loading the view from its nib.
    [self initTabButtons];
//    self 

    
}



- (IBAction)clickGeniusButton:(UIButton *)sender {
    
    // TODO: set pull down list to select
    
    [KxMenu dismissMenu];
    
    NSArray *menuItems =
    @[

        [KxMenuItem menuItem:NSLS(@"select")
                       image:nil
                      target:nil
                      action:NULL],

        [KxMenuItem menuItem:NSLS(@"week")
                       image:nil
                      target:self
                      action:@selector(pushMenuItem:)],

        [KxMenuItem menuItem:NSLS(@"year")
                       image:nil
                      target:self
                      action:@selector(pushMenuItem:)]
    ];

    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;

    [KxMenu showMenuInView:self.view
    fromRect:sender.frame
    menuItems:menuItems];

}

- (IBAction)clickContestButton:(UIButton *)sender {
    
    // TODO: set pull down list to select
    
    [KxMenu dismissMenu];
    
    NSArray *menuItems =
    @[
      
        [KxMenuItem menuItem:NSLS(@"select")
                       image:nil
                      target:nil
                      action:NULL],

        [KxMenuItem menuItem:NSLS(@"today")
                       image:nil
                      target:self
                      action:@selector(pushMenuItem:)],

        [KxMenuItem menuItem:NSLS(@"yestoday")
                       image:nil
                      target:self
                      action:@selector(pushMenuItem:)],

        [KxMenuItem menuItem:NSLS(@"beforYestoday")
                       image:nil
                      target:self
                      action:@selector(pushMenuItem:)]
    ];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;

    [KxMenu showMenuInView:self.view
                fromRect:sender.frame
               menuItems:menuItems];
}
      
- (void) pushMenuItem:(KxMenuItem *)item
{
    PPDebug(@"title = %@", item.title);
}

- (void)didGetGuessRankList:(NSArray *)list resultCode:(int)resultCode{
    
    
    if (resultCode == 0) {
        PPDebug(@"list count = %d", [list count]);
    }else{
        [self popupHappyMessage:NSLS(@"kLoadFailed") title:nil];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GuessRankCell *cell = [tableView dequeueReusableCellWithIdentifier:[GuessRankCell getCellIdentifier]];
    if (cell == nil) {
        cell = [GuessRankCell createCell:nil];
    }
    
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
            [[GuessService defaultService] getGuessRankListWithType:0 mode:PBUserGuessModeGuessModeContest contestId:nil offset:tab.offset limit:tab.limit];
            [[GuessService defaultService] setDelegate:self];
            break;
            
        case TabTypeContestYestoday:
            [[GuessService defaultService] getGuessRankListWithType:0 mode:PBUserGuessModeGuessModeContest contestId:nil offset:tab.offset limit:tab.limit];
            [[GuessService defaultService] setDelegate:self];
            break;
            
        case TabTypeContestBeforeYestoday:
            [[GuessService defaultService] getGuessRankListWithType:0 mode:PBUserGuessModeGuessModeContest contestId:nil offset:tab.offset limit:tab.limit];
            [[GuessService defaultService] setDelegate:self];
            break;
            
        default:
            break;
    }
}


@end
