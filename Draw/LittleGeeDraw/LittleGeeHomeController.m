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
#import "UserDetailViewController.h"
#import "SelfUserDetail.h"
#import "CommonMessageCenter.h"
#import "Contest.h"
#import "StatementController.h"
#import "RegisterUserController.h"
#import "StringUtil.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"
#import "TopPlayer.h"
#import "TopPlayerView.h"
#import "ViewUserDetail.h"
#import "ContestManager.h"
#import "DrawAppDelegate.h"
#import "SearchPhotoController.h"
#import "UINavigationController+UINavigationControllerAdditions.h"

#define POP_OPTION_SHEET_TAG    120130511
#define DRAW_OPTION_SHEET_TAG   220130511

typedef enum {
    DrawOptionIndexDrawTo = 0,
    DrawOptionIndexDraft,
    DrawOptionIndexBegin,
    DrawOptionIndexContest,
}DrawOptionIndex;

typedef enum {
    PopOptionSelf = 0,
    PopOptionContest,
    PopOptionPK,
    PopOptionBbs,
    PopOptionNotice,
    PopOptionShop,
    PopOptionIngot,
    PopOptionMore,
    PopOptionCount,
}PopOption;

static int popOptionListWithFreeCoins[] = {
    PopOptionSelf,
    PopOptionContest,
    PopOptionPK,
    PopOptionBbs,
    PopOptionNotice,
    PopOptionShop,
    PopOptionIngot,
    PopOptionMore,
};

static int popOptionListWithoutFreeCoins[] = {
    PopOptionSelf,
    PopOptionContest,
    PopOptionPK,
    PopOptionBbs,
    PopOptionNotice,
    PopOptionShop,
    PopOptionMore,
};

static int popOptionListWithFreeCoinsEn[] = {
    PopOptionSelf,
    PopOptionNotice,
    PopOptionShop,
    PopOptionIngot,
    PopOptionMore,
};

static int popOptionListWithoutFreeCoinsEn[] = {
    PopOptionSelf,
    PopOptionNotice,
    PopOptionShop,
    PopOptionMore,
};

@interface LittleGeeHomeController () {
    BOOL _isJoiningContest;
}

@property (nonatomic, retain) HomeBottomMenuPanel *homeBottomMenuPanel;
@property (nonatomic, retain) CustomActionSheet* optionSheet;
@property (nonatomic, retain) CustomActionSheet* drawOptionSheet;
@property (retain, nonatomic) IBOutlet UIButton *drawOptionBtn;
@property (retain, nonatomic) IBOutlet UIImageView *bigPen;

@property (retain, nonatomic) IBOutlet UIButton *testBtn;


@end

@implementation LittleGeeHomeController
@synthesize notificationType;

- (void)dealloc
{
    PPRelease(_homeBottomMenuPanel);
    PPRelease(_optionSheet);
    PPRelease(_drawOptionSheet);
    [_drawOptionBtn release];
    [_bigPen release];
    [_testBtn release];
    [super dealloc];
}

- (UIImage*)imageForPopOption:(PopOption)option
{
    LittleGeeImageManager* imgManager = [LittleGeeImageManager defaultManager];
    switch (option) {
        case PopOptionPK: {
            return imgManager.popOptionsGameImage;
        } break;
        case PopOptionSelf: {
            return imgManager.popOptionsSelfImage;
        } break;
        case PopOptionNotice: {
            return imgManager.popOptionsNoticeImage;
        } break;
        case PopOptionBbs: {
            return imgManager.popOptionsBbsImage;
        } break;
        case PopOptionIngot: {
            return imgManager.popOptionsIngotImage;
        } break;
        case PopOptionContest: {
            return imgManager.popOptionsContestImage;
        } break;
        case PopOptionShop: {
            return imgManager.popOptionsShopImage;
        } break;
        case PopOptionMore: {
            return imgManager.popOptionsMoreImage;
        } break;
            
        default:
            break;
    }
    return nil;
}

