//
//  PainterController.m
//  Draw
//
//  Created by Gamy on 13-10-14.
//
//

#import "PainterController.h"
#import "UserService.h"
#import "FeedService.h"
#import "TopPlayerView.h"
#import "UserDetailViewController.h"
#import "ViewUserDetail.h"
#import "PPConfigManager.h"
#import "PurchaseVipController.h"

#define SHOW_ALL_TAGS ([PPConfigManager showAllPainterTags])

typedef enum{
    PainterTypeLevel = 1,
    PainterTypeScore = 2,
    PainterTypePop = 3,
    PainterTypePotential = 4,
    PainterTypeVIP = 5,
}PainterType;

@interface PainterController ()

@end

@implementation PainterController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if (SHOW_ALL_TAGS) {
            _defaultTabIndex = 2;
        }
    }
    return self;
}

- (void)updateTitleView
{
    [self.titleView setTitle:[GameApp painterName]]; //NSLS(@"kPainter")];
    [self.titleView setTarget:self];
    [self.titleView setBackButtonSelector:@selector(clickBackButton:)];
    [self.titleView setRightButtonAsRefresh];
    [self.titleView setRightButtonSelector:@selector(clickRefreshButton:)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTabButtons];

    SET_COMMON_TAB_TABLE_VIEW_Y(self.dataTableView);
    CGFloat height = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(self.dataTableView.frame);    
    [self.dataTableView updateHeight:height];
    [self updateTitleView];
    
    if (!SHOW_ALL_TAGS) {
        [[self.view viewWithTag:PainterTypePop] removeFromSuperview];
        [[self.view viewWithTag:PainterTypePotential] removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#define WIDTH_SPACE 1
- (void)setTopPlayerCell:(UITableViewCell *)cell
             WithPlayers:(NSArray *)players isFirstRow:(BOOL)isFirstRow
{
    CGFloat width = [TopPlayerView getHeight];
    CGFloat height = [TopPlayerView getHeight];//[RankView heightForRankViewType:RankViewTypeNormal];
    CGFloat space = WIDTH_SPACE;;
    CGFloat x = 0;
    CGFloat y = 0;
    //    NSInteger i = 0;
    for (TopPlayer *player in players) {
        TopPlayerView *playerView = [TopPlayerView createTopPlayerView:self];
        [playerView setViewInfo:player];
        [cell.contentView addSubview:playerView];
        playerView.frame = CGRectMake(x, y, width, height);
        x += width + space;
    }
}

- (void)clearCellSubViews:(UITableViewCell *)cell{
    [cell.contentView enumSubviewsWithClass:[TopPlayerView class] handler:^(id view) {
        [view removeFromSuperview];
    }];
}

- (NSObject *)saveGetObjectForIndex:(NSInteger)index
{
    NSArray *list = [self tabDataList];
    if (index < 0 || index >= [list count]) {
        return nil;
    }
    return [list objectAtIndex:index];
}

#define NORMAL_CELL_VIEW_NUMBER 3
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = @"RankCell";//[RankFirstCell getCellIdentifier];
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }else{
        [self clearCellSubViews:cell];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;

    NSInteger startIndex = (indexPath.row * NORMAL_CELL_VIEW_NUMBER);
    NSMutableArray *list = [NSMutableArray array];
    for (NSInteger i = startIndex; i < startIndex+NORMAL_CELL_VIEW_NUMBER; ++ i) {
        NSObject *object = [self saveGetObjectForIndex:i];
        if (object) {
            [list addObject:object];
        }
    }
    [self setTopPlayerCell:cell WithPlayers:list isFirstRow:(indexPath.row == 0)];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
    NSInteger rows = count/3 + ((count % 3) != 0);
    return rows;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TopPlayerView getHeight] + 1;
}


- (void)clickVipInfo:(id)sender
{
    [PurchaseVipController enter:self];
}

- (void)setRightButtonVipInfo
{
    [self.titleView setRightButtonTitle:NSLS(@"kUpgradeVIP")];
    [self.titleView setRightButtonSelector:@selector(clickVipInfo:)];
}

- (void)setRightButtonRefresh
{
    [self.titleView setRightButtonAsRefresh];
    [self.titleView setRightButtonSelector:@selector(clickRefreshButton:)];
}


#pragma mark delegate

- (NSInteger)tabCount
{
    return (SHOW_ALL_TAGS ? 5 : 2);
}

- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 18;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabIDs[] = {PainterTypeScore,PainterTypeLevel,PainterTypePop,PainterTypePotential,PainterTypeVIP};
    return tabIDs[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSArray *titles = @[NSLS(@"kFamousPlayer"), NSLS(@"kLevelPlayer"), NSLS(@"kPopPlayer"), NSLS(@"kNewStarPlayer"), NSLS(@"kRankVip")];
    return titles[index];
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    [self showActivityWithText:NSLS(@"kLoading")];
    TableTab *tab = [_tabManager tabForID:tabID];
    [[UserService defaultService] getTopPlayerWithType:tabID offset:tab.offset limit:tab.limit resultBlock:^(int resultCode, NSArray *userList) {
        [self hideActivity];
        if (resultCode == 0) {
            [self finishLoadDataForTabID:tabID resultList:userList];
        }else{
            POSTMSG(NSLS(@"kFailLoad"));
            [self failLoadDataForTabID:tabID];
        }
    }];
}

- (void)didClickTopPlayerView:(TopPlayerView *)topPlayerView
{
    TopPlayer *player = topPlayerView.topPlayer;
    [UserDetailViewController presentUserDetail:[ViewUserDetail viewUserDetailWithUserId:player.userId avatar:player.avatar nickName:player.nickName] inViewController:self];
}

- (void)clickTab:(NSInteger)tabID
{
    [super clickTab:tabID];
    if (tabID == PainterTypeVIP && ![[UserManager defaultManager] isVip]) {
        [self setRightButtonVipInfo];
    }else{
        [self setRightButtonRefresh];
    }
}
@end
