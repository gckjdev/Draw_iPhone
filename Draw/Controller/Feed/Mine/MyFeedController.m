//
//  HotController.m
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyFeedController.h"
#import "TableTabManager.h"
#import "ShareImageManager.h"
#import "ShowFeedController.h"
#import "FeedCell.h"
#import "CommonUserInfoView.h"
#import "CommonMessageCenter.h"
#import "CommonDialog.h"

typedef enum{
    MyTypeFeed = FeedListTypeAll,
    MyTypeOpus = FeedListTypeUserOpus,
    MyTypeComment = FeedListTypeComment,
    MyTypeDrawToMe = FeedListTypeDrawToMe,
    
}MyType;

@interface MyFeedController()
- (void)alertDeleteConfirm;
@end

@implementation MyFeedController
//@synthesize titleLabel = _tipsLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



- (void)initTabButtons
{
    NSArray* tabList = [_tabManager tabList];
    for(TableTab *tab in tabList){
        UIButton *button = (UIButton *)[self.view viewWithTag:tab.tabID];
        ShareImageManager *imageManager = [ShareImageManager defaultManager];
        [button setTitle:tab.title forState:UIControlStateNormal];
        if (tab.tabID == MyTypeFeed) {
            [button setBackgroundImage:[imageManager myFoucsImage] forState:UIButtonTypeCustom];
            [button setBackgroundImage:[imageManager myFoucsSelectedImage] forState:UIControlStateSelected];
        }else if(tab.tabID == MyTypeDrawToMe){
            [button setBackgroundImage:[imageManager foucsMeImage] forState:UIButtonTypeCustom];
            [button setBackgroundImage:[imageManager foucsMeSelectedImage] forState:UIControlStateSelected];            
        }else{
            [button setBackgroundImage:[imageManager middleTabImage] forState:UIControlStateNormal];
            [button setBackgroundImage:[imageManager middleTabSelectedImage] forState:UIControlStateSelected];
        }
    }
    //    UIButton *tabButton = [self tabButtonWithTabID:RankTypeHot];
    [self clickTabButton:self.currentTabButton];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self initTabButtons];
    [self.titleLabel setText:NSLS(@"kFeed")];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (self.currentTab.tabID) {
        case MyTypeOpus:
        case MyTypeDrawToMe:
        return [RankView heightForRankViewType:RankViewTypeNormal]+1;
        case MyTypeFeed:
            return [FeedCell getCellHeight];
        default:
            return 44.0f;
    }
}

- (void)clearCellSubViews:(UITableViewCell *)cell{
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[RankView class]]) {
            [view removeFromSuperview];
        }
    }    
}

- (void)setFirstRankCell:(UITableViewCell *)cell WithFeed:(DrawFeed *)feed
{
    RankView *view = [RankView createRankView:self type:RankViewTypeFirst];
    [view setViewInfo:feed];
    [cell.contentView addSubview:view];
}

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
    
    CGFloat x2 = (CGRectGetWidth(cell.frame) -  [RankView widthForRankViewType:RankViewTypeSecond]);
    view2.frame = CGRectMake(x2, 0, view2.frame.size.width, view2.frame.size.height);
}


#define NORMAL_CELL_VIEW_NUMBER 3
#define WIDTH_SPACE 1
- (void)setNormalRankCell:(UITableViewCell *)cell 
                WithFeeds:(NSArray *)feeds
{
    CGFloat width = [RankView widthForRankViewType:RankViewTypeNormal];
    CGFloat height = [RankView heightForRankViewType:RankViewTypeNormal];
//    CGFloat space = (cell.frame.size.width - NORMAL_CELL_VIEW_NUMBER * width)/ (NORMAL_CELL_VIEW_NUMBER - 1);
    CGFloat space =  WIDTH_SPACE;
    CGFloat x = 0;
    CGFloat y = 0;
    for (DrawFeed *feed in feeds) {
        RankView *rankView = [RankView createRankView:self type:RankViewTypeNormal];
        [rankView setViewInfo:feed];
        [cell.contentView addSubview:rankView];
        rankView.frame = CGRectMake(x, y, width, height);
        x += width + space;
//        rankView.drawFlag.hidden = YES;
        if (self.currentTab.tabID == MyTypeOpus) {
            [rankView updateViewInfoForMyOpus];
        }
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
    
    if (tab.tabID == MyTypeFeed) {
        
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
        
    }else if(tab.tabID == MyTypeDrawToMe || tab.tabID == MyTypeOpus){
        
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
    MyType type = self.currentTab.tabID;
    if (type == MyTypeOpus || type == MyTypeDrawToMe) {
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
        case MyTypeFeed:
        case MyTypeComment:
            return count;
        case MyTypeOpus:
        case MyTypeDrawToMe:
            if (count %3 == 0) {
                return count/3;
            }else{
                return count/3 + 1;
            }
        default:
            return 0;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PPDebug(@"<willSelectRowAtIndexPath>");
    return indexPath;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.currentTab.tabID != MyTypeFeed && indexPath.row > [self.tabDataList count])
        return;
    
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
        PPDebug(@"warnning:<FeedController> feedId = %@ is illegal feed, cannot set the detail", feed.feedId);
        return;
    }
    ShowFeedController *sfc = [[ShowFeedController alloc] initWithFeed:drawFeed];
    [self.navigationController pushViewController:sfc animated:YES];
    [sfc release];
        
    //enter the detail feed contrller
}


#pragma mark - delete feed.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    _seletedFeed = [self.tabDataList objectAtIndex:indexPath.row];
    [self alertDeleteConfirm];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentTab.tabID == MyTypeFeed) {
        Feed *feed = [self.tabDataList objectAtIndex:indexPath.row];
        return [feed isMyFeed];        
    }
    return false;
}