- (void)hideOptionSheet
{
    if (self.optionSheet && [self.optionSheet isVisable]) {
        [self.optionSheet hideActionSheet];
    }
}

static int* getPopOptionList()
{
    if ([ConfigManager wallEnabled]) {
        if ([[UserManager defaultManager] getLanguageType] == ChineseType) {
            return popOptionListWithFreeCoins;
        } else {
            return popOptionListWithFreeCoinsEn;
        }
        
    } else {
        if ([[UserManager defaultManager] getLanguageType] == ChineseType) {
            return popOptionListWithoutFreeCoins;
        } else {
            return popOptionListWithoutFreeCoinsEn;
        }
    }
}

int getPopOptionCount()
{
    if ([ConfigManager wallEnabled]) {
        if ([[UserManager defaultManager] getLanguageType] == ChineseType) {
            return (PopOptionCount);
        } else {
            return (PopOptionCount-3);
        }
        
    } else {
        if ([[UserManager defaultManager] getLanguageType] == ChineseType) {
            return (PopOptionCount-1);
        } else {
            return (PopOptionCount-4);
        }
    }
}

- (int)indexForPopOption:(PopOption)option
{
    int count = getPopOptionCount();
    int* list = getPopOptionList();
    for (int i = 0; i < count; i ++) {
        if (option == list[i]) {
            return i;
        }
    }
    return 0;
}

#define OPTION_ITEM_SIZE (ISIPAD?CGSizeMake(120,80):CGSizeMake(60,40))
#define OPTION_CONTAINER_SIZE (ISIPAD?CGSizeMake(700,1000):CGSizeMake(300,480))
- (void)showOptionSheetForTime:(CFTimeInterval)timeInterval
{
    if (timeInterval == 0) {
        return;
    }
    LittleGeeImageManager* imgManager = [LittleGeeImageManager defaultManager];
    if (!_optionSheet) {
        self.optionSheet = [[[CustomActionSheet alloc] initWithTitle:nil delegate:self imageArray:nil] autorelease];
        self.optionSheet.tag = POP_OPTION_SHEET_TAG;
        //                [self.actionSheet.popView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_pattern.png"]]];
    }
    [_optionSheet removeAllActions];
    int count = getPopOptionCount();
    int* list = getPopOptionList();
    for (int i = 0; i < count; i ++) {
        UIImage* image = [self imageForPopOption:list[i]];
        [self.optionSheet addButtonWithImage:image];
    }
    if ([_optionSheet isVisable]) {
        [self hideOptionSheet];
    }
    UIView* menu = [self.homeBottomMenuPanel getMenuViewWithType:HomeMenuTypeLittleGeeOptions];
    [_optionSheet setBadgeCount:[[StatisticManager defaultManager] bulletinCount] forIndex:[self indexForPopOption:PopOptionNotice]];
    if ([[UserManager defaultManager] getLanguageType] == ChineseType) {
        [_optionSheet setBadgeCount:[[StatisticManager defaultManager] bbsActionCount] forIndex:[self indexForPopOption:PopOptionBbs]];
        [_optionSheet setBadgeCount:[[StatisticManager defaultManager] newContestCount] forIndex:[self indexForPopOption:PopOptionContest]];
    }
    
    [_optionSheet showInView:self.view onView:menu
 WithContainerSize:OPTION_CONTAINER_SIZE columns:1 showTitles:NO itemSize:OPTION_ITEM_SIZE backgroundImage:[imgManager popOptionsBackgroundImage]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideOptionSheet) object:nil];
    [self performSelector:@selector(hideOptionSheet) withObject:nil afterDelay:timeInterval];
}

