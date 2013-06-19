//
//  OpusManageController.n
//  Draw
//
//  Created by Orange on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OpusManageController.h"
#import "LocaleUtils.h"
#import "ShareEditController.h"
#import "MyPaint.h"
#import "DrawAction.h"
#import "ShareCell.h"
#import "UserManager.h"
#import "ReplayController.h"
#import "GifView.h"
#import "PPDebug.h"
#import "ShareImageManager.h"
#import "CommonDialog.h"
#import "ConfigManager.h"
#import "FileUtil.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "OfflineDrawViewController.h"
#import "TableTab.h"
#import "TableTabManager.h"
#import "UIImageExt.h"
#import "OfflineDrawViewController.h"
#import "ReplayView.h"
#import "SaveToContactPickerView.h"

#define BUTTON_INDEX_OFFSET 20120229
#define IMAGE_WIDTH 93

#define IMAGE_OPTION            20120407
#define FROM_WEIXIN_OPTION      20130116

#define DREAM_AVATAR_OPTION     20130506
#define DREAM_LOCKSCREEN_OPTION 20130509

#define LOAD_PAINT_LIMIT 20


typedef enum{
    TabTypeMine = 100,
    TabTypeAll = 101,
    TabTypeDraft = 102,
}TabType;

@interface OpusManageController () {
    BOOL isLoading;
}
@end

@implementation OpusManageController
@synthesize clearButton;
@synthesize titleLabel;
@synthesize awardCoinTips;
@synthesize backButton;
@synthesize fromWeiXin = _fromWeiXin;

- (void)dealloc {
    PPRelease(clearButton);
    PPRelease(awardCoinTips);
    PPRelease(backButton);
    [super dealloc];
}

- (void)reloadView
{
    [self.dataTableView reloadData];
    if ([self.paints count] != 0) {
//        self.awardCoinTips.text = [NSString stringWithFormat:NSLS(@"kShareAwardCoinTips"),[ConfigManager getShareWeiboReward]];
        self.awardCoinTips.text = @"";
        [self.clearButton setHidden:NO];
    }else{
        self.awardCoinTips.text = NSLS(@"kNoDrawings");
        [self.clearButton setHidden:YES];
    }
}

- (void)updateTab:(NSArray *)paints
{
    if ([paints count] < self.currentTab.limit) {
        self.currentTab.hasMoreData = NO;
    }
    isLoading = NO;   
    self.noDataTipLabl.hidden = NO;
}

#pragma mark - MyPaintManager Delegate
- (void)didGetAllPaints:(NSArray *)paints
{
    [self finishLoadDataForTabID:TabTypeAll resultList:paints];
    
    [self hideActivity];
    [self reloadView];
    [self updateTab:paints];
}
- (void)didGetMyPaints:(NSArray *)paints
{
    [self finishLoadDataForTabID:TabTypeMine resultList:paints];
    
    [self hideActivity];
    [self reloadView];
    [self updateTab:paints];
}

- (void)didGetAllDrafts:(NSArray *)paints
{
    [self finishLoadDataForTabID:TabTypeDraft resultList:paints];
    
    [self hideActivity];
    [self reloadView];
    [self updateTab:paints];
}

- (void)didGetAllPaintCount:(NSInteger)allPaintCount
               myPaintCount:(NSInteger)myPaintCount
                 draftCount:(NSInteger)draftCount
{
    UIButton *draftButton = (UIButton *)[self.view viewWithTag:TabTypeDraft];
    NSString *draftTitle = [NSString stringWithFormat:@"%@(%d)", NSLS(@"kDraft"), draftCount];
    [draftButton setTitle:draftTitle forState:UIControlStateNormal];
    
    UIButton *myButton = (UIButton *)[self.view viewWithTag:TabTypeMine];
    NSString *myTitle = [NSString stringWithFormat:@"%@(%d)", NSLS(@"kMine"), myPaintCount];
    [myButton setTitle:myTitle forState:UIControlStateNormal];
    
    UIButton *allButton = (UIButton *)[self.view viewWithTag:TabTypeAll];
    NSString *allTitle = [NSString stringWithFormat:@"%@(%d)", NSLS(@"kAll"), allPaintCount];
    [allButton setTitle:allTitle forState:UIControlStateNormal];
}

- (void)performLoadMyPaints
{
//    TableTab *tab = [_tabManager tabForID:TabTypeMine];
//    [_myPaintManager findMyPaintsFrom:tab.offset limit:tab.limit delegate:self];
    [self hideActivity];
}

- (void)performLoadAllPaints
{
//    TableTab *tab = [_tabManager tabForID:TabTypeAll];
//    [_myPaintManager findAllPaintsFrom:tab.offset limit:tab.limit delegate:self];
    [self hideActivity];
}

