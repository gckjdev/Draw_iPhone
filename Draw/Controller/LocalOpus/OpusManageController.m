//
//  OpusManageController.n
//  Draw
//
//  Created by Orange on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OpusManageController.h"
#import "LocaleUtils.h"
#import "UserManager.h"
#import "PPDebug.h"
#import "ShareImageManager.h"
#import "CommonDialog.h"
#import "PPConfigManager.h"
#import "FileUtil.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "TableTab.h"
#import "TableTabManager.h"
#import "UIImageExt.h"
#import "MKBlockActionSheet.h"

#import "OpusManager.h"
#import "OpusService.h"
#import "OpusView.h"
#import "Opus.h"
#import "FeedService.h"
#import "MKBlockAlertView.h"
#import "UseItemScene.h"
#import "ShowFeedController.h"

#define BUTTON_INDEX_OFFSET 20120229
#define IMAGE_WIDTH 93

#define IMAGE_OPTION            20120407
#define FROM_WEIXIN_OPTION      20130116

#define DREAM_AVATAR_OPTION     20130506
#define DREAM_LOCKSCREEN_OPTION 20130509

#define LOAD_PAINT_LIMIT 20


typedef enum{
    TabTypeMine = 100,
    TabTypeFavorite = 101,
    TabTypeDraft = 102,
}TabType;

typedef enum {
    OpusOptionEdit = 0,
    OpusOptionShare,
    OpusOptionReplay,
    OpusOptionDelete,
}OpusOption;

@interface OpusManageController () <OpusViewDelegate, UIActionSheetDelegate, FeedServiceDelegate>{
    BOOL isLoading;
}

@property (assign, nonatomic) OpusManager* selfOpusManager;
@property (assign, nonatomic) OpusManager* favoriteManager;
@property (assign, nonatomic) OpusManager* draftManager;

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

- (id)initWithClass:(Class)aClass
             selfDb:(NSString *)selfDb
         favoriteDb:(NSString *)favoriteDb
            draftDb:(NSString *)draftDb
{
    self = [super init];
    if (self) {
        self.selfOpusManager = [[OpusService defaultService] myOpusManager];
        self.favoriteManager = [[OpusService defaultService] favoriteOpusManager];
        self.draftManager = [[OpusService defaultService] draftOpusManager];
    }
    return self;
}

- (void)reloadView
{
    [self.dataTableView reloadData];
    if ([[self getOpusList] count] != 0) {
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

#define CELL_HEIGHT ([DeviceDetection isIPAD]?189.4:94.7)
#define OPUS_VIEW_WIDTH ([DeviceDetection isIPAD]?150:75)
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [super tableView:tableView numberOfRowsInSection:section];
    
    int number = 0;
    
    if ([self getOpusList].count % IMAGES_PER_LINE == 0){
        number = [self getOpusList].count / IMAGES_PER_LINE;
    }
    else{
        number = [self getOpusList].count / IMAGES_PER_LINE + 1;
    }
    
    return number;
}

- (NSArray*)getOpusList
{
    return [self tabDataList];
}

#define OPUS_VIEW_TAG_OFFSET   120130619
#define VIEW_PER_LINE   4

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        float sep = (tableView.frame.size.width/VIEW_PER_LINE - OPUS_VIEW_WIDTH)/2;
        for (int i = 0; i < VIEW_PER_LINE; i ++) {
            OpusView* view = [OpusView createOpusView:self];
            [view setFrame:CGRectMake(i*tableView.frame.size.width/VIEW_PER_LINE+sep, 0, OPUS_VIEW_WIDTH, CELL_HEIGHT)];
            view.tag = OPUS_VIEW_TAG_OFFSET + i;
            [cell.contentView addSubview:view];
        }
    }
    
    for (int i = 0; i < VIEW_PER_LINE; i ++) {
        OpusView* view = (OpusView*)[cell viewWithTag:(OPUS_VIEW_TAG_OFFSET+i)];
        if (indexPath.row*VIEW_PER_LINE + i < [[self getOpusList] count]) {
            
            if (self.currentTab.tabID == TabTypeMine || self.currentTab.tabID == TabTypeFavorite) {
                DrawFeed* feed = [[self getOpusList] objectAtIndex:(indexPath.row*VIEW_PER_LINE + i)];
                [view updateWithFeed:feed];
                [view setIsDraft:NO];
            }else{
                Opus* opus = [[self getOpusList] objectAtIndex:(indexPath.row*VIEW_PER_LINE + i)];
                [view updateWithOpus:opus];
                [view setIsDraft:YES];
            }
            
            [view setHidden:NO];
        } else {
            [view setHidden:YES];
        }
    }

    return cell;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    int row = indexPath.row;
