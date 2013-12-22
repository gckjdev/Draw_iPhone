//
//  HotController.m
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserFeedController.h"
#import "TableTabManager.h"
#import "ShareImageManager.h"
#import "ShowFeedController.h"
//#import "FeedCell.h"
#import "CommonMessageCenter.h"
#import "UseItemScene.h"
#import "PPConfigManager.h"
#import "UserManager.h"
#import "MKBlockActionSheet.h"
#import "UINavigationController+UINavigationControllerAdditions.h"
//#import "SingHotCell.h"
#import "CellManager.h"

typedef enum{
    UserTypeFeed = FeedListTypeUserFeed,
    UserTypeOpus = FeedListTypeUserOpus,
    UserTypeFavorite = FeedListTypeUserFavorite,
}UserFeedType;

@interface UserFeedController () {
    RankView* _selectedRankView;
    DrawFeed* _selectedFeed;
    BOOL canSellOpus;
}
@property (retain, nonatomic) DrawFeed* currentSelectFeed;

@end

@implementation UserFeedController
@synthesize nickName = _nickName;
@synthesize userId = _userId;


- (void)dealloc
{
    PPRelease(_userId);
    PPRelease(_nickName);
    PPRelease(_currentSelectFeed);
    [super dealloc];
}

- (id)initWithUserId:(NSString *)userId
            nickName:(NSString *)nickName
{
    return [self initWithUserId:userId nickName:nickName defaultTabIndex:0];
}

- (id)initWithUserId:(NSString *)userId
            nickName:(NSString *)nickName
     defaultTabIndex:(int)defaultTabIndex
{
    self = [super initWithDefaultTabIndex:defaultTabIndex];
    if (self) {
        self.userId = userId;
        self.nickName = nickName;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _defaultTabIndex = 0;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)initTabButtons
{
    [super initTabButtons];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTabButtons];
    [self.titleLabel setText:[NSString stringWithFormat:@"%@",_nickName]];

    if ([PPConfigManager showOpusCount]) {
        //load opus count
        [[FeedService defaultService] getOpusCount:_userId delegete:self];
    }
    
    self.dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    SET_COMMON_TAB_TABLE_VIEW_Y(self.dataTableView);
    
    CommonTitleView* titleView = self.titleView;
    [titleView setTitle:NSLS(@"kExhibition")];
    [titleView setRightButtonAsRefresh];
    [titleView setTarget:self];
    [titleView setBackButtonSelector:@selector(clickBackButton:)];
    [titleView setRightButtonSelector:@selector(clickRefreshButton:)];
    
    self.view.backgroundColor = COLOR_WHITE;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - table view delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (self.currentTab.tabID) {
        case UserTypeOpus:
        case UserTypeFavorite:
//            if (isDrawApp()) {
//                return [RankView heightForRankViewType:RankViewTypeNormal]+1;
//            }else if(isSingApp()){
//                return [RankView heightForRankViewType:RankViewTypeWhisper]+1;
//            }
            return [CellManager getLastStyleCellHeightWithIndexPath:indexPath];
            
        case UserTypeFeed:
//            return [FeedCell getCellHeight];
            return [CellManager getTimelineStyleCellHeight];

        default:
            return 0;
    }
}

- (void)clearCellSubViews:(UITableViewCell *)cell{
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[RankView class]]) {
            [view removeFromSuperview];
        }
    }    
}


//#define NORMAL_CELL_VIEW_NUMBER 3

//#define WIDTH_SPACE 1
//- (void)setNormalRankCell:(UITableViewCell *)cell
//                WithFeeds:(NSArray *)feeds
//{
//    CGFloat width = [RankView widthForRankViewType:RankViewTypeNormal];
//    CGFloat height = [RankView heightForRankViewType:RankViewTypeNormal];
//    CGFloat space = WIDTH_SPACE;
//    CGFloat x = 0;
//    CGFloat y = 0;
//    for (DrawFeed *feed in feeds) {
//        RankView *rankView = [RankView createRankView:self type:RankViewTypeNormal];
//        [rankView setViewInfo:feed];
//        [cell.contentView addSubview:rankView];
//        rankView.frame = CGRectMake(x, y, width, height);
//        x += width + space;
//        [rankView updateViewInfoForUserOpus];
//    }
//}