- (void)addBottomMenuView
{
    self.homeBottomMenuPanel = [HomeBottomMenuPanel createView:self];
    [self.view addSubview:self.homeBottomMenuPanel];
    [self.homeBottomMenuPanel updateOriginY:CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.homeBottomMenuPanel.bounds) + (ISIPAD?10:0)];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)showCachedFeedList:(int)tabID
{
    PPDebug(@"<showCachedFeedList> tab id = %d", tabID);
    FeedListType type = [self feedListTypeForTabID:tabID];
    NSArray *feedList = [[FeedService defaultService] getCachedFeedList:type];
    if ([feedList count] != 0) {
        [self finishLoadDataForTabID:tabID resultList:feedList];
    }
    TableTab *tab = [_tabManager tabForID:tabID];
    tab.status = TableTabStatusUnload;
    tab.offset = 0;
}

- (void)clickTabButton:(id)sender
{
    int tabID = [(UIButton *)sender tag];
    TableTab *tab = [_tabManager tabForID:tabID];
    if ([tab.dataList count] == 0) {
        [self showCachedFeedList:tabID];
    }   
    [super clickTabButton:sender];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBottomMenuView];
    [self initTabButtons];
    [self.view bringSubviewToFront:self.drawOptionBtn];
    [self.view bringSubviewToFront:self.bigPen];
    [self.drawOptionBtn addTarget:self action:@selector(clickDrawOptionBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.titleLabel setText:NSLS(@"kLittleGee")];
    [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(handleStaticTimer:) userInfo:nil repeats:YES];
    [[BulletinService defaultService] syncBulletins:^(int resultCode) {
        [self updateAllBadge];
        [self firstShowOptions];
    }];
    [[ContestService defaultService] getContestListWithType:ContestListTypeRunning offset:0 limit:HUGE_VAL delegate:self];
    [self registerNetworkDisconnectedNotification];
#if DEBUG
//    self.testBtn.hidden = NO;
#endif
    // Do any additional setup after loading the view from its nib.
    
}

- (void)firstShowOptions
{
    if ([[UserManager defaultManager] hasUser]) {
        //first enter game, show side bar
        
        [self showOptionSheetForTime:[ConfigManager littleGeeFirstShowOptionsDuration]];
    }
}

#define BUTTON_FONT_EN (ISIPAD ? [UIFont boldSystemFontOfSize:28] : [UIFont boldSystemFontOfSize:12])
- (void)initTabButtons
{
    [super initTabButtons];
    if (![LocaleUtils isChinese]) {
        NSArray* tabList = [_tabManager tabList];
        NSInteger index = 0;
        for(TableTab *tab in tabList){
            UIButton *button = (UIButton *)[self.view viewWithTag:tab.tabID];
            //font
            [button.titleLabel setFont:BUTTON_FONT_EN];
            index++;
        }
    }
}

//#define TAB_BTN_FONT_SIZE (ISIPAD?24:12)
//- (void)initTabButtons
//{
//    [super initTabButtons];
//    NSArray* tabList = [_tabManager tabList];
//    NSInteger index = 0;
//    for(TableTab *tab in tabList){
//        UIButton *button = (UIButton *)[self.view viewWithTag:tab.tabID];
//        
//        //text color
//        [button setTitleColor:OPAQUE_COLOR(37, 161, 126) forState:UIControlStateSelected];
//        
//        //bg image
//        [button setBackgroundImage:nil forState:UIControlStateSelected];
//        [button setBackgroundImage:nil forState:UIControlStateNormal];
//        
//        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:TAB_BTN_FONT_SIZE]];
//        
//        index++;
//    }
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UserService defaultService] getStatistic:self];
}