- (void)loadPaintsOnlyMine:(BOOL)onlyMine
{
    [self showActivityWithText:NSLS(@"kLoading")];
    if (onlyMine) {
        [self performSelector:@selector(performLoadMyPaints) withObject:nil afterDelay:0.3f];
    } else {
        [self performSelector:@selector(performLoadAllPaints) withObject:nil afterDelay:0.3f];
    }
}

- (void)performLoadDrafts
{
//    TableTab *tab = [_tabManager tabForID:TabTypeDraft];
//    [_myPaintManager findAllDraftsFrom:tab.offset limit:tab.limit delegate:self];
    [self hideActivity];
}

// db.bulletin.insert({"date":new Date(), "type":0, "game_id":"Draw","function":"","content":"[公告] 近期发现部分用户反复使用草稿发同一副作品，影响画榜。先明令禁止此种行为，发现一律直接删除，严重违反者直接封号"});

- (void)loadDrafts
{
//    TableTab *tab = [_tabManager tabForID:TabTypeDraft];
//    if (tab.status == TableTabStatusLoading) {
//        return;
//    }
    [self showActivityWithText:NSLS(@"kLoading")];
    [self performSelector:@selector(performLoadDrafts) withObject:nil afterDelay:0.3f];
}

//- (void)loadDrafts
//{
//    [self loadDraftsShouldShowLoading:YES];
//}

#define TITLE_RECOVERY        NSLS(@"kRecovery")
#define TITLE_EDIT            NSLS(@"kEdit")
#define TITLE_SAVE_TO_ALBUM   NSLS(@"kDreamAvatarSaveToAlbum")
#define TITLE_SAVE_TO_CONTACT NSLS(@"kDreamAvatarSaveToContact")
#define TITLE_DELETE          NSLS(@"kDelete")

#define DREAM_AVATAR_TITLES  TITLE_SAVE_TO_ALBUM, TITLE_SAVE_TO_CONTACT, TITLE_DELETE, nil
- (void)didSelectPaintInDreamAvatar
{
  
}

- (void)didSelectPaintInDreamLockscreen
{    
    
}

#pragma mark - Share Cell Delegate
- (void)didSelectPaint:(MyPaint *)paint
{
    
   
    
}

#pragma mark - UIActionSheetDelegate

- (void)showViewController:(UIViewController*)controller
{
    [self.navigationController presentModalViewController:controller animated:YES];
}


- (void)weixinActionSheet:(UIActionSheet *)actionSheet
     clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case FromWeixinOptionShareOpus: {
        } break;
        case FromWeixinOptionDrawAPicture: {
//            OfflineDrawViewController *odc = [[OfflineDrawViewController alloc] initWithTargetType:TypeGraffiti delegate:self];
//            odc.startController = self;
//            [self.navigationController pushViewController:odc animated:YES];
//            [odc release];
        } break;
        default:
            break;
    }
}

- (void)performReplay
{
    
}

- (void)performEdit
{
    
}

- (void)imageActionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

- (void)dreamAvatarActionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}


- (void)dreamLockscreenActionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}




#pragma mark - table view delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ShareCell getCellHeight];
        
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int number = 0;
    if (self.paints.count % IMAGES_PER_LINE == 0){
        number = self.paints.count / IMAGES_PER_LINE;
    }
    else{
        number = self.paints.count / IMAGES_PER_LINE + 1;
    }
    return number;
}