//- (void)setWhisperRankCell:(UITableViewCell *)cell
//                WithFeeds:(NSArray *)feeds
//{
//    CGFloat width = [RankView widthForRankViewType:RankViewTypeWhisper];
//    CGFloat height = [RankView heightForRankViewType:RankViewTypeWhisper];
//    CGFloat x = 0;
//    CGFloat y = 0;
//    for (DrawFeed *feed in feeds) {
//        RankView *rankView = [RankView createRankView:self type:RankViewTypeWhisper];
//        [rankView setViewInfo:feed];
//        [cell.contentView addSubview:rankView];
//        rankView.frame = CGRectMake(x, y, width, height);
//        x += width;
//        [rankView updateViewInfoForUserOpus];
//    }
//}


//- (NSObject *)saveGetObjectForIndex:(NSInteger)index
//{
//    NSArray *list = [self tabDataList];
//    if (index < 0 || index >= [list count]) {
//        return nil;
//    }
//    return [list objectAtIndex:index];
//}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    switch ([[self currentTab] tabID]) {
        case UserTypeOpus:
        case UserTypeFavorite:
            
            return [CellManager getLastStyleCell:theTableView
                                       indexPath:indexPath
                                        delegate:self
                                        dataList:[self tabDataList]];
            break;
            
        case UserTypeFeed:
            
           return [CellManager getTimelineStyleCell:theTableView
                                          indexPath:indexPath
                                           delegate:self
                                           dataList:self.tabDataList];
            
            break;
            
        default:
            return nil;
            break;
    }
    
    
    
//    
//    TableTab *tab = [self currentTab];
//    
//    if (tab.tabID == UserTypeFeed) {
//        
//        NSString *CellIdentifier = [FeedCell getCellIdentifier];
//        FeedCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            cell = [FeedCell createCell:self];
//        }
//        cell.indexPath = indexPath;
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        Feed *feed = [self.tabDataList objectAtIndex:indexPath.row];
//        [feed updateDesc];
//        [cell setCellInfo:feed];
//        return cell;
//        
//    }else if(tab.tabID == UserTypeOpus || tab.tabID == UserTypeFavorite){
//        
//        if (isDrawApp()) {
//            NSString *CellIdentifier = @"RankCell";
//            UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            
//            if (cell == nil) {
//                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//            }else{
//                [self clearCellSubViews:cell];
//            }
//            
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            cell.accessoryType = UITableViewCellAccessoryNone;
//            
//            NSInteger startIndex = (indexPath.row * NORMAL_CELL_VIEW_NUMBER);
//            NSMutableArray *list = [NSMutableArray array];
//            for (NSInteger i = startIndex; i < startIndex+NORMAL_CELL_VIEW_NUMBER; ++ i) {
//                NSObject *object = [self saveGetObjectForIndex:i];
//                if (object) {
//                    [list addObject:object];
//                }
//            }
//            [self setNormalRankCell:cell WithFeeds:list];
//            
//            return cell;
//            
//        }else if (isSingApp()){
//            
//            return [CellManager getLastStyleCell:theTableView
//                                       indexPath:indexPath
//                                        delegate:self
//                                        dataList:[self tabDataList]];
//        }
//    }
//    
//    return nil;
}

