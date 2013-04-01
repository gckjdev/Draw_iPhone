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
#import "FeedCell.h"
#import "CommonMessageCenter.h"
#import "DrawUserInfoView.h"
#import "UseItemScene.h"
#import "ConfigManager.h"
#import "UserManager.h"
#import "MKBlockActionSheet.h"

typedef enum{
    UserTypeFeed = FeedListTypeUserFeed,
    UserTypeOpus = FeedListTypeUserOpus,
    UserTypeFavorite = FeedListTypeUserFavorite,
}UserFeedType;

@interface UserFeedController () {
    RankView* _selectedRankView;
    DrawFeed* _selectedFeed;
}

@end

@implementation UserFeedController
@synthesize nickName = _nickName;
@synthesize userId = _userId;


- (void)dealloc
{
    PPRelease(_userId);
    PPRelease(_nickName);
    [super dealloc];
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
    if ([[UserManager defaultManager] isMe:self.userId]) {
        [[self.view viewWithTag:UserTypeFeed] removeFromSuperview];
    }else{
        [[self.view viewWithTag:UserTypeFavorite] removeFromSuperview];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTabButtons];
    [self.titleLabel setText:[NSString stringWithFormat:@"%@",_nickName]];

    if ([ConfigManager showOpusCount]) {
        //load opus count
        [[FeedService defaultService] getOpusCount:_userId delegete:self];
    }
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
            return [RankView heightForRankViewType:RankViewTypeNormal]+1;
        case UserTypeFeed:
            return [FeedCell getCellHeight];

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


#define NORMAL_CELL_VIEW_NUMBER 3
#define WIDTH_SPACE 1
- (void)setNormalRankCell:(UITableViewCell *)cell 
                WithFeeds:(NSArray *)feeds
{
    CGFloat width = [RankView widthForRankViewType:RankViewTypeNormal];
    CGFloat height = [RankView heightForRankViewType:RankViewTypeNormal];
    CGFloat space = WIDTH_SPACE;
    CGFloat x = 0;
    CGFloat y = 0;
    for (DrawFeed *feed in feeds) {
        RankView *rankView = [RankView createRankView:self type:RankViewTypeNormal];
        [rankView setViewInfo:feed];
        [cell.contentView addSubview:rankView];
        rankView.frame = CGRectMake(x, y, width, height);
        x += width + space;
        [rankView updateViewInfoForUserOpus];
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

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableTab *tab = [self currentTab];
    
    if (tab.tabID == UserTypeFeed) {
        
        NSString *CellIdentifier = [FeedCell getCellIdentifier];
        FeedCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [FeedCell createCell:self];
        }
        cell.indexPath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryNone;
        Feed *feed = [self.tabDataList objectAtIndex:indexPath.row];
        [feed updateDesc];
        [cell setCellInfo:feed];
        return cell;
        
    }else if(tab.tabID == UserTypeOpus || tab.tabID == UserTypeFavorite){
        
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
    }else{
        return nil;
    }
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
        case UserTypeFeed:
            return count;
        case UserTypeOpus:
        case UserTypeFavorite:
            if (count %3 == 0) {
                return count/3;
            }else{
                return count/3 + 1;
            }
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
    if (feed.isDrawType) {
        drawFeed = (DrawFeed *)feed;
    }else if(feed.isGuessType){
        drawFeed = [(GuessFeed *)feed drawFeed];
    }else{
        PPDebug(@"warnning:<UserFeedController> feedId = %@ is illegal feed, cannot set the detail", feed.feedId);
        return;
    }
    [self enterDetailFeed:drawFeed];
    
    
    //enter the detail feed contrller
}

- (void)enterDetailFeed:(DrawFeed *)feed
{
    ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:feed scene:[UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:feed]];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];
}

- (void)alertDeleteConfirm
{
    CommonDialog* dialog = nil;
    NSString *title = [[UserManager defaultManager] isSuperUser] ? [NSString stringWithFormat:@"%@［超级管理员权限模式］", NSLS(@"kSure_delete")] : NSLS(@"kSure_delete");
    dialog = [CommonDialog createDialogWithTitle:title
                                             message:NSLS(@"kAre_you_sure")
                                               style:CommonDialogStyleDoubleButton
                                            delegate:nil clickOkBlock:^{
                                                if (_selectedFeed) {
                                                    [self showActivityWithText:NSLS(@"kDeleting")];
                                                    [[FeedService defaultService] deleteFeed:_selectedFeed delegate:self];
                                                }
                                                _selectedFeed = nil;
                                            } clickCancelBlock:^{
                                                //
                                            }];
    [dialog showInView:self.view];
}

