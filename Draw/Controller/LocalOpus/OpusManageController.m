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
#import "SingController.h"
#import "PPSNSConstants.h"
#import "ShareAction.h"
#import "GameSNSService.h"

#define BUTTON_INDEX_OFFSET 20120229
#define IMAGE_WIDTH 93

#define IMAGE_OPTION            20120407
#define FROM_WEIXIN_OPTION      20130116

#define DREAM_AVATAR_OPTION     20130506
#define DREAM_LOCKSCREEN_OPTION 20130509

#define LOAD_PAINT_LIMIT 20

typedef enum{
    
    OPUS_ACTION_EDIT = 0,
    OPUS_ACTION_DELETE,
    OPUS_ACTION_SHARE_SINA_WEIBO,
    OPUS_ACTION_SHARE_WEIXIN_SESSION,
    OPUS_ACTION_SHARE_WEIXIN_TIMELINE,
    OPUS_ACTION_SHARE_QQ_SPACE,
} OpusActionMenuType;


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
        [v setRightButtonTitle:NSLS(@"kAddChat")];
        [v setRightButtonSelector:@selector(clickCreateOpusButton:)];
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
        
        NSArray* array = [self.draftManager findAllOpusWithOffset:tab.offset limit:tab.limit];
        [self finishLoadDataForTabID:tab.tabID resultList:array];
        [self performSelector:@selector(hideRefreshHeaderAndFooter) withObject:nil afterDelay:0.5];
    }
}

- (void)hideRefreshHeaderAndFooter{
    
    [self dataSourceDidFinishLoadingNewData];
    [self dataSourceDidFinishLoadingMoreData];
}

#pragma mark - OpusViewDelegate

- (void)didClickOpus:(Opus*)opus{
    
    PPDebug(@"<test>did click opus %@", opus.pbOpus.name);
    
    MKBlockActionSheet* tips = nil;
    
    NSString* editString = NSLS(@"kEdit");
    NSString *shareString = NSLS(@"kShare");
    
    tips = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOptions")
                                            delegate:nil
                                   cancelButtonTitle:NSLS(@"kCancel")
                              destructiveButtonTitle:nil
                                   otherButtonTitles:editString, NSLS(@"kDelete"), NSLS(@"kShareSinaWeibo"), NSLS(@"kShareWeixinSession"),
                                        NSLS(@"kShareWeixinTimeline"),NSLS(@"kShareQQSpace"),nil];
    
    tips.actionBlock = ^(NSInteger buttonIndex){
        
        switch (buttonIndex) {
                
            case OPUS_ACTION_EDIT:
                [self editDraft:opus];
                break;
                
            case OPUS_ACTION_DELETE:
                [self deleteDraft:opus];
                break;
                
            case OPUS_ACTION_SHARE_SINA_WEIBO:
                [self shareSNS:TYPE_SINA opus:opus];
                break;
                
            case OPUS_ACTION_SHARE_WEIXIN_SESSION:
                [self shareSNS:TYPE_WEIXIN_SESSION opus:opus];
                break;
                
            case OPUS_ACTION_SHARE_WEIXIN_TIMELINE:
                [self shareSNS:TYPE_WEIXIN_TIMELINE opus:opus];
                break;
                
            case OPUS_ACTION_SHARE_QQ_SPACE:
                [self shareSNS:TYPE_QQSPACE opus:opus];
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
        [[self draftManager] deleteOpus:opus];
        [self reloadTableViewDataSource];
    }];

    [dialog showInView:self.view];
}


- (void)shareSNS:(PPSNSType)type feed:(DrawFeed*)feed
{
    NSString* text = [ShareAction shareTextByDrawFeed:feed snsType:type];
    NSString* imagePath = [ShareAction createFeedImagePath:feed];
    
    [[GameSNSService defaultService] publishWeibo:type
                                             text:text
                                    imageFilePath:imagePath
                                           inView:self.view
                                       awardCoins:[PPConfigManager getShareWeiboReward]
                                   successMessage:NSLS(@"kShareWeiboSucc")
                                   failureMessage:NSLS(@"kShareWeiboFailure")];
    
}