- (void)updateSeparator:(NSInteger)dataCount
{
    if (self.currentTab.tabID == UserTypeOpus || self.currentTab.tabID == UserTypeFavorite) {
        [self.dataTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }else{
        if (dataCount == 0) {
            [self.dataTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        }else{
            [self.dataTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];            
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
    [self updateSeparator:count];
    
    switch (self.currentTab.tabID) {
            
        case UserTypeOpus:
        case UserTypeFavorite:
            return [CellManager getLastStyleCellCountWithDataCount:count roundingUp:YES];
            
        case UserTypeFeed:
            return [CellManager getTimelineStyleCellCountWithDataCount:count];

        default:
            return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.currentTab.tabID != UserTypeFeed ||
        indexPath.row > [self.tabDataList count])
    {
        return;
    }
    
    Feed *feed = [self.tabDataList objectAtIndex:indexPath.row];
    
    if (feed.opusStatus == OPusStatusDelete) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kOpusDelete") delayTime:1.5 isHappy:NO];
        return;
    }
    DrawFeed *drawFeed = nil;
    if (feed.isOpusType) {
        drawFeed = (DrawFeed *)feed;
    }else if(feed.isGuessType){
        drawFeed = [(GuessFeed *)feed drawFeed];
    }else{
        PPDebug(@"warnning:<UserFeedController> feedId = %@ is illegal feed, cannot set the detail", feed.feedId);
        return;
    }
    
    [self enterDetailFeed:drawFeed showOpusImageBrowser:NO];
}

- (void)enterDetailFeed:(DrawFeed *)feed showOpusImageBrowser:(BOOL)showOpusImageBrowser
{
    ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:feed scene:[UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:feed]];
    if (showOpusImageBrowser) {
        [sc showOpusImageBrower];
    }
    sc.feedList = [[self currentTab] dataList];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];
}


- (void)alertDeleteConfirm
{
    CommonDialog* dialog = nil;
    NSString *title = [[UserManager defaultManager] isSuperUser] ? [NSString stringWithFormat:@"%@［超级管理员权限模式］", NSLS(@"kSure_delete")] : NSLS(@"kSure_delete");
    
    dialog = [CommonDialog createDialogWithTitle:title
                                         message:NSLS(@"kAre_you_sure")
                                           style:CommonDialogStyleDoubleButton];
    [dialog setClickOkBlock:^(UILabel *label){
        if (_selectedFeed) {
            [self showActivityWithText:NSLS(@"kDeleting")];
            [[FeedService defaultService] deleteFeed:_selectedFeed delegate:self];
        }
        _selectedFeed = nil;
    }];
    
    [dialog showInView:self.view];
}

- (void)alertUnFavoriteConfirm
{
    CommonDialog* dialog = nil;
    __block typeof (self) bself = self;
    
    dialog = [CommonDialog createDialogWithTitle:NSLS(@"kUnFavorite")
                                         message:NSLS(@"kAre_you_sure_to_unfavorite")
                                           style:CommonDialogStyleDoubleButton];
    [dialog setClickOkBlock:^(UILabel *label){
        if (_selectedFeed) {
            [self showActivityWithText:NSLS(@"kUnFavoriting")];
            [[FeedService defaultService] removeOpusFromFavorite:_selectedFeed.feedId resultBlock:^(int resultCode) {
                [bself hideActivity];
                if (resultCode != 0) {
                    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUnfavoriteFail") delayTime:1.5 isHappy:NO];
                    return;
                }
                [bself finishDeleteData:_selectedFeed ForTabID:bself.currentTab.tabID];
                _selectedFeed = nil;
            }];
        }
    }];
    
    [dialog showInView:self.view];
}

- (void)editDescOfFeed:(DrawFeed*)feed
{
    if ([feed isContestFeed]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kContestNotSupportDesc") delayTime:2.5];
        return;
    }
    self.currentSelectFeed = feed;
    
    CommonDialog *dialog = [CommonDialog createInputViewDialogWith:NSLS(@"kEditOpusDesc")];
    dialog.inputTextView.text = feed.opusDesc;
    dialog.delegate = self;
    [dialog setMaxInputLen:[PPConfigManager getMaxLengthOfDrawDesc]];
    
    [dialog showInView:self.view];
}

- (void)didClickOk:(CommonDialog *)dialog infoView:(id)infoView{
    
    UITextView *tv = (UITextView *)infoView;
    [self commitDesc:tv.text];
}

- (void)commitDesc:(NSString *)desc{
    [[FeedService defaultService] updateOpus:self.currentSelectFeed.feedId image:nil description:desc resultHandler:^(int resultCode) {
        if (resultCode == 0) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateSucc") delayTime:2];
        } else {
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateFail") delayTime:2];
        }
    }];
}

typedef enum{
    ActionSheetIndexDetail = 0,
    ActionSheetIndexEditDesc,
    ActionSheetIndexDelete,
    ActionSheetIndexCancel,
}ActionSheetIndex;

typedef enum{
    FavoriteActionSheetIndexDetail = 0,
    FavoriteActionSheetIndexUnFavorite = 1,
    FavoriteActionSheetIndexCancel,
}FavoriteActionSheetIndex;

typedef enum{
    SuperActionSheetIndexDetail = 0,
    SuperActionSheetIndexDelete = 1,
    SuperActionSheetIndexAddToCell,
    SuperActionSheetIndexAddToRecommend,
    SuperActionSheetIndexRemoveFromRecommend,
    SuperActionSheetIndexCancel,
}SuperActionSheetIndex;

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self handleActionSheetforOpus:actionSheet atIndex:buttonIndex];
}