- (void)alertUnFavoriteConfirm
{
    CommonDialog* dialog = nil;
    __block typeof (self) bself = self;
    dialog = [CommonDialog createDialogWithTitle:NSLS(@"kUnFavorite")
                                         message:NSLS(@"kAre_you_sure_to_unfavorite")
                                           style:CommonDialogStyleDoubleButton
                                        delegate:nil clickOkBlock:^{
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
                                        } clickCancelBlock:^{
                                            //
                                        }];
    [dialog showInView:self.view];
}

typedef enum{
    ActionSheetIndexDetail = 0,
    ActionSheetIndexDelete = 1,
    ActionSheetIndexUnFavorite = 1,
    ActionSheetIndexCancel,
}ActionSheetIndex;

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self handleActionSheetForOpus:buttonIndex];
}

- (void)handleActionSheetForOpus:(NSInteger)buttonIndex
{
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
            [self enterDetailFeed:feed];
        }
            break;
        default:
        {
            
        }
            break;
    }

}


#pragma mark common tab controller

- (NSInteger)tabCount
{
    return 2;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return [ConfigManager getTimelineCountOnce];
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    if ([[UserManager defaultManager] isMe:self.userId]) {
        NSInteger tabId[] = {UserTypeOpus, UserTypeFavorite};
        return tabId[index];
    }else{
        NSInteger tabId[] = {UserTypeOpus, UserTypeFeed};
        return tabId[index];
    }
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    if ([[UserManager defaultManager] isMe:self.userId]) {
        NSString *noOpus = [NSString stringWithFormat:NSLS(@"kUserNoOpus"),self.nickName];
        NSString *noFeed = [NSString stringWithFormat:NSLS(@"kUserNoFavorite"),self.nickName];
        NSString *tabDesc[] = {noOpus,noFeed};
        
        return tabDesc[index];
    }else{
        NSString *noOpus = [NSString stringWithFormat:NSLS(@"kUserNoOpus"),self.nickName];
        NSString *noFeed = [NSString stringWithFormat:NSLS(@"kUserNoFeed"),self.nickName];
        NSString *tabDesc[] = {noOpus,noFeed};
        
        return tabDesc[index];
    }
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    if ([[UserManager defaultManager] isMe:self.userId]) {
        NSString *tabTitle[] = {NSLS(@"kUserOpus"), NSLS(@"kUserFavorite")};
        return tabTitle[index];
    }else{
        NSString *tabTitle[] = {NSLS(@"kUserOpus"),NSLS(@"kUserFeed")};
        return tabTitle[index];

    }
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
            //update opus count
            UIButton * button = [self tabButtonWithTabID:UserTypeOpus];
            NSString *title = [NSString stringWithFormat:NSLS(@"kOpusCount"),count];
            [button setTitle:title forState:UIControlStateNormal];
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

    if ([[UserManager defaultManager] isSuperUser]) {
        UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:[NSString stringWithFormat:@"%@<警告！你正在使用超级管理权限>", NSLS(@"kOpusOperation")]
                                      delegate:self
                                      cancelButtonTitle:NSLS(@"kCancel")
                                      destructiveButtonTitle:NSLS(@"kOpusDetail")
                                      otherButtonTitles:NSLS(@"kDelete"), nil];
        [actionSheet showInView:self.view];
        [actionSheet release];
    } else {
        MKBlockActionSheet *sheet;
        TableTab *tab = [self currentTab];
        if(tab.tabID == UserTypeOpus ){
            if ([[UserManager defaultManager] isMe:self.userId]) {
                sheet = [[[MKBlockActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"kOpusDetail") otherButtonTitles:NSLS(@"kDelete"), nil] autorelease];
                [sheet showInView:self.view];
                __block typeof (self) bself  = self;
                [sheet setActionBlock:^(NSInteger buttonIndex){
                    [bself handleActionSheetForOpus:buttonIndex];
                }];
            }else{
                [self enterDetailFeed:_selectedRankView.feed];
            }
        }else if(tab.tabID == UserTypeFavorite){
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
        case ActionSheetIndexUnFavorite:
        {
            _selectedFeed = feed;
            [self alertUnFavoriteConfirm];
        }
            break;
        case ActionSheetIndexDetail:
        {
            [self enterDetailFeed:feed];
        }
            break;
        default:
        {
            
        }
            break;
    }
}

- (void)showRankView:(RankView *)rankView
{
    ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:rankView.feed scene:[UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:rankView.feed]];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];
}



@end
