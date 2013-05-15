//
//  LittleGeeHomeController.m
//  Draw
//
//  Created by Kira on 13-5-8.
//
//

#import "LittleGeeHomeController.h"
#import "RankView.h"
#import "MKBlockActionSheet.h"
#import "BBSPermissionManager.h"
#import "CMPopTipView.h"
#import "LittleGeeImageManager.h"
#import "UserManager.h"
#import "OfflineDrawViewController.h"
#import "Word.h"
#import "ShareController.h"
#import "ContestController.h"
#import "StatisticManager.h"
#import "ChatListController.h"
#import "MyFeedController.h"
#import "BulletinView.h"
#import "FreeIngotController.h"
#import "BBSBoardController.h"
#import "StoreController.h"
#import "ShowFeedController.h"
#import "UseItemScene.h"
#import "DrawRoomListController.h"
#import "FeedbackController.h"
#import "BulletinService.h"
#import "NotificationName.h"
#import "DrawGameService.h"
#import "UIColor+UIColorExt.h"

#define OPTION_SHEET_FIRST_SHOW_DURATION 6
#define OPTION_SHEET_SHOW_DURATION  60

#define POP_OPTION_SHEET_TAG    120130511
#define DRAW_OPTION_SHEET_TAG   220130511

typedef enum {
    DrawOptionIndexDrawTo = 0,
    DrawOptionIndexDraft,
    DrawOptionIndexBegin,
    DrawOptionIndexContest,
}DrawOptionIndex;

typedef enum {
    PopOptionIndexPK = 0,
//    PopOptionIndexSearch,
    PopOptionIndexNotice,
    PopOptionIndexBbs,
    PopOptionIndexIngot,
    PopOptionIndexContest,
    PopOptionIndexShop,
    PopOptionIndexMore
}PopOptionIndex;

@interface LittleGeeHomeController ()

@property(nonatomic, retain)HomeBottomMenuPanel *homeBottomMenuPanel;
@property (nonatomic, retain) CustomActionSheet* optionSheet;
@property (nonatomic, retain) CustomActionSheet* drawOptionSheet;
@property (retain, nonatomic) IBOutlet UIButton *drawOptionBtn;
@property (retain, nonatomic) IBOutlet UIImageView *bigPen;
@end

@implementation LittleGeeHomeController

- (void)dealloc
{
    PPRelease(_homeBottomMenuPanel);
    PPRelease(_optionSheet);
    PPRelease(_drawOptionSheet);
    [_drawOptionBtn release];
    [_bigPen release];
    [super dealloc];
}

- (void)hideOptionSheet
{
    if (self.optionSheet && [self.optionSheet isVisable]) {
        [self.optionSheet hideActionSheet];
    }
}

#define OPTION_ITEM_SIZE (ISIPAD?CGSizeMake(80,80):CGSizeMake(50,50))
#define OPTION_CONTAINER_SIZE (ISIPAD?CGSizeMake(80,1000):CGSizeMake(60,480))
- (void)showOptionSheetForTime:(CFTimeInterval)timeInterval
{
    LittleGeeImageManager* imgManager = [LittleGeeImageManager defaultManager];
    if (!_optionSheet) {
        self.optionSheet = [[[CustomActionSheet alloc] initWithTitle:nil delegate:self imageArray:[imgManager popOptionsGameImage], [imgManager popOptionsNoticeImage], [imgManager popOptionsBbsImage],  [imgManager popOptionsIngotImage], [imgManager popOptionsContestImage], [imgManager popOptionsShopImage], [imgManager popOptionsMoreImage], nil] autorelease];
        self.optionSheet.tag = POP_OPTION_SHEET_TAG;
        //                [self.actionSheet.popView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_pattern.png"]]];
    }
    UIView* menu = [self.homeBottomMenuPanel getMenuViewWithType:HomeMenuTypeLittleGeeOptions];
    [_optionSheet setBadgeCount:3 forIndex:PopOptionIndexNotice];
    [_optionSheet setBadgeCount:2 forIndex:PopOptionIndexBbs];
    [_optionSheet showInView:self.view onView:menu
 WithContainerSize:OPTION_CONTAINER_SIZE columns:1 showTitles:NO itemSize:OPTION_ITEM_SIZE backgroundImage:[imgManager popOptionsBackgroundImage]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideOptionSheet) object:nil];
    [self performSelector:@selector(hideOptionSheet) withObject:nil afterDelay:timeInterval];
}