- (void)handleActionSheetforOpus:(UIActionSheet*)actionSheet
                         atIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    _selectedFeed = nil;
    DrawFeed* feed = _selectedRankView.feed;
    
    switch (buttonIndex) {
        case ActionSheetIndexDelete:
        {
            _selectedFeed = feed;
            [self alertDeleteConfirm];
        }
            break;
        case ActionSheetIndexDetail:
        {
            PPDebug(@"Detail");
            [self enterDetailFeed:feed showOpusImageBrowser:YES];
        } break;
        case ActionSheetIndexEditDesc: {
            [self editDescOfFeed:feed];
        } break;
        default:
        {
            
        }
            break;
    }

}

- (void)handleSuperActionSheetforOpus:(UIActionSheet*)actionSheet
                              atIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    _selectedFeed = nil;
    DrawFeed* feed = _selectedRankView.feed;
    
    switch (buttonIndex) {
        case SuperActionSheetIndexDelete:
        {
            _selectedFeed = feed;
            [self alertDeleteConfirm];
        }
            break;
        case SuperActionSheetIndexDetail:
        {
            [self enterDetailFeed:_selectedRankView.feed showOpusImageBrowser:YES];
        }
            break;
        case SuperActionSheetIndexAddToCell:
        {/*
            if (canSellOpus) {
                PPDebug(@"<handleActionSheet> ActionSheetIndexAddToCell" );
                AddLearnDrawView *ldView = [AddLearnDrawView createViewWithOpusId:feed.feedId];
                [ldView showInView:self.view];
                break;
            }
          */
            break;
        }
        case SuperActionSheetIndexAddToRecommend: {
            PPDebug(@"<handleActionSheet> ActionSheetIndexAddToRecommend" );
            [[FeedService defaultService] recommendOpus:feed.feedId
                                              contestId:feed.contestId
                                            resultBlock:^(int resultCode) {
                if (resultCode == 0) {
                    [[CommonMessageCenter defaultCenter] postMessageWithText:@"成功推荐" delayTime:2];
                } else {
                    [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:@"推荐失败， result code = %d", resultCode] delayTime:2];
                }
                
            }];
            
        } break;
        case SuperActionSheetIndexRemoveFromRecommend: {
            PPDebug(@"<handleActionSheet> ActionSheetIndexAddToRecommend" );
            [[FeedService defaultService] unRecommendOpus:feed.feedId resultBlock:^(int resultCode) {
                if (resultCode == 0) {
                    [[CommonMessageCenter defaultCenter] postMessageWithText:@"成功取消推荐" delayTime:2];
                } else {
                    [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:@"取消推荐失败， result code = %d", resultCode] delayTime:2];
                }
                
            }];
        } break;
            
        default:
        {
            
        }
            break;
    }
    
}


#pragma mark common tab controller