- (void)initDrawOptions
{
    LittleGeeImageManager* imgManager = [LittleGeeImageManager defaultManager];
    if (!_drawOptionSheet) {
        self.drawOptionSheet = [[[CustomActionSheet alloc] initWithTitle:nil delegate:self buttonTitles:nil] autorelease];
        self.drawOptionSheet.tag = DRAW_OPTION_SHEET_TAG;
    }
    [_drawOptionSheet removeAllActions];
    [self.drawOptionSheet addButtonWithTitle:NSLS(@"kLittleGeeDrawTo") image:[imgManager drawToBtnBackgroundImage]];
    
    if ([[UserManager defaultManager] getLanguageType] == ChineseType) {
        [self.drawOptionSheet addButtonWithTitle:NSLS(@"kDraft") image:[imgManager draftBtnBackgroundImage]];
        [self.drawOptionSheet addButtonWithTitle:NSLS(@"kLittleGeeBegin") image:[imgManager beginBtnBackgroundImage]];
        [self.drawOptionSheet addButtonWithTitle:NSLS(@"kLittleGeeContest") image:[imgManager contestBtnBackgroundImage]];
    } else {
        [self.drawOptionSheet addButtonWithTitle:NSLS(@"kLittleGeeBegin") image:[imgManager beginBtnBackgroundImage]];
        [self.drawOptionSheet addButtonWithTitle:NSLS(@"kDraft") image:[imgManager draftBtnBackgroundImage]];
    }

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
    if (![self isRegistered]) {
        [self toRegister];
        return;
    }
    switch (type) {
        case HomeMenuTypeLittleGeeOptions: {
            if ([_optionSheet isVisable]) {
                [_optionSheet hideActionSheet];
            } else {
                [self showOptionSheetForTime:[ConfigManager littleGeeShowOptionsDuration]];
            }
            return;//don't reset badge
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
            [[StatisticManager defaultManager] setTimelineOpusCount:0];
        } break;
        default:
            break;
    }
     [menu updateBadge:0];
}

#pragma mark - custom action sheet delegate

- (DrawOptionIndex)fixDrawOptionIndex:(DrawOptionIndex)index
{
    if ([[UserManager defaultManager] getLanguageType] != ChineseType) {
        if (index == DrawOptionIndexBegin) {
            return DrawOptionIndexDraft;
        }
        if (index == DrawOptionIndexDraft) {
            return DrawOptionIndexBegin;
        }
    }
    return index;
}

- (void)customActionSheet:(CustomActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (![self isRegistered] && !(actionSheet.tag == DRAW_OPTION_SHEET_TAG && buttonIndex == DrawOptionIndexBegin)) {
        [self toRegister];
        return;
    }
    if (actionSheet.tag == DRAW_OPTION_SHEET_TAG) {
        switch ([self fixDrawOptionIndex:buttonIndex]) {
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
                [OfflineDrawViewController startDraw:[Word cusWordWithText:@""] fromController:self startController:self targetUid:nil];
            } break;
            case DrawOptionIndexContest: {
                [[ContestService defaultService] getContestListWithType:ContestListTypeRunning offset:0 limit:1 delegate:self];
                _isJoiningContest = YES;
            } break;
            default:
                break;
        }
    }
    if (actionSheet.tag == POP_OPTION_SHEET_TAG) {
        int* list = getPopOptionList();
        int count = getPopOptionCount();
        if (buttonIndex >= count) {
            return;
        }
        switch (list[buttonIndex]) {
            case PopOptionPK: {
                UIViewController* rc = [[[DrawRoomListController alloc] init] autorelease];
                [self.navigationController pushViewController:rc animated:YES];
            } break;
            case PopOptionSelf: {
                UserDetailViewController* us = [[UserDetailViewController alloc] initWithUserDetail:[SelfUserDetail createDetail]];
                //    UserSettingController *us = [[UserSettingController alloc] init];
                [self.navigationController pushViewController:us animated:YES];
                [us release];
            } break;
            case PopOptionNotice: {                
                
                BulletinView *v = [BulletinView createWithSuperController:self];
                CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kBulletin") customView:v style:CommonDialogStyleCross];
                [dialog showInView:self.view];
                
                [self updateAllBadge];
            } break;
            case PopOptionBbs: {
//                [[StatisticManager defaultManager] setBbsActionCount:0];
                BBSBoardController *bbs = [[BBSBoardController alloc] init];
                [self.navigationController pushViewController:bbs animated:YES];
                [bbs release];
            } break;
            case PopOptionIngot: {
                FreeIngotController* fc = [[[FreeIngotController alloc] init] autorelease];
                [self.navigationController pushViewController:fc animated:YES];
            } break;
            case PopOptionContest: {
                ContestController *cc = [[ContestController alloc] init];
                [self.navigationController pushViewController:cc animated:YES];
                [cc release];
            } break;
            case PopOptionShop: {
                StoreController *vc = [[[StoreController alloc] init] autorelease];
                [self.navigationController pushViewController:vc animated:YES];
            } break;
            case PopOptionMore: {
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
    sc.feedList = [self.currentTab dataList];    
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];
    
}

- (void)showFeed:(DrawFeed *)feed animatedWithTransition:(UIViewAnimationTransition)transition
{
    ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:feed scene:[UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:feed]];
    sc.feedList = [self.currentTab dataList];
    [self.navigationController pushViewController:sc animatedWithTransition:transition duration:1];
    [sc release];
}