- (NSArray *)paints
{
    return [self tabDataList];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShareCell* cell = [tableView dequeueReusableCellWithIdentifier:[ShareCell getIdentifier]];
    if (cell == nil) {
//        cell = [ShareCell creatShareCellWithIndexPath:indexPath delegate:self];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSMutableArray* myPaintArray = [NSMutableArray array];

    NSAutoreleasePool* loopPool = [[NSAutoreleasePool alloc] init];
    for (int lineIndex = 0; lineIndex < IMAGES_PER_LINE; lineIndex++) {
        int paintIndex = indexPath.row*IMAGES_PER_LINE + lineIndex;
        if (paintIndex < self.paints.count) {
            MyPaint* paint  = [self.paints objectAtIndex:paintIndex]; 
            [myPaintArray addObject:paint];                
        }
    }
    [loopPool release];

    cell.indexPath = indexPath;
    [cell setPaints:myPaintArray];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    int number = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    if (row == number - 1) {
        TableTab *tab = self.currentTab;
        if (!isLoading && tab.hasMoreData && tab.status != TableTabStatusLoading) {
            [self serviceLoadDataForTabID:tab.tabID];
            PPDebug(@"service load opus, tab id = %d", tab.tabID);
        }
    }
}


- (IBAction)deleteAll:(id)sender
{
    
}

-(IBAction)clickBackButton:(id)sender
{
//    self.shareAction = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isMineTab
{
    return self.currentTab.tabID == TabTypeMine;
}
- (BOOL)isAllTab
{
    return self.currentTab.tabID == TabTypeAll;    
}
- (BOOL)isDraftTab
{
    return self.currentTab.tabID == TabTypeDraft;
}


- (void)updateActionSheetIndexs
{
    
    
}


- (id)init
{
    self = [super init];
    if (self) {
        _defaultTabIndex = 1;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [self setFromWeiXin:NO];

    }
    return self;
}

- (void)showChooseWeixinOptionActionSheet
{

}

- (void)initTabButtons
{
    
//    switch ([self currentTab].tabID) {
//        case TabTypeDraft:
//            //
//            break;
//            
//        default:
//            break;
//    }
//    [self loadDrafts];
//    [self loadPaintsOnlyMine:YES];
//    [self loadPaintsOnlyMine:NO];
    [super initTabButtons];
    
    if ([GameApp showPaintCategory] == NO){
        UIButton *mineButton = (UIButton *)[self.view viewWithTag:TabTypeMine];
        UIButton *allButton = (UIButton *)[self.view viewWithTag:TabTypeAll];
        UIButton *draftButton = (UIButton *)[self.view viewWithTag:TabTypeDraft];
        mineButton.hidden = YES;
        allButton.hidden = YES;
        draftButton.hidden = YES;
        
        [self.dataTableView updateOriginY:self.dataTableView.frame.origin.y - mineButton.frame.size.height];
        [self.dataTableView updateHeight:self.dataTableView.frame.size.height + mineButton.frame.size.height];
    }
}


- (void)viewDidLoad
{
    [self setPullRefreshType:PullRefreshTypeNone];
    [super viewDidLoad]; 

    [self initTabButtons];
    UIButton *allButton = [self tabButtonWithTabID:TabTypeAll];
    

    if (self.isFromWeiXin) {
        [self.clearButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];        
        self.backButton.hidden = YES;
        self.awardCoinTips.hidden = YES;
        self.titleLabel.text = NSLS(@"kShareToWeiXinTitle");
        
        //update the table view frame
        CGFloat x = self.dataTableView.frame.origin.x;
        CGFloat y = self.dataTableView.frame.origin.y;
        CGFloat width = self.dataTableView.frame.size.width;
        CGFloat height = self.dataTableView.frame.size.height;
        CGFloat ny = allButton.frame.origin.y  + allButton.frame.size.height * 1.2 ;
        CGFloat nHeight = height + (y - ny);
        
        [self.dataTableView setFrame:CGRectMake(x, ny, width, nHeight)];
        
        [self showChooseWeixinOptionActionSheet];
    }else{
//        [self.clearButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
        [self.clearButton setTitle:NSLS(@"kClear") forState:UIControlStateNormal];
        self.titleLabel.text = NSLS(@"kShareTitle");
    }

    
}

- (void)viewDidUnload
{
    [self setClearButton:nil];
    [self setTitleLabel:nil];
    [self setAwardCoinTips:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




- (void)viewDidAppear:(BOOL)animated
{
//    if (self.isDraftTab) {
//        TableTab *tab = [self currentTab];
//        tab.offset = 0;
//        [tab.dataList removeAllObjects];
//        [self loadDrafts];
//    }
    [super viewDidAppear:animated];
    [self clickRefreshButton:nil];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_tabManager reset];
    [self.dataTableView reloadData];
}

#pragma mark common tab controller

- (NSInteger)tabCount
{
    return 3;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 32;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabId[] = {TabTypeMine,TabTypeAll,TabTypeDraft};
    return tabId[index];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
//    NSString *tabDesc[] = {NSLS(@"kNoMyFeed"),NSLS(@"kNoMyOpus"),NSLS(@"kNoMyComment"),NSLS(@"kNoDrawToMe")};
    
    return NSLS(@"NoData");
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *tabTitle[] = {NSLS(@"kMine"),NSLS(@"kAll"),NSLS(@"kDraft")};
    return tabTitle[index];
    
}

- (void)clickTabButton:(id)sender
{
    [super clickTabButton:sender];
    [self updateActionSheetIndexs];
    [self reloadView];
}


- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    [self reloadView];
    TableTab *tab = [_tabManager tabForID:tabID];
    if (tab) {
        isLoading = YES;
        self.noDataTipLabl.hidden = YES;
        switch (tabID) {
            case TabTypeMine:
                [self loadPaintsOnlyMine:YES];
                break;
            case TabTypeAll:
            {
                [self loadPaintsOnlyMine:NO];
                break;
            }
                
            case TabTypeDraft: //for test
            {
                [self loadDrafts];
                break;
            }
            default:
                
                [self hideActivity];
                break;
        }
        
    }
}

+ (void)shareFromWeiXin:(UIViewController *)superController
{
    OpusManageController* share = [[[OpusManageController alloc] init ] autorelease];
    [share setFromWeiXin:YES];
    [superController.navigationController pushViewController:share animated:YES];
}
@end