- (void)shareSNS:(PPSNSType)type opus:(Opus*)opus
{
    NSString* text = @"";
    text = [ShareAction createShareText:opus.pbOpus.name
                            desc:opus.pbOpus.desc
                      opusUserId:[[UserManager defaultManager] userId]
                      userGender:[[UserManager defaultManager] isUserMale]
                         snsType:type];

    NSString* imagePath = opus.pbOpus.localImageUrl;
    
    [[GameSNSService defaultService] publishWeibo:type
                                             text:text
                                    imageFilePath:imagePath
                                           inView:self.view
                                       awardCoins:[PPConfigManager getShareWeiboReward]
                                   successMessage:NSLS(@"kShareWeiboSucc")
                                   failureMessage:NSLS(@"kShareWeiboFailure")];
    
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
                                       otherButtonTitles:/*shareString,*/ NSLS(@"kLook"), NSLS(@"kDelete"), NSLS(@"kShareSinaWeibo"), NSLS(@"kShareWeixinSession"),
                                            NSLS(@"kShareWeixinTimeline"),NSLS(@"kShareQQSpace"),nil];
        
        tips.actionBlock = ^(NSInteger buttonIndex){
            
            switch (buttonIndex) {
                    
                case OPUS_ACTION_EDIT:
                    [self enterOpusDetail:feed];
                    break;
                    
                case OPUS_ACTION_DELETE:
                    [self deleteFeed:feed];
                    break;

                case OPUS_ACTION_SHARE_SINA_WEIBO:
                    [self shareSNS:TYPE_SINA feed:feed];
                    break;

                case OPUS_ACTION_SHARE_WEIXIN_SESSION:
                    [self shareSNS:TYPE_WEIXIN_SESSION feed:feed];
                    break;

                case OPUS_ACTION_SHARE_WEIXIN_TIMELINE:
                    [self shareSNS:TYPE_WEIXIN_TIMELINE feed:feed];
                    break;

                case OPUS_ACTION_SHARE_QQ_SPACE:
                    [self shareSNS:TYPE_QQSPACE feed:feed];
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
                                       otherButtonTitles:NSLS(@"kLook"), NSLS(@"kUnFavorite"), NSLS(@"kShareSinaWeibo"), NSLS(@"kShareWeixinSession"),
                                            NSLS(@"kShareWeixinTimeline"),NSLS(@"kShareQQSpace"),nil];
   
        
        tips.actionBlock = ^(NSInteger buttonIndex){
            
            switch (buttonIndex) {
                    
                case 0:
                    [self enterOpusDetail:feed];
                    break;
                    
                case 1:
                    [self unFavoriteOpus:feed];
                    break;
                    
                case OPUS_ACTION_SHARE_SINA_WEIBO:
                    [self shareSNS:TYPE_SINA feed:feed];
                    break;
                    
                case OPUS_ACTION_SHARE_WEIXIN_SESSION:
                    [self shareSNS:TYPE_WEIXIN_SESSION feed:feed];
                    break;
                    
                case OPUS_ACTION_SHARE_WEIXIN_TIMELINE:
                    [self shareSNS:TYPE_WEIXIN_TIMELINE feed:feed];
                    break;
                    
                case OPUS_ACTION_SHARE_QQ_SPACE:
                    [self shareSNS:TYPE_QQSPACE feed:feed];
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

- (void)deleteFeed:(DrawFeed *)feed{
    
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


+ (void)shareFromWeiXin:(UIViewController *)superController
{
    OpusManageController* share = [[[OpusManageController alloc] init ] autorelease];
    [share setFromWeiXin:YES];
    [superController.navigationController pushViewController:share animated:YES];
}

- (void)clickCreateOpusButton:(id)sender{
    
    if (isSingApp()) {
        SingController *vc = [[[SingController alloc] init] autorelease];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