- (void)didClickRankView:(RankView *)rankView
{
    if (![self isRegistered]) {
        [self toRegister];
        return;
    }
    [self hideOptionSheet];
//    [self performSelector:@selector(showFeed:) withObject:rankView.feed afterDelay:0.001];

    int index = [[self.currentTab dataList] indexOfObject:rankView.feed];
    [self showOpusImageBrower:index];

}


- (void)showOpusImageBrower:(int)index{
    
    OpusImageBrower *brower = [[[OpusImageBrower alloc] initWithFeedList:_tabManager.currentTab.dataList] autorelease];
    brower.delegate = self;
    [brower showInView:self.view];
    [brower setIndex:index];
}


- (void)brower:(OpusImageBrower *)brower didSelecteFeed:(DrawFeed *)feed{
    
    [self showFeed:feed animatedWithTransition:UIViewAnimationTransitionCurlUp];
}

//table view delegate





#define NORMAL_CELL_VIEW_NUMBER 3
#define WIDTH_SPACE 1

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
    
    if (count > NORMAL_CELL_VIEW_NUMBER) {
        count = count - (count % NORMAL_CELL_VIEW_NUMBER);
    }
    
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
//        if (isFirstRow) {
//            [playerView setRankFlag:i++];
//        }
        [cell.contentView addSubview:playerView];
        playerView.frame = CGRectMake(x, y, width, height);
        x += width + space;
    }
}

- (void)setFirstRankCell:(UITableViewCell *)cell WithFeed:(DrawFeed *)feed
{
    RankView *view = [RankView createRankView:self type:RankViewTypeFirst];
    [view setViewInfo:feed];
    [cell.contentView addSubview:view];
}

#define NORMAL_CELL_VIEW_NUMBER 3
#define WIDTH_SPACE 1

