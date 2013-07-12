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
#import "ConfigManager.h"
#import "FileUtil.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "TableTab.h"
#import "TableTabManager.h"
#import "UIImageExt.h"
#import "ReplayView.h"
#import "MKBlockActionSheet.h"

#import "OpusManager.h"
#import "OpusView.h"
#import "Opus.h"

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

@interface OpusManageController () <OpusViewDelegate, UIActionSheetDelegate>{
    BOOL isLoading;
    Opus* _currentSelectOpus;
}

@property (retain, nonatomic) OpusManager* selfOpusManager;
@property (retain, nonatomic) OpusManager* favoriteManager;
@property (retain, nonatomic) OpusManager* draftManager;

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
    PPRelease(_selfOpusManager);
    PPRelease(_favoriteManager);
    PPRelease(_draftManager);
    [super dealloc];
}

- (id)initWithClass:(Class)aClass
             selfDb:(NSString *)selfDb
         favoriteDb:(NSString *)favoriteDb
            draftDb:(NSString *)draftDb
{
    self = [super init];
    if (self) {
        self.selfOpusManager = [[[OpusManager alloc] initWithClass:aClass dbName:selfDb] autorelease];
        self.favoriteManager = [[[OpusManager alloc] initWithClass:aClass dbName:favoriteDb] autorelease];
        self.draftManager = [[[OpusManager alloc] initWithClass:aClass dbName:draftDb] autorelease];
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
    self.noDataTipLabl.hidden = NO;
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
            Opus* opus = [[self getOpusList] objectAtIndex:(indexPath.row*VIEW_PER_LINE + i)];
            [view updateWithOpus:opus];
            [view setHidden:NO];
        } else {
            [view setHidden:YES];
        }
    }
//    NSMutableArray* myPaintArray = [NSMutableArray array];
//
//    NSAutoreleasePool* loopPool = [[NSAutoreleasePool alloc] init];
//    for (int lineIndex = 0; lineIndex < VIEW_PER_LINE; lineIndex++) {
//        int paintIndex = indexPath.row*VIEW_PER_LINE + lineIndex;
//        if (paintIndex < self.paints.count) {
//            MyPaint* paint  = [self.paints objectAtIndex:paintIndex]; 
//            [myPaintArray addObject:paint];                
//        }
//    }
//    [loopPool release];
//
//    cell.indexPath = indexPath;
//    [cell setPaints:myPaintArray];
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


- (OpusManager*)managerForTab:(TabType)tabType
{
    switch (tabType) {
        case TabTypeFavorite: {
            return self.favoriteManager;
        };
        case TabTypeMine: {
            return self.selfOpusManager;
        };
        case TabTypeDraft: {
            return self.draftManager;
        }
            
        default:
            break;
    }
    return nil;
}

- (IBAction)deleteAll:(id)sender
{
    __block OpusManageController* cp = self;
    
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kAttention")
                                                       message:NSLS(@"kDeleteAllWarning")
                                                         style:CommonDialogStyleDoubleButton
                                                      delegate:nil clickOkBlock:^{
                                                          OpusManager* manager = [cp managerForTab:[cp currentTab].tabID];
                                                          [manager deleteAllOpus];
                                                          [cp reloadTableViewDataSource];
                                                      } clickCancelBlock:^{
                                                          //
                                                      }];
    [dialog showInView:self.view];
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
    [super initTabButtons];
    
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
}

- (void)viewDidLoad
{
    [self setPullRefreshType:PullRefreshTypeNone];
    [super viewDidLoad]; 

    [self initTabButtons];
    UIButton *allButton = [self tabButtonWithTabID:TabTypeFavorite];
    

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

}

- (void)viewDidAppear:(BOOL)animated
{
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
    NSInteger tabId[] = {TabTypeMine,TabTypeFavorite,TabTypeDraft};
    return tabId[index];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    
    return NSLS(@"NoData");
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
    

    [self showActivityWithText:NSLS(@"kLoading")];
    OpusManager* manager = [self managerForTab:tabID];
    NSArray* array = [manager findAllOpusWithOffset:tab.offset limit:tab.limit];
    [self finishLoadDataForTabID:tab.tabID resultList:array];
    [self updateTab:array];
    [self reloadView];
    [self hideActivity];

}