//    int number = [self tableView:tableView numberOfRowsInSection:indexPath.section];
//    if (row == number - 1) {
//        TableTab *tab = self.currentTab;
//        if (!isLoading && tab.hasMoreData && tab.status != TableTabStatusLoading) {
//            [self serviceLoadDataForTabID:tab.tabID];
//            PPDebug(@"service load opus, tab id = %d", tab.tabID);
//        }
//    }
//}

//- (OpusManager*)managerForTab:(TabType)tabType
//{
//    switch (tabType) {
//        case TabTypeFavorite: {
//            return self.favoriteManager;
//        };
//        case TabTypeMine: {
//            return self.selfOpusManager;
//        };
//        case TabTypeDraft: {
//            return self.draftManager;
//        }
//            
//        default:
//            break;
//    }
//    return nil;
//}

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

- (void)initTabButtons
{
    if ([GameApp showPaintCategory] == NO){
        UIButton *mineButton = (UIButton *)[self.view viewWithTag:TabTypeMine];
        UIButton *allButton = (UIButton *)[self.view viewWithTag:TabTypeFavorite];
        UIButton *draftButton = (UIButton *)[self.view viewWithTag:TabTypeDraft];
        mineButton.hidden = YES;
        allButton.hidden = YES;
        draftButton.hidden = YES;
        
        [self.dataTableView updateOriginY:self.dataTableView.frame.origin.y - mineButton.frame.size.height];
        [self.dataTableView updateHeight:self.dataTableView.frame.size.height + mineButton.frame.size.height];
    }
    [super initTabButtons];    
}

- (void)viewDidLoad
{
//    [self setPullRefreshType:PullRefreshTypeNone];
    [self setPullRefreshType:PullRefreshTypeBoth];
    _defaultTabIndex = 2;
    [super viewDidLoad]; 

    [self initTabButtons];
    
    CommonTitleView *v = [CommonTitleView createTitleView:self.view];
    [v setTarget:self];

    if (self.isFromWeiXin) {
        self.awardCoinTips.hidden = YES;
        [v setRightButtonTitle:NSLS(@"kCancel")];
        [v setTitle:NSLS(@"kShareToWeiXinTitle")];
    }else{
        [v setTitle:NSLS(@"kOpusSet")];
        [v setBackButtonSelector:@selector(clickBackButton:)];
    }
    
    SET_COMMON_TAB_TABLE_VIEW_Y(self.dataTableView);
}

- (void)viewDidUnload
{
    [self setClearButton:nil];
    [self setTitleLabel:nil];
    [self setAwardCoinTips:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    [self clickRefreshButton:nil];
//}
//
//- (void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//    [_tabManager reset];
//    [self.dataTableView reloadData];
//}

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
    NSInteger tabId[] = {TabTypeMine,TabTypeFavorite,TabTypeDraft};
    return tabId[index];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    
    return NSLS(@"kNoData");
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *tabTitle[] = {NSLS(@"kMine"),NSLS(@"kFavorite"),NSLS(@"kDraft")};
    return tabTitle[index];
    
}

- (void)clickTabButton:(id)sender
{
    [super clickTabButton:sender];
    [self reloadView];
}


- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    TableTab *tab = [_tabManager tabForID:tabID];

    GetFeedListCompleteBlock completed = ^(int resultCode, NSArray *feedList) {
        
        [self finishLoadDataForTabID:tabID resultList:feedList];
    };
    
    if (tabID == TabTypeMine){
        
        [[FeedService defaultService] getUserOpusList:[[UserManager defaultManager] userId]
                                               offset:tab.offset
                                                limit:tab.limit
                                                 type:FeedListTypeUserOpus
                                            completed:completed];
        
    }else if(tabID == TabTypeFavorite) {
        
        [[FeedService defaultService] getUserOpusList:[[UserManager defaultManager] userId]
                                               offset:tab.offset
                                                limit:tab.limit
                                                 type:FeedListTypeUserFavorite
                                            completed:completed];
        
    }else if (tabID == TabTypeDraft){
        
        [self showActivityWithText:NSLS(@"kLoading")];
        NSArray* array = [self.draftManager findAllOpusWithOffset:tab.offset limit:tab.limit];
        [self finishLoadDataForTabID:tab.tabID resultList:array];
        [self updateTab:array];
        [self reloadView];
        [self hideActivity];
    }
}