- (void)setSencodRankCell:(UITableViewCell *)cell
                WithFeed1:(DrawFeed *)feed1
                    feed2:(DrawFeed *)feed2
{
    RankView *view1 = [RankView createRankView:self type:RankViewTypeSecond];
    [view1 setViewInfo:feed1];
    RankView *view2 = [RankView createRankView:self type:RankViewTypeSecond];
    [view2 setViewInfo:feed2];
    [cell.contentView addSubview:view1];
    [cell.contentView addSubview:view2];
    
    CGFloat x2 = WIDTH_SPACE + [RankView widthForRankViewType:RankViewTypeSecond];
    view2.frame = CGRectMake(x2, 0, view2.frame.size.width, view2.frame.size.height);
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
        if ([view isKindOfClass:[RankView class]] || [view isKindOfClass:[TopPlayerView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger type = self.currentTab.tabID;
    
    if ([self typeFromTabID:type] == LittleGeeHomeGalleryTypeWeekly) {
        if (indexPath.row == 0) {
            return [RankView heightForRankViewType:RankViewTypeFirst]+1;
        }else if(indexPath.row == 1){
            return [RankView heightForRankViewType:RankViewTypeSecond]+1;
        }
    }
    return [RankView heightForRankViewType:RankViewTypeNormal]+1;
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
   TableTab *tab = [self currentTab];
    if([self typeFromTabID:tab.tabID] == LittleGeeHomeGalleryTypePainter){
        [self setTopPlayerCell:cell WithPlayers:list isFirstRow:(indexPath.row == 0)];
    } else  if ([self typeFromTabID:tab.tabID] == LittleGeeHomeGalleryTypeWeekly) {
        if (indexPath.row == 0) {
            DrawFeed *feed = (DrawFeed *)[self saveGetObjectForIndex:0];
            [self setFirstRankCell:cell WithFeed:feed];
        }else if(indexPath.row == 1){
            DrawFeed *feed1 = (DrawFeed *)[self saveGetObjectForIndex:1];
            DrawFeed *feed2 = (DrawFeed *)[self saveGetObjectForIndex:2];
            [self setSencodRankCell:cell WithFeed1:feed1 feed2:feed2];
        }else{
            NSInteger startIndex = ((indexPath.row - 1) * NORMAL_CELL_VIEW_NUMBER);
            NSMutableArray *list = [NSMutableArray array];
            for (NSInteger i = startIndex; i < startIndex+NORMAL_CELL_VIEW_NUMBER; ++ i) {
                NSObject *object = [self saveGetObjectForIndex:i];
                if (object) {
                    [list addObject:object];
                }
            }
            //            PPDebug(@"startIndex = %d,list count = %d",startIndex,[list count]);
            [self setNormalRankCell:cell WithFeeds:list];
        }
        
    }
    else {
        [self setNormalRankCell:cell WithFeeds:list];
    }
    
    
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
        case FeedListTypeHistoryRank: {
            littleGeeType = LittleGeeHomeGalleryTypeAnnual;
        } break;
        case FeedListTypeHot: {
            littleGeeType = LittleGeeHomeGalleryTypeWeekly;
        } break;
        case FeedListTypeLatest: {
            littleGeeType = LittleGeeHomeGalleryTypeLatest;
        } break;
        case FeedListTypeRecommend: {
            littleGeeType = LittleGeeHomeGalleryTypeRecommend;
        } break;
        case FeedListTypeTopPlayer: {
            littleGeeType = LittleGeeHomeGalleryTypePainter;
        } break;
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
    return LittleGeeHomeGalleryTypeWeekly;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index //default 20
{
    return [ConfigManager getHotOpusCountOnce];
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    
    int types[] = {
        LittleGeeHomeGalleryTypeAnnual,
        LittleGeeHomeGalleryTypeWeekly,
        LittleGeeHomeGalleryTypeLatest,
        LittleGeeHomeGalleryTypeRecommend,
        LittleGeeHomeGalleryTypePainter};
    
    return [self tabIDFromType:types[index]];
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *titles[] = {NSLS(@"kRankHistory"),NSLS(@"kRankHot"),NSLS(@"kRankNew"),NSLS(@"kLittleGeeRecommend"),NSLS(@"kPainter")};
    return titles[index];
}

- (FeedListType)feedListTypeForTabID:(int)tabID
{
    int type = [self typeFromTabID:tabID];
    switch (type) {
        case LittleGeeHomeGalleryTypeLatest:
            return FeedListTypeLatest;

        case LittleGeeHomeGalleryTypeAnnual:
            return FeedListTypeHistoryRank;

        case LittleGeeHomeGalleryTypeWeekly:
            return FeedListTypeHot;

        case LittleGeeHomeGalleryTypeRecommend:
            return FeedListTypeRecommend;

        default:
            return tabID;
    }
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    [self showActivityWithText:NSLS(@"kLoading")];
    TableTab *tab = [_tabManager tabForID:tabID];
    if (tab) {
        int type = [self typeFromTabID:tabID];
        
        if (type == LittleGeeHomeGalleryTypeLatest) {
            [[FeedService defaultService] getFeedList:FeedListTypeLatest offset:tab.offset limit:tab.limit delegate:self];
        }else if(type == LittleGeeHomeGalleryTypePainter){
            [[UserService defaultService] getTopPlayerByScore:tab.offset limit:tab.limit delegate:self];
        }else if (type == LittleGeeHomeGalleryTypeAnnual) {
            [[FeedService defaultService] getFeedList:FeedListTypeHistoryRank offset:tab.offset limit:tab.limit delegate:self];
        }else if (type == LittleGeeHomeGalleryTypeWeekly) {
            [[FeedService defaultService] getFeedList:FeedListTypeHot offset:tab.offset limit:tab.limit delegate:self];
        }
        else if (type == LittleGeeHomeGalleryTypeRecommend){
            [[FeedService defaultService] getFeedList:FeedListTypeRecommend offset:tab.offset limit:tab.limit delegate:self];
        }else {
//            [[FeedService defaultService] getFeedList:[self feedListTypeForTabID:tabID] offset:tab.offset limit:tab.limit delegate:self];
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
//        for (DrawFeed *feed in feedList) {
            //            PPDebug(@"%d: feedId = %@, word = %@", i++, feed.feedId,feed.wordText);
//        }
        [self finishLoadDataForTabID:[self tabIDFromType:[self littleGeeTypeFromFeedListType:type]] resultList:feedList];
    }else{
        [self failLoadDataForTabID:[self tabIDFromType:[self littleGeeTypeFromFeedListType:type]]];
    }
    

}

- (void)didGetTopPlayerList:(NSArray *)playerList
                 resultCode:(NSInteger)resultCode
{
    PPDebug(@"<didGetTopPlayerList> list count = %d ", [playerList count]);
    [self hideActivity];
    if (resultCode == 0) {
        [self finishLoadDataForTabID:[self tabIDFromType:LittleGeeHomeGalleryTypePainter] resultList:playerList];
    }else{
        [self failLoadDataForTabID:[self tabIDFromType:LittleGeeHomeGalleryTypePainter]];
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
        float radius = sqrtf((btn.frame.size.height*btn.frame.size.height) + (0.5*btn.frame.size.width*0.5*btn.frame.size.width));
        [self initDrawOptions];
        [self.drawOptionSheet expandInView:self.view onView:btn fromAngle:(-M_PI*0.3) toAngle:(M_PI*0.3) radius:radius itemSize:ITEM_SIZE];
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
    [OfflineDrawViewController startDraw:[Word cusWordWithText:@""] fromController:self startController:self targetUid:aFriend.friendUserId];
}

- (void)viewDidUnload {
    [self setDrawOptionBtn:nil];
    [self setBigPen:nil];
    [self setTestBtn:nil];
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
    
    long timelineCount = manager.timelineOpusCount + manager.timelineGuessCount + manager.commentCount + manager.drawToMeCount;
    
    PPDebug(@"<LittleGee-updateAllBadge> update timelineOpus count = %d, comment count = %d, draw to me count = %d", manager.timelineOpusCount, manager.commentCount, manager.drawToMeCount);
    
    [self updateBadgeWithType:HomeMenuTypeLittleGeeFeed badge:timelineCount];
    
    int optionCount;
    if ([[UserManager defaultManager] getLanguageType] != ChineseType) {
        optionCount = manager.bulletinCount;
        [_optionSheet setBadgeCount:[[StatisticManager defaultManager] bulletinCount] forIndex:[self indexForPopOption:PopOptionNotice]];
    } else {
        optionCount = manager.bbsActionCount + manager.bulletinCount + manager.newContestCount;
        [_optionSheet setBadgeCount:[[StatisticManager defaultManager] bulletinCount] forIndex:[self indexForPopOption:PopOptionNotice]];
        [_optionSheet setBadgeCount:[[StatisticManager defaultManager] bbsActionCount] forIndex:[self indexForPopOption:PopOptionBbs]];
        [_optionSheet setBadgeCount:[[StatisticManager defaultManager] newContestCount] forIndex:[self indexForPopOption:PopOptionContest]];
    }
    
    [self updateBadgeWithType:HomeMenuTypeLittleGeeOptions badge:optionCount];
//    [self.homeHeaderPanel updateBulletinBadge:[manager bulletinCount]];
    
}

- (void)didSyncStatisticWithResultCode:(int)resultCode
{
//    _hasLoadStatistic = YES;
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
        POSTMSG(NSLS(@"kNetworkBroken"));
    }
}

- (void)registerNetworkDisconnectedNotification
{
    [self registerNotificationWithName:NOTIFICATION_NETWORK_DISCONNECTED
                            usingBlock:^(NSNotification *note) {
                                [self handleDisconnectWithError:[CommonGameNetworkService userInfoToError:note.userInfo]];
                            }];
}

#pragma mark - draw home controller protocol
- (BOOL)isRegistered
{
    return ([[UserManager defaultManager] hasUser]); // && [[UserManager defaultManager] hasXiaojiNumber]);
}

- (BOOL)toRegister
{
//    RegisterUserController *ruc = [[RegisterUserController alloc] init];
//    [self.navigationController pushViewController:ruc animated:YES];
//    [ruc release];

    // change by Benson for new xiaoji number login and logout
    return [[UserService defaultService] checkAndAskLogin:self.view];
}

#pragma mark - contest service delegate
- (void)didGetContestList:(NSArray *)contestList type:(ContestListType)type resultCode:(NSInteger)code
{
    if (code == 0) {
        [[StatisticManager defaultManager] setNewContestCount:[[ContestManager defaultManager] calNewContestCount:contestList]];
    }
    [self updateAllBadge];
    
    if (_isJoiningContest) {
        _isJoiningContest = NO;
        if (contestList == nil || contestList.count == 0) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNoRunningContest") delayTime:2 isHappy:NO];
            return;
        }
        Contest* contest = [contestList objectAtIndex:0];
        if ([contest joined]) {
            [OfflineDrawViewController startDrawWithContest:contest fromController:self startController:self animated:YES];
        } else {
            StatementController *sc = [[StatementController alloc] initWithContest:contest];
            sc.superController = self;
            [self.navigationController pushViewController:sc animated:YES];
            [sc release];
        }
    }
    
}

- (void)didClickTopPlayerView:(TopPlayerView *)topPlayerView
{
    [self hideOptionSheet];
    TopPlayer *player = topPlayerView.topPlayer;
    
    [UserDetailViewController presentUserDetail:[ViewUserDetail viewUserDetailWithUserId:player.userId avatar:player.avatar nickName:player.nickName] inViewController:self];
}

#pragma mark - customize refresh header and footer
- (EGORefreshTableHeaderView*)createRefreshHeaderView
{
    return [[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.dataTableView.bounds.size.height, self.dataTableView.frame.size.width, self.dataTableView.bounds.size.height) backgroundColor:[UIColor clearColor] textColor:OPAQUE_COLOR(37, 161, 126)] autorelease];
}

- (EGORefreshTableFooterView*)createRefreshFooterView
{
    return [[[EGORefreshTableFooterView alloc] initWithFrame: CGRectMake(0.0f, self.dataTableView.contentSize.height, self.dataTableView.frame.size.width, 650) backgroundColor:[UIColor clearColor] textColor:OPAQUE_COLOR(37, 161, 126)] autorelease];
}

+ (LittleGeeHomeController*)defaultInstance
{
    DrawAppDelegate* app = (DrawAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (app.homeController == nil){
        app.homeController = [[[LittleGeeHomeController alloc] init] autorelease];
    }
    
    return (LittleGeeHomeController*)app.homeController;
}

- (IBAction)clickTest:(id)sender
{
    Class class = NSClassFromString(@"SearchPhotoController");
    UIViewController* vc = [[[class alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