#pragma mark common tab controller

- (NSInteger)tabCount
{
    return 4;
}
- (NSInteger)currentTabIndex
{
    return 0;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 12;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabId[] = {MyTypeFeed,MyTypeOpus,MyTypeComment,MyTypeDrawToMe};
    return tabId[index];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    NSString *tabDesc[] = {NSLS(@"kNoMyFeed"),NSLS(@"kNoMyOpus"),NSLS(@"kNoMyComment"),NSLS(@"kNoDrawToMe")};
    
    return tabDesc[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *tabTitle[] = {NSLS(@"kUserFeed"),NSLS(@"kUserOpus"),NSLS(@"kComment"),NSLS(@"kDrawToMe")};
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
            case MyTypeFeed:
                [feedService getFeedList:FeedListTypeAll
                                  offset:offset
                                   limit:limit
                                delegate:self];
                break;
            case MyTypeOpus:
            {
                NSString *userId = [[UserManager defaultManager] userId];
                [feedService getUserOpusList:userId
                                      offset:offset
                                       limit:limit 
                                        type:FeedListTypeUserOpus 
                                    delegate:self];
            }
                break;

            case MyTypeDrawToMe: //for test
            {
                NSString *userId = [[UserManager defaultManager] userId];
                [feedService getUserOpusList:userId
                                      offset:offset 
                                       limit:limit 
                                        type:FeedListTypeDrawToMe
                                    delegate:self];
            }
            case MyTypeComment:
                //TODO finish the comment label.
            {
                [self.noDataTipLabl setText:@"功能尚未完成，先试试其他的吧。"];
                self.currentTab.status = TableTabStatusLoaded;
            }
            default:
                
                [self hideActivity];
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


- (void)enterDetailFeed:(DrawFeed *)feed
{
    ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:feed];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];    
}

- (void)alertDeleteConfirm
{    
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSure_delete") 
                                                       message:NSLS(@"kAre_you_sure") 
                                                         style:CommonDialogStyleDoubleButton 
                                                        delegate:self];  
    [dialog showInView:self.view];
}

- (void)clickOk:(CommonDialog *)dialog
{
    if (_seletedFeed) {
        [self showActivityWithText:NSLS(@"kDeleting")];
        [[FeedService defaultService] deleteFeed:_seletedFeed delegate:self];        
    }
    _seletedFeed = nil;
}
- (void)clickBack:(CommonDialog *)dialog
{
    _seletedFeed = nil;
}

#pragma mark - action sheet delegate

typedef enum{
    ActionSheetIndexDetail = 0,
    ActionSheetIndexDelete = 1,
    ActionSheetIndexCancel,
}ActionSheetIndex;

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    DrawFeed *feed = _selectRanView.feed;
    
    switch (buttonIndex) {
        case ActionSheetIndexDelete:
        {
            _seletedFeed = feed;
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
    [_selectRanView setRankViewSelected:NO];
    _selectRanView = nil;
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
    TableTab *tab = [self currentTab];
    if(tab.tabID == MyTypeOpus){
        //action sheet
        _selectRanView = rankView;
        [rankView setRankViewSelected:YES];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:NSLS(@"kOpusOperation")
                                      delegate:self 
                                      cancelButtonTitle:NSLS(@"kCancel") 
                                      destructiveButtonTitle:NSLS(@"kOpusDetail") 
                                      otherButtonTitles:NSLS(@"kDelete"), nil];
        
        [actionSheet showInView:self.view];
        [actionSheet release];
        
    }else{
        [self enterDetailFeed:rankView.feed];
    }
}



#pragma mark feed cell delegate
- (void)didClickAvatar:(NSString *)userId 
              nickName:(NSString *)nickName 
                gender:(BOOL)gender 
           atIndexPath:(NSIndexPath *)indexPath
{
    
    NSString* genderString = gender?@"m":@"f";
    [CommonUserInfoView showUser:userId 
                        nickName:nickName 
                          avatar:nil 
                          gender:genderString 
                        location:nil 
                           level:1
                         hasSina:NO 
                           hasQQ:NO 
                     hasFacebook:NO 
                      infoInView:self];
}
@end