- (void)addBottomMenuView
{
    self.homeBottomMenuPanel = [HomeBottomMenuPanel createView:self];
    [self.view addSubview:self.homeBottomMenuPanel];
    [self.homeBottomMenuPanel updateOriginY:CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.homeBottomMenuPanel.bounds)];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBottomMenuView];
    [self initTabButtons];
    [self initDrawOptions];
    [self.view bringSubviewToFront:self.drawOptionBtn];
    [self.view bringSubviewToFront:self.bigPen];
    [self.drawOptionBtn addTarget:self action:@selector(clickDrawOptionBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.titleLabel setText:NSLS(@"kLittleGee")];
    [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(handleStaticTimer:) userInfo:nil repeats:YES];
    [[BulletinService defaultService] syncBulletins:^(int resultCode) {
        [self updateAllBadge];
        if ([[UserManager defaultManager] hasUser]) {
            [self showOptionSheetForTime:OPTION_SHEET_FIRST_SHOW_DURATION];
        }
    }];
    [self registerNetworkDisconnectedNotification];
    // Do any additional setup after loading the view from its nib.
}

- (void)initTabButtons
{
    [super initTabButtons];
    NSArray* tabList = [_tabManager tabList];
    NSInteger index = 0;
    for(TableTab *tab in tabList){
        UIButton *button = (UIButton *)[self.view viewWithTag:tab.tabID];
        
        //text color
        [button setTitleColor:OPAQUE_COLOR(37, 161, 126) forState:UIControlStateSelected];
        
        //bg image
        [button setBackgroundImage:nil forState:UIControlStateSelected];
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        
        index++;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UserService defaultService] getStatistic:self];
}