#pragma mark - OpusViewDelegate

- (void)didClickOpus:(Opus*)opus{
    
    PPDebug(@"<test>did click opus %@", opus.pbOpus.name);
    
    MKBlockActionSheet* tips = nil;
    
    NSString* editString = NSLS(@"kRecovery");
    NSString *shareString = NSLS(@"kShare");
    
    tips = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOptions")
                                            delegate:nil
                                   cancelButtonTitle:NSLS(@"kCancel")
                              destructiveButtonTitle:nil
                                   otherButtonTitles:editString, /*shareString, */ NSLS(@"kDelete"), nil];
    
    tips.actionBlock = ^(NSInteger buttonIndex){
        
        switch (buttonIndex) {
                
            case 0:
                [self editDraft:opus];
                break;
                
            case 1:
                [self deleteDraft:opus];
                break;
                
            default:
                break;
        }
    };
    
    [tips showInView:self.view];
    [tips release];
}


- (void)editDraft:(Opus *)opus{
    
    [opus enterEditFromController:self];
}

- (void)deleteDraft:(Opus *)opus{
    
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSure_delete")
                                                       message:NSLS(@"kAre_you_sure")
                                                         style:CommonDialogStyleDoubleButton];
    [dialog setClickOkBlock:^(UILabel *label){
        [[self draftManager] deleteOpus:opus.pbOpus.opusId];
        [self reloadTableViewDataSource];
    }];

    [dialog showInView:self.view];
}


- (void)didClickFeed:(DrawFeed *)feed {
    
    PPDebug(@"<test>did click opus %@", feed.wordText);
    
    MKBlockActionSheet* tips = nil;
    
    NSString *shareString = NSLS(@"kShare");
    
    if (self.currentTab.tabID == TabTypeMine) {
        tips = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOptions")
                                                delegate:self
                                       cancelButtonTitle:NSLS(@"kCancel")
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:/*shareString,*/ NSLS(@"kLook"), NSLS(@"kDelete"), nil];
        
        tips.actionBlock = ^(NSInteger buttonIndex){
            
            switch (buttonIndex) {
                    
                case 0:
                    [self enterOpusDetail:feed];
                    break;
                    
                case 1:
                    [self deleteOpus:feed];
                    break;
                    
                default:
                    break;
            }
        };
    }else{
        
        tips = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOptions")
                                                delegate:self
                                       cancelButtonTitle:NSLS(@"kCancel")
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:/*shareString,*/ NSLS(@"kLook"), NSLS(@"kUnFavorite"), nil];
        
        tips.actionBlock = ^(NSInteger buttonIndex){
            
            switch (buttonIndex) {
                    
                case 0:
                    [self enterOpusDetail:feed];
                    break;
                    
                case 1:
                    [self unFavoriteOpus:feed];
                    break;
                    
                default:
                    break;
            }
        };
    }

    
    [tips showInView:self.view];
    [tips release];
}

- (void)enterOpusDetail:(DrawFeed *)feed{
    
    UseItemScene *scene = [UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:feed];
    ShowFeedController *sf = [[ShowFeedController alloc] initWithFeed:feed
                                                                scene:scene];
    [self.navigationController pushViewController:sf animated:YES];
    [sf release];
}