#pragma mark - OpusViewDelegate

- (void)didClickOpus:(Opus *)opus
{
    PPDebug(@"<test>did click opus %@", opus.name);
    
    UIActionSheet* tips = nil;
    
    NSString* editString = [opus.pbOpusBuilder isRecovery]?NSLS(@"kRecovery"):NSLS(@"kEdit");
    
    
    NSString *shareString = NSLS(@"kShare");
    
    if ([LocaleUtils isChina]){
        
        if ([self currentTab].tabID == TabTypeDraft) {
            tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions")
                                               delegate:self
                                      cancelButtonTitle:NSLS(@"kCancel")
                                 destructiveButtonTitle:editString
                                      otherButtonTitles:shareString, NSLS(@"kReplay"), NSLS(@"kDelete"), nil];
        }else{
            tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions")
                                               delegate:self
                                      cancelButtonTitle:NSLS(@"kCancel")
                                 destructiveButtonTitle:shareString
                                      otherButtonTitles:
                    NSLS(@"kReplay"), NSLS(@"kDelete"), nil];
        }
    }
    else{
        if ([self currentTab].tabID == TabTypeDraft) {
            tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions")
                                               delegate:self
                                      cancelButtonTitle:NSLS(@"kCancel")
                                 destructiveButtonTitle:editString
                                      otherButtonTitles:shareString,
                    NSLS(@"kReplay"), NSLS(@"kDelete"), nil];
        }else{
            tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions")
                                               delegate:self
                                      cancelButtonTitle:NSLS(@"kCancel")
                                 destructiveButtonTitle:shareString
                                      otherButtonTitles:NSLS(@"kReplay"), NSLS(@"kDelete"), nil];
        }
        
    }
    _currentSelectOpus = opus;
    [tips showInView:self.view];
    [tips release];
}

- (OpusOption)optionIndex:(int)buttonIndex
                   forTab:(TabType)tabType
{
    if (tabType != TabTypeDraft) {
        return buttonIndex + 1;
    }
    return buttonIndex;
}

- (OpusManager*)currentOpusManager
{
    return [self managerForTab:[self currentTab].tabID];
}

#pragma mark - actionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int index = [self optionIndex:buttonIndex forTab:[self currentTab].tabID];
    __block OpusManageController* cp = self;
    switch (index) {
        case OpusOptionEdit: {
            [_currentSelectOpus enterEditFromController:self];
        } break;
        case OpusOptionShare: {
            MKBlockActionSheet* actionSheet = [[[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kShare_Options") delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
            NSArray* titleArray = [_currentSelectOpus shareOptionsTitleArray];
            for (NSString* title in titleArray) {
                [actionSheet addButtonWithTitle:title];
            }
            int cancelIndex = [actionSheet addButtonWithTitle:NSLS(@"kCancel")];
            [actionSheet setCancelButtonIndex:cancelIndex];
            [actionSheet setActionBlock:^(NSInteger buttonIndex){
                if (buttonIndex == actionSheet.cancelButtonIndex) {
                    return ;
                }
                [_currentSelectOpus handleShareOptionAtIndex:buttonIndex fromController:cp];
            }];
            [actionSheet showInView:self.view];
        } break;
        case OpusOptionReplay: {
            [_currentSelectOpus replayInController:self];
        } break;
        case OpusOptionDelete: {
            CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSure_delete")
                                                               message:NSLS(@"kAre_you_sure")
                                                                 style:CommonDialogStyleDoubleButton
                                                              delegate:nil
                                                          clickOkBlock:^{
                                                              [[cp currentOpusManager] deleteOpus:_currentSelectOpus.pbOpus.opusId];
                                                              [cp reloadTableViewDataSource];
                                                              }
                                                      clickCancelBlock:^{
                                                                  //
                                                              }];
            
            [dialog showInView:self.view];
        } break;
        default:
            break;
    }
}

+ (void)shareFromWeiXin:(UIViewController *)superController
{
    OpusManageController* share = [[[OpusManageController alloc] init ] autorelease];
    [share setFromWeiXin:YES];
    [superController.navigationController pushViewController:share animated:YES];
}
@end