- (NSInteger)tabCount
{
    return 3;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return [PPConfigManager getTimelineCountOnce];
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
        NSInteger tabId[] = {UserTypeOpus, UserTypeFavorite, UserTypeFeed};
        return tabId[index];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{

    NSString *noOpus = [NSString stringWithFormat:NSLS(@"kNoOpus"),self.nickName];
    NSString *noFavor= [NSString stringWithFormat:NSLS(@"kNoFavorite"),self.nickName];
    NSString *noFeed = [NSString stringWithFormat:NSLS(@"kUserNoFeed"),self.nickName];
    NSString *tabDesc[] = {noOpus,noFavor, noFeed};
    return tabDesc[index];
    
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *tabTitle[] = {NSLS(@"kUserOpus"), NSLS(@"kUserFavorite"),NSLS(@"kUserGuess")};
    return tabTitle[index];
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    
    [self showActivityWithText:NSLS(@"kLoading")];
    TableTab *tab = [_tabManager tabForID:tabID];
    FeedService *feedService = [FeedService defaultService];
    if (tab) {
        NSInteger offset = tab.offset;
        NSInteger limit = tab.limit;
        switch (tabID) {
            case UserTypeFeed:
                [feedService getUserFeedList:_userId offset:offset limit:limit delegate:self];
                break;
            case UserTypeOpus:
            {
                [feedService getUserOpusList:_userId offset:offset limit:limit type:FeedListTypeUserOpus delegate:self];
                break;
            }
            case UserTypeFavorite:
            {
                [feedService getUserFavoriteOpusList:_userId offset:offset limit:limit delegate:self];
            }
            default:
                break;
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
        [self finishLoadDataForTabID:type resultList:feedList];
    }else{
        [self failLoadDataForTabID:type];
    }
}

- (void)didGetFeedList:(NSArray *)feedList 
            targetUser:(NSString *)userId 
                  type:(FeedListType)type
            resultCode:(NSInteger)resultCode
{
    PPDebug(@"<didGetFeedList> list count = %d ", [feedList count]);
    [self hideActivity];
    if (resultCode == 0) {
        [self finishLoadDataForTabID:type resultList:feedList];
    }else{
        [self failLoadDataForTabID:type];
    }
    
}

- (void)didGetUser:(NSString *)userId
         opusCount:(NSInteger)count
        resultCode:(NSInteger)resultCode
{
    if (resultCode == 0) {
        if (count != 0) {
            [self setTab:UserTypeOpus titleNumber:count];
        }
    }
}

- (void)didDeleteFeed:(Feed *)feed resultCode:(NSInteger)resultCode;

{
    [self hideActivity];
    if (resultCode != 0) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kDeleteFail") delayTime:1.5 isHappy:NO];
        return;
    }
    [self finishDeleteData:feed ForTabID:self.currentTab.tabID];
}



#pragma mark Rank View delegate
- (void)didClickRankView:(RankView *)rankView
{
    _selectedRankView = rankView;
    
    MKBlockActionSheet *sheet;
    TableTab *tab = [self currentTab];
    BOOL isMyFavor = [[UserManager defaultManager] isMe:self.userId];
    if(tab.tabID == UserTypeOpus ){
        if ([rankView.feed isMyOpus]) {
            sheet = [[[MKBlockActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"kOpusDetail") otherButtonTitles:NSLS(@"kEditOpusDesc"), NSLS(@"kDelete"), nil] autorelease];
            sheet.cancelButtonIndex = ActionSheetIndexCancel;
            [sheet showInView:self.view];
            __block typeof (self) bself  = self;
            [sheet setActionBlock:^(NSInteger buttonIndex){
                canSellOpus = NO;
                [bself handleActionSheetforOpus:sheet atIndex:buttonIndex];
            }];
        }else if([[UserManager defaultManager] isSuperUser]) {
                sheet = [[MKBlockActionSheet alloc]
                                              initWithTitle:[NSString stringWithFormat:@"%@<警告！你正在使用超级管理权限>", NSLS(@"kOpusOperation")]
                                              delegate:self
                                              cancelButtonTitle:NSLS(@"kCancel")
                                              destructiveButtonTitle:NSLS(@"kOpusDetail")
                                              otherButtonTitles:NSLS(@"kDelete"), NSLS(@"kAddLearnDraw"), NSLS(@"kRecommend"), @"取消推荐", nil];
                
            __block typeof (self) bself  = self;
            [sheet setActionBlock:^(NSInteger buttonIndex){
                canSellOpus = YES;
                [bself handleSuperActionSheetforOpus:sheet atIndex:buttonIndex];
            }];
            sheet.cancelButtonIndex = SuperActionSheetIndexCancel;
                
                [sheet showInView:self.view];
                [sheet release];
        }else{
            [self enterDetailFeed:_selectedRankView.feed showOpusImageBrowser:YES];
        }
    }else if(tab.tabID == UserTypeFavorite){
        if (!isMyFavor) {
            [self enterDetailFeed:_selectedRankView.feed showOpusImageBrowser:YES];
        }else{
            sheet = [[[MKBlockActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"kOpusDetail") otherButtonTitles:NSLS(@"kUnFavorite"), nil] autorelease];
            [sheet showInView:self.view];
            __block typeof (self) bself  = self;
            [sheet setActionBlock:^(NSInteger buttonIndex){
                [bself handleActionSheetForFavorite:buttonIndex];
            }];
        }
    }
}

- (void)handleActionSheetForFavorite:(NSInteger)buttonIndex
{
    _selectedFeed = nil;
    DrawFeed* feed = _selectedRankView.feed;
    
    switch (buttonIndex) {
        case FavoriteActionSheetIndexUnFavorite:
        {
            _selectedFeed = feed;
            [self alertUnFavoriteConfirm];
        }
            break;
        case FavoriteActionSheetIndexDetail:
        {
            [self enterDetailFeed:feed showOpusImageBrowser:YES];
        }
            break;
        default:
        {
            
        }
            break;
    }
}



@end