- (void)deleteOpus:(DrawFeed *)feed{
    
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSure_delete")
                                                       message:NSLS(@"kAre_you_sure")
                                                         style:CommonDialogStyleDoubleButton];
    [dialog setClickOkBlock:^(UILabel *label){
        
        [self showActivityWithText:NSLS(@"kDeleting")];
        [[FeedService defaultService] deleteFeed:feed
                                        delegate:self];
    }];
    
    [dialog showInView:self.view];
    
}


- (void)didDeleteFeed:(Feed *)feed
           resultCode:(NSInteger)resultCode{
    
    [self hideActivity];

    if (resultCode == 0) {
        [self finishDeleteData:feed ForTabID:self.currentTab.tabID];
    }else{
        POSTMSG(NSLS(@"kDeleteFail"));
    }
}



- (void)unFavoriteOpus:(DrawFeed *)feed
{
    
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kUnFavorite")
                                                       message:NSLS(@"kAre_you_sure_to_unfavorite")
                                                         style:CommonDialogStyleDoubleButton];
    
    [dialog setClickOkBlock:^(UILabel *label){
        
        [self showActivityWithText:NSLS(@"kUnFavoriting")];
        [[FeedService defaultService] removeOpusFromFavorite:feed.feedId resultBlock:^(int resultCode) {
            
            [self hideActivity];
            
            if(resultCode == 0){
                [self finishDeleteData:feed ForTabID:self.currentTab.tabID];
            }else{
                POSTMSG(NSLS(@"kUnfavoriteFail"));
            }
        }];
    }];
    
    [dialog showInView:self.view];
}


- (OpusOption)optionIndex:(int)buttonIndex
                   forTab:(TabType)tabType
{
    if (tabType != TabTypeDraft) {
        return buttonIndex + 1;
    }
    return buttonIndex;
}

//- (OpusManager*)currentOpusManager
//{
//    return [self managerForTab:[self currentTab].tabID];
//}

//#pragma mark - actionsheet delegate
//
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    int index = [self optionIndex:buttonIndex forTab:[self currentTab].tabID];
//    __block OpusManageController* cp = self;
//    
//    switch (index) {
//        case OpusOptionEdit: {
//            [_currentSelectOpus enterEditFromController:self];
//        } break;
//        case OpusOptionShare: {
//            MKBlockActionSheet* actionSheet = [[[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kShare_Options") delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
//            NSArray* titleArray = [_currentSelectOpus shareOptionsTitleArray];
//            for (NSString* title in titleArray) {
//                [actionSheet addButtonWithTitle:title];
//            }
//            int cancelIndex = [actionSheet addButtonWithTitle:NSLS(@"kCancel")];
//            [actionSheet setCancelButtonIndex:cancelIndex];
//            [actionSheet setActionBlock:^(NSInteger buttonIndex){
//                if (buttonIndex == actionSheet.cancelButtonIndex) {
//                    return;
//                }
//                [_currentSelectOpus handleShareOptionAtIndex:buttonIndex fromController:cp];
//            }];
//            [actionSheet showInView:self.view];
//        } break;
//        case OpusOptionReplay: {
//            [_currentSelectOpus replayInController:self];
//        } break;
//        case OpusOptionDelete: {
//            
//            CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSure_delete")
//                                                               message:NSLS(@"kAre_you_sure")
//                                                                 style:CommonDialogStyleDoubleButton];
//            [dialog setClickOkBlock:^(UILabel *label){
//                [[cp currentOpusManager] deleteOpus:_currentSelectOpus.pbOpus.opusId];
//                [cp reloadTableViewDataSource];
//            }];
//
//                
//                [dialog showInView:self.view];
//            } break;
//        default:
//            break;
//    }
//}

+ (void)shareFromWeiXin:(UIViewController *)superController
{
    OpusManageController* share = [[[OpusManageController alloc] init ] autorelease];
    [share setFromWeiXin:YES];
    [superController.navigationController pushViewController:share animated:YES];
}

@end