- (void)initDrawOptions
{
    LittleGeeImageManager* imgManager = [LittleGeeImageManager defaultManager];
    self.drawOptionSheet = [[[CustomActionSheet alloc] initWithTitle:nil delegate:self buttonTitles:nil] autorelease];
    self.drawOptionSheet.tag = DRAW_OPTION_SHEET_TAG;
    [self.drawOptionSheet addButtonWithTitle:NSLS(@"kLittleGeeDrawTo") image:[imgManager drawToBtnBackgroundImage]];
    [self.drawOptionSheet addButtonWithTitle:NSLS(@"kDraft") image:[imgManager draftBtnBackgroundImage]];
    [self.drawOptionSheet addButtonWithTitle:NSLS(@"kLittleGeeBegin") image:[imgManager beginBtnBackgroundImage]];
    [self.drawOptionSheet addButtonWithTitle:NSLS(@"kLittleGeeContest") image:[imgManager contestBtnBackgroundImage]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)homeBottomMenuPanel:(HomeBottomMenuPanel *)bottomMenuPanel
               didClickMenu:(HomeMenuView *)menu
                   menuType:(HomeMenuType)type
{
    switch (type) {
        case HomeMenuTypeLittleGeeOptions: {
            if ([_optionSheet isVisable]) {
                [_optionSheet hideActionSheet];
            } else {
                [self showOptionSheetForTime:OPTION_SHEET_SHOW_DURATION];
            }
            
        }break;
        case HomeMenuTypeLittleGeeFriend: {
            FriendController* vc = [[[FriendController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
        case HomeMenuTypeLittleGeeChat: {
            ChatListController *controller = [[ChatListController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        } break;
        case HomeMenuTypeLittleGeeFeed: {
            [MyFeedController enterControllerWithIndex:0 fromController:self animated:YES];
            [[StatisticManager defaultManager] setFeedCount:0];
        } break;
        default:
            break;
    }
     [menu updateBadge:0];
}

#pragma mark - custom action sheet delegate
- (void)customActionSheet:(CustomActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == DRAW_OPTION_SHEET_TAG) {
        switch (buttonIndex) {
            case DrawOptionIndexDrawTo: {
                FriendController* vc = [[[FriendController alloc] initWithDelegate:self] autorelease];
                [self.navigationController pushViewController:vc animated:YES];
            } break;
            case DrawOptionIndexDraft: {
                ShareController* share = [[ShareController alloc] init];
//                int count = [[StatisticManager defaultManager] recoveryCount];
                [share setDefaultTabIndex:2];
                [[StatisticManager defaultManager] setRecoveryCount:0];
                [self.navigationController pushViewController:share animated:YES];
                [share release];
            } break;
            case DrawOptionIndexBegin: {
                [OfflineDrawViewController startDraw:[Word wordWithText:@"" level:0] fromController:self startController:self targetUid:nil];
            } break;
            case DrawOptionIndexContest: {
                ContestController *cc = [[ContestController alloc] init];
                [self.navigationController pushViewController:cc animated:YES];
                [cc release];
            } break;
            default:
                break;
        }
    }
    if (actionSheet.tag == POP_OPTION_SHEET_TAG) {
        switch (buttonIndex) {
            case PopOptionIndexPK: {
                UIViewController* rc = [[[DrawRoomListController alloc] init] autorelease];
                [self.navigationController pushViewController:rc animated:YES];
            } break;
//            case PopOptionIndexSearch: {
//                
//            } break;
            case PopOptionIndexNotice: {
                
                [BulletinView showBulletinInController:self];
            } break;
            case PopOptionIndexBbs: {
                [[StatisticManager defaultManager] setBbsActionCount:0];
                BBSBoardController *bbs = [[BBSBoardController alloc] init];
                [self.navigationController pushViewController:bbs animated:YES];
                [bbs release];
            } break;
            case PopOptionIndexIngot: {
                FreeIngotController* fc = [[[FreeIngotController alloc] init] autorelease];
                [self.navigationController pushViewController:fc animated:YES];
            } break;
            case PopOptionIndexContest: {
                ContestController *cc = [[ContestController alloc] init];
                [self.navigationController pushViewController:cc animated:YES];
                [cc release];
            } break;
            case PopOptionIndexShop: {
                StoreController *vc = [[[StoreController alloc] init] autorelease];
                [self.navigationController pushViewController:vc animated:YES];
            } break;
            case PopOptionIndexMore: {
                FeedbackController* feedBack = [[FeedbackController alloc] init];
                [self.navigationController pushViewController:feedBack animated:YES];
                [feedBack release];
            } break;
                
            default:
                break;
        }
    }
}


//rank view delegate
- (void)playFeed:(DrawFeed *)aFeed
{

    
}

// progress download delegate
- (void)setProgress:(CGFloat)progress
{
    if (progress == 1.0f){
        // make this because after uploading data, it takes server sometime to process
        progress = 0.99;
    }
    
    NSString* progressText = [NSString stringWithFormat:NSLS(@"kLoadingProgress"), progress*100];
    [self.progressView setLabelText:progressText];
    [self.progressView setProgress:progress];
}


- (void)showFeed:(DrawFeed *)feed
{
    ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:feed scene:[UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:feed]];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];
    
}

- (void)didClickRankView:(RankView *)rankView
{
    [self showFeed:rankView.feed];
}



//table view delegate





#define NORMAL_CELL_VIEW_NUMBER 3
#define WIDTH_SPACE 1

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
    return  count / NORMAL_CELL_VIEW_NUMBER + (count % NORMAL_CELL_VIEW_NUMBER != 0);
}

- (void)setNormalRankCell:(UITableViewCell *)cell
                WithFeeds:(NSArray *)feeds
{
    CGFloat width = [RankView widthForRankViewType:RankViewTypeNormal];
    CGFloat height = [RankView heightForRankViewType:RankViewTypeNormal];
    
    CGFloat space =  WIDTH_SPACE;
    CGFloat x = 0;
    CGFloat y = 0;
    for (DrawFeed *feed in feeds) {
        RankView *rankView = [RankView createRankView:self type:RankViewTypeNormal];
        [rankView setViewInfo:feed];
        [cell.contentView addSubview:rankView];
        rankView.frame = CGRectMake(x, y, width, height);
        x += width + space;
    }
}

- (NSObject *)saveGetObjectForIndex:(NSInteger)index
{
    NSArray *list = [self tabDataList];
    if (index < 0 || index >= [list count]) {
        return nil;
    }
    return [list objectAtIndex:index];
}

- (void)clearCellSubViews:(UITableViewCell *)cell{
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[RankView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [RankView heightForRankViewType:RankViewTypeNormal] + 1;
}

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
    //        PPDebug(@"startIndex = %d",startIndex);
    for (NSInteger i = startIndex; i < startIndex+NORMAL_CELL_VIEW_NUMBER; ++ i) {
        NSObject *object = [self saveGetObjectForIndex:i];
        if (object) {
            [list addObject:object];
        }
    }
    [self setNormalRankCell:cell WithFeeds:list];
    
    return cell;
    
}

//table tab manager


#define OFFSET 100

- (LittleGeeHomeGalleryType)typeFromTabID:(int)tabID
{
    return tabID - OFFSET;
}

- (int)tabIDFromType:(LittleGeeHomeGalleryType)type
{
    return type + OFFSET;
}

- (LittleGeeHomeGalleryType)littleGeeTypeFromFeedListType:(FeedListType)type
{
    int littleGeeType = 0;
    switch (type) {
        case FeedListTypeHistoryRank:
            littleGeeType = LittleGeeHomeGalleryTypeAnnual;
            break;
        case FeedListTypeHot:
            littleGeeType = LittleGeeHomeGalleryTypeWeekly;
            break;
        case FeedListTypeLatest:
            littleGeeType = LittleGeeHomeGalleryTypeLatest;
        default:
            break;
    }
    return littleGeeType;
}

- (NSInteger)tabCount //default 1
{
    return 5;
}
- (NSInteger)currentTabIndex //default 0
{
    return _defaultTabIndex;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index //default 20
{
    return 15;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    
    int types[] = {
        LittleGeeHomeGalleryTypeAnnual,
        LittleGeeHomeGalleryTypeWeekly,
        LittleGeeHomeGalleryTypeLatest,
        LittleGeeHomeGalleryTypeRecommend,
        LittleGeeHomeGalleryTypeFriend};
    
    return [self tabIDFromType:types[index]];
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *titles[] = {NSLS(@"kRankHistory"),NSLS(@"kRankHot"),NSLS(@"kRankNew"),NSLS(@"kLittleGeeRecommend"),NSLS(@"kFriend")};
    return titles[index];
}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    [self showActivityWithText:NSLS(@"kLoading")];
    TableTab *tab = [_tabManager tabForID:tabID];
    int type = [self typeFromTabID:tabID];
    if (tab) {
        if (type == LittleGeeHomeGalleryTypeLatest) {
            [[FeedService defaultService] getFeedList:FeedListTypeLatest offset:tab.offset limit:tab.limit delegate:self];
        }else if(type == LittleGeeHomeGalleryTypeFriend){
//            [[UserService defaultService] getTopPlayer:tab.offset limit:tab.limit delegate:self];
        }else if (type == LittleGeeHomeGalleryTypeAnnual) {
            [[FeedService defaultService] getFeedList:FeedListTypeHistoryRank offset:tab.offset limit:tab.limit delegate:self];
        }else if (type == LittleGeeHomeGalleryTypeWeekly) {
            [[FeedService defaultService] getFeedList:FeedListTypeHot offset:tab.offset limit:tab.limit delegate:self];
        }
        else if (type == LittleGeeHomeGalleryTypeRecommend){
            [self hideActivity];
//            [[FeedService defaultService] getFeedList:FeedListTypeHistoryRank offset:tab.offset limit:tab.limit delegate:self];
        }
        
    }
    
}

#pragma mark - feed service delegate

- (void)didGetFeedList:(NSArray *)feedList
          feedListType:(FeedListType)type
            resultCode:(NSInteger)resultCode
{
    PPDebug(@"<didGetFeedList> list count = %d ", [feedList count]);
    [self hideActivity];
    if (resultCode == 0) {
        for (DrawFeed *feed in feedList) {
            //            PPDebug(@"%d: feedId = %@, word = %@", i++, feed.feedId,feed.wordText);
        }
        [self finishLoadDataForTabID:[self tabIDFromType:[self littleGeeTypeFromFeedListType:type]] resultList:feedList];
    }else{
        [self failLoadDataForTabID:[self tabIDFromType:[self littleGeeTypeFromFeedListType:type]]];
    }
    

}

#define ITEM_SIZE (ISIPAD?CGSizeMake(100, 100):CGSizeMake(60,60))
#define DRAW_OPTION_SHEET_RADIUS (ISIPAD?180:100)
- (IBAction)clickDrawOptionBtn:(id)sender
{
    [self hideOptionSheet];
    if ([self.drawOptionSheet isVisable]) {
        [self.drawOptionSheet hideActionSheet];
    } else {
        UIButton* btn = (UIButton*)sender;
        float radius = sqrtf((btn.frame.size.height*btn.frame.size.height) + (0.5*btn.frame.size.width*0.5*btn.frame.size.width)) + MAX(ITEM_SIZE.width, ITEM_SIZE.height);
        [self.drawOptionSheet expandInView:self.view onView:btn fromAngle:(-M_PI*0.2) toAngle:(M_PI*0.2) radius:radius itemSize:ITEM_SIZE];
    }
}

//- (void)didGetTopPlayerList:(NSArray *)playerList
//                 resultCode:(NSInteger)resultCode
//{
//    PPDebug(@"<didGetTopPlayerList> list count = %d ", [playerList count]);
//    [self hideActivity];
//    if (resultCode == 0) {
//        [self finishLoadDataForTabID:LittleGeeHomeGalleryTypeFriend resultList:playerList];
//    }else{
//        [self failLoadDataForTabID:LittleGeeHomeGalleryTypeFriend];
//    }
//}

#pragma mark - tableView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideOptionSheet];
}


#pragma mark - friend controller delegate
- (void)friendController:(FriendController *)controller
         didSelectFriend:(MyFriend *)aFriend
{
    [OfflineDrawViewController startDraw:[Word wordWithText:@"" level:0] fromController:self startController:self targetUid:aFriend.friendUserId];
}

- (void)viewDidUnload {
    [self setDrawOptionBtn:nil];
    [self setBigPen:nil];
    [super viewDidUnload];
}

#pragma mark - get && update statistic
- (void)handleStaticTimer:(NSTimer *)theTimer
{
    PPDebug(@"<handleStaticTimer>: get static");
    [[UserService defaultService] getStatistic:self];
}


- (HomeCommonView *)panelForType:(HomeMenuType)type
{
    return self.homeBottomMenuPanel;
}

- (void)updateBadgeWithType:(HomeMenuType)type badge:(NSInteger)badge
{
    HomeCommonView *panel = [self panelForType:type];
    [panel updateMenu:type badge:badge];
}

- (void)updateAllBadge
{
    StatisticManager *manager = [StatisticManager defaultManager];
    
    [self updateBadgeWithType:HomeMenuTypeLittleGeeChat badge:manager.messageCount];
    [self updateBadgeWithType:HomeMenuTypeLittleGeeFriend badge:manager.fanCount];
    //    [self updateBadgeWithType:HomeMenuTypeDrawBBS badge:manager.bbsActionCount];
    
    long timelineCount = manager.feedCount + manager.commentCount + manager.drawToMeCount;
    
    PPDebug(@"<LittleGee-updateAllBadge> update feed count = %d, comment count = %d, draw to me count = %d", manager.feedCount, manager.commentCount, manager.drawToMeCount);
    
    [self updateBadgeWithType:HomeMenuTypeLittleGeeFeed badge:timelineCount];
    
    int optionCount = manager.bbsActionCount + manager.bulletinCount;
    [self updateBadgeWithType:HomeMenuTypeLittleGeeOptions badge:optionCount];
//    [self.homeHeaderPanel updateBulletinBadge:[manager bulletinCount]];
    
}

- (void)didSyncStatisticWithResultCode:(int)resultCode
{
    if (resultCode == 0) {
        [self updateAllBadge];
    }
}

- (void)handleDisconnectWithError:(NSError *)error
{
    PPDebug(@"diconnect error: %@", [error description]);
    
//    _isTryJoinGame = NO;
    [self hideActivity];
    
    if (error != nil) {
        [[DrawGameService defaultService] setSession:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self popupUnhappyMessage:NSLS(@"kNetworkBroken") title:@""];
    }
}

- (void)registerNetworkDisconnectedNotification
{
    [self registerNotificationWithName:NOTIFICATION_NETWORK_DISCONNECTED
                            usingBlock:^(NSNotification *note) {
                                [self handleDisconnectWithError:[CommonGameNetworkService userInfoToError:note.userInfo]];
                            }];
}

@end
