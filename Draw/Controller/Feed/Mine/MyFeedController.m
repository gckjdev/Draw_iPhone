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
//#import "DrawUserInfoView.h"
#import "ViewUserDetail.h"
#import "UserDetailViewController.h"
#import "CommonMessageCenter.h"
#import "CommonDialog.h"
#import "StatisticManager.h"
#import "CommentCell.h"
#import "MyCommentCell.h"
#import "DrawFeed.h"
#import "CommentController.h"
#import "UseItemScene.h"
#import "MyFriend.h"
#import "ConfigManager.h"
#import "CommonMessageCenter.h"

typedef enum{
    MyTypeTimelineOpus = FeedListTypeTimelineOpus,
    MyTypeTimelineGuess = FeedListTypeTimelineGuess,
    MyTypeComment = FeedListTypeComment,
    MyTypeDrawToMe = FeedListTypeDrawToMe,
    
}MyType;

@interface MyFeedController()
- (void)alertDeleteConfirmForType:(MyType)type;
- (void)showActionSheetForType:(MyType)type;
- (void)enterOpusDetail:(CommentFeed *)feed;
- (void)replyComment:(CommentFeed *)feed;
- (void)enterDetailFeed:(DrawFeed *)feed;
@end

@implementation MyFeedController
//@synthesize titleLabel = _tipsLabel;

- (id)init
{
    self = [super init];
    if (self) {
        _defaultTabIndex = 0;
    }
    return self;
}

- (id)initWithDefaultTabIndex:(NSInteger)index
{
    self = [super initWithDefaultTabIndex:index];
    return self;
}

+ (void)enterControllerWithIndex:(NSInteger)index
                  fromController:(UIViewController *)controller 
                        animated:(BOOL)animated
{
    MyFeedController *myFeedController = [[MyFeedController alloc] initWithDefaultTabIndex:index];
    [controller.navigationController pushViewController:myFeedController animated:animated];
    [myFeedController release];
}

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


- (void)didGetFeed:(DrawFeed *)feed resultCode:(NSInteger)resultCode fromCache:(BOOL)fromCache
{
    [self hideActivity];
    if (resultCode == 0) {
        if (feed) {
            [self enterDetailFeed:feed];
        }else{
            [[CommonMessageCenter defaultCenter]postMessageWithText:NSLS(@"kOpusDelete") delayTime:1.5 isHappy:NO];
        }
    }else{
        [[CommonMessageCenter defaultCenter]postMessageWithText:NSLS(@"kLoadFail") delayTime:1.5 isHappy:NO];        
    }
}
- (void)enterOpusDetail:(CommentFeed *)feed
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [[FeedService defaultService]getFeedByFeedId:feed.opusId delegate:self];
}
- (void)replyComment:(CommentFeed *)feed
{
    DrawFeed *drawFeed = [[DrawFeed alloc] init];
    drawFeed.feedId = feed.opusId;
    
    FeedUser *feedUser = [[FeedUser alloc]initWithUserId:feed.opusCreator
                                                nickName:nil
                                                  avatar:nil
                                                  gender:YES
                                               signature:nil];
    drawFeed.feedUser = feedUser;
    [feedUser release];

    CommentController *cc = [[CommentController alloc] initWithFeed:drawFeed commentFeed:_selectedCommentFeed];
    [self presentModalViewController:cc animated:YES];
    [cc release];
    
    [drawFeed release];
}


- (void)updateCommentIndexes:(BOOL)canDelete
{
    if (canDelete) {
        indexOfCommentOpus = 1;
        indexOfCommentReply = 0;
        indexOfCommentDelete = 2;
    }else{
        indexOfCommentReply = 0;
        indexOfCommentOpus = 1;
        indexOfCommentDelete = -1;        
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self initTabButtons];
    [self.titleLabel setText:NSLS(@"kFeed")];
    if ([ConfigManager showOpusCount]) {
        [[FeedService defaultService] getOpusCount:[[UserManager defaultManager] userId]
                                          delegete:self];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //update the feed/comment/draw to me/ badge.
    [self updateAllBadge];
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
        case MyTypeDrawToMe:
        return [RankView heightForRankViewType:RankViewTypeNormal]+1;
        case MyTypeTimelineOpus:
        case MyTypeTimelineGuess:
            return [FeedCell getCellHeight];
        case MyTypeComment:
        {
            CommentFeed * commentFeed = [self.tabDataList objectAtIndex:indexPath.row];
            return [MyCommentCell  getCellHeight:commentFeed];
        }
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
    
    if (tab.tabID == MyTypeTimelineOpus || tab.tabID == MyTypeTimelineGuess ) {
        
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
        
    }else if(tab.tabID == MyTypeDrawToMe){
        
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
    }else if(tab.tabID == MyTypeComment){
        CommentFeed * commentFeed = [self.tabDataList objectAtIndex:indexPath.row];
        MyCommentCell *cell = [theTableView dequeueReusableCellWithIdentifier:[MyCommentCell getCellIdentifier]];
        if (cell == nil) {
            cell = [MyCommentCell createCell:self];
            cell.superViewController = self;
        }
        [cell setCellInfo:commentFeed];
        return cell;
//        return nil;
    }else{
        return nil;
    }
}

- (void)updateSeparator:(NSInteger)dataCount
{
    MyType type = self.currentTab.tabID;
    if (type == MyTypeDrawToMe) {
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
        case MyTypeTimelineOpus:
        case MyTypeTimelineGuess:
        case MyTypeComment:
            return count;
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MyType type = self.currentTab.tabID;
    
    if (type == MyTypeComment) {
        //show the action sheet
        _selectedCommentFeed = [self.tabDataList objectAtIndex:indexPath.row];
        [self showActionSheetForType:MyTypeComment];
        return;
    }
    
    if ((type != MyTypeTimelineOpus && type != MyTypeTimelineGuess) || indexPath.row > [self.tabDataList count])
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
        PPDebug(@"warnning:<MyFeedController> feedId = %@ is illegal feed, cannot set the detail", feed.feedId);
        return;
    }
    ShowFeedController *sfc = [[ShowFeedController alloc] initWithFeed:drawFeed scene:[UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:drawFeed]];
    [self.navigationController pushViewController:sfc animated:YES];
    [sfc release];
        
    //enter the detail feed contrller
}


#pragma mark - delete feed.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    _seletedFeed = [self.tabDataList objectAtIndex:indexPath.row];
    [self alertDeleteConfirmForType:MyTypeTimelineOpus];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentTab.tabID == MyTypeTimelineOpus) {
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
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return [ConfigManager getTimelineCountOnce];
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabId[] = {MyTypeTimelineOpus,MyTypeTimelineGuess,MyTypeComment,MyTypeDrawToMe};

    return tabId[index];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    NSString *tabDesc[] = {NSLS(@"kNoMyFeed"),NSLS(@"kNoTimelineGuess"),NSLS(@"kNoMyComment"),NSLS(@"kNoDrawToMe")};
    
    return tabDesc[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *tabTitle[] = {NSLS(@"kUserFeed"),NSLS(@"kUserGuess"),NSLS(@"kComment"),NSLS(@"kDrawToMe")};

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
            case MyTypeTimelineOpus:
            {
                [feedService getFeedList:FeedListTypeTimelineOpus
                                  offset:offset
                                   limit:limit
                                delegate:self];
                break;
            }
                
            case MyTypeTimelineGuess:
            {
                [feedService getFeedList:FeedListTypeTimelineGuess
                                  offset:offset
                                   limit:limit
                                delegate:self];
                break;
            }

            case MyTypeDrawToMe: //for test
            {
                NSString *userId = [[UserManager defaultManager] userId];
                [feedService getUserOpusList:userId
                                      offset:offset 
                                       limit:limit 
                                        type:FeedListTypeDrawToMe
                                    delegate:self];
                break;
            }
            case MyTypeComment:
                
            {
                [feedService getMyCommentList:offset limit:limit delegate:self];
            }
                break;
            default:
                
                [self hideActivity];
                break;
        }
        
    }
}

- (void)updateBadge:(FeedListType)type count:(NSInteger)count
{
    UIButton *badgeButton = (UIButton *)[self.view viewWithTag:1000 + type];
    NSString* title = @"";
    if (count > 99){
        title = @"N";
    }
    else{
        title = [NSString stringWithFormat:@"%d",count];
    }
    [badgeButton setTitle:title forState:UIControlStateNormal];
    if (count == 0) {
        badgeButton.hidden = YES;
    } else {
        badgeButton.hidden = NO;
    }
}

- (void)updateAllBadge
{
    StatisticManager * manager = [StatisticManager defaultManager];
    [self updateBadge:FeedListTypeTimelineOpus count:manager.timelineOpusCount];
    [self updateBadge:FeedListTypeTimelineGuess count:manager.timelineGuessCount];
    [self updateBadge:FeedListTypeComment count:manager.commentCount];
    [self updateBadge:FeedListTypeDrawToMe count:manager.drawToMeCount];
}

- (void)clearBadge:(FeedListType)type
{
    StatisticManager * manager = [StatisticManager defaultManager];
    switch (type) {
        case FeedListTypeTimelineOpus:
            manager.timelineOpusCount = 0;
            break;
        case FeedListTypeTimelineGuess:
            manager.timelineGuessCount = 0;
            break;
        case FeedListTypeComment:
            manager.commentCount = 0;
            break;
        case FeedListTypeDrawToMe:
            manager.drawToMeCount = 0;
            break;
        default:
            break;
    }
    [self updateAllBadge];
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
        [self clearBadge:type];
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
        [self clearBadge:type];
    }else{
        [self failLoadDataForTabID:type];
    }
    
    [self updateBadge:type count:0];
}

- (void)didGetMyCommentList:(NSArray *)commentList resultCode:(NSInteger)resultCode
{
    PPDebug(@"<didGetMyCommentList> list count = %d ", [commentList count]);
    [self hideActivity];
    if (resultCode == 0) {
        [self finishLoadDataForTabID:MyTypeComment resultList:commentList];
        [self clearBadge:FeedListTypeComment];
    }else{
        [self failLoadDataForTabID:MyTypeComment];
    }
}

- (void)didGetUser:(NSString *)userId
         opusCount:(NSInteger)count
        resultCode:(NSInteger)resultCode
{
    if (resultCode == 0) {
        if (count != 0) {
            
        }
    }
}


- (void)enterDetailFeed:(DrawFeed *)feed
{
    ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:feed scene:[UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:feed]];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];    
}

- (void)alertDeleteConfirmForType:(MyType)type
{    
    CommonDialog* dialog = nil;
    if (type == MyTypeTimelineOpus) {
        dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSure_delete") 
                                    message:NSLS(@"kAre_you_sure") 
                                      style:CommonDialogStyleDoubleButton 
                                   delegate:self];          
    }else if(type == MyTypeComment){
        //delete comment
    }
    
    [dialog showInView:self.view];
}

- (void)showActionSheetForType:(MyType)type
{
    UIActionSheet *actionSheet = nil;
    if (NO) {
        actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:NSLS(@"kOpusOperation")
                                      delegate:self 
                                      cancelButtonTitle:NSLS(@"kCancel") 
                                      destructiveButtonTitle:NSLS(@"kOpusDetail") 
                                      otherButtonTitles:NSLS(@"kDelete"), nil];
    }else if(type == MyTypeComment)
    {
        [self updateCommentIndexes:NO];
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:NSLS(@"kOpusOperation")
                       delegate:self 
                       cancelButtonTitle:NSLS(@"kCancel") 
                       destructiveButtonTitle:NSLS(@"kReply") 
                       otherButtonTitles:NSLS(@"kOpusDetail"), nil];
            
    } else if (type == MyTypeDrawToMe) {
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:NSLS(@"kOpusOperation")
                       delegate:self
                       cancelButtonTitle:NSLS(@"kCancel")
                       destructiveButtonTitle:NSLS(@"kOpusDetail")
                       otherButtonTitles:NSLS(@"kRefuse"), nil];
    }
    [actionSheet showInView:self.view];
    [actionSheet release];

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
    ActionSheetIndexRefuse = 1,
    ActionSheetIndexCancel,
}ActionSheetIndex;

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    MyType type = self.currentTab.tabID;
    if (NO) {
        DrawFeed *feed = _selectRanView.feed;
        
        switch (buttonIndex) {
            case ActionSheetIndexDelete:
            {
                _seletedFeed = feed;
                [self alertDeleteConfirmForType:MyTypeTimelineOpus];
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
    }else if(type == MyTypeComment){
        if (buttonIndex == indexOfCommentReply) {
            PPDebug(@"reply comment");
            [self replyComment:_selectedCommentFeed];
        }else if(buttonIndex == indexOfCommentOpus){
            [self enterOpusDetail:_selectedCommentFeed];
        }
    }else if(type == MyTypeDrawToMe){
        DrawFeed *feed = _selectRanView.feed;
        
        switch (buttonIndex) {
            case ActionSheetIndexRefuse:
            {
                _seletedFeed = feed;
                CommonDialog* dialog = [CommonDialog createDialogWithTitle:nil message:NSLS(@"kAskSureRefuse") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
                    __block MyFeedController* cp = self;
                    
                    [[FeedService defaultService] rejectOpusDrawToMe:feed.feedId resultBlock:^(int resultCode) {
                        if (resultCode == 0) {
                            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kRefuseOpusSuccess") delayTime:1.5];
                            [cp clickRefreshButton:nil];
                        } else {
                            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kRefuseOpusFail") delayTime:1.5];
                        }
                    }];
                    
//                    [[FeedService defaultService] rejectOpusDrawToMe:feed.feedId successBlock:^{
//                        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kRefuseOpusSuccess") delayTime:1.5];
//                        [cp clickRefreshButton:nil];
//                        
//                    } failBlock:^{
//                        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kRefuseOpusFail") delayTime:1.5];
//                    }];
                    
                } clickCancelBlock:^{
                    //
                }];
                [dialog showInView:self.view];
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
    if(tab.tabID == MyTypeDrawToMe && ![rankView.feed isContestFeed]){

        //action sheet
        _selectRanView = rankView;
        [rankView setRankViewSelected:YES];
        [self showActionSheetForType:tab.tabID];
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
    
//    NSString* genderString = gender?@"m":@"f";
//    MyFriend *friend = [MyFriend friendWithFid:userId
//                                      nickName:nickName
//                                        avatar:nil
//                                        gender:genderString
//                                         level:1];
//    [DrawUserInfoView showFriend:friend infoInView:self needUpdate:YES];
    
//    UserDetailViewController* uc = [[[UserDetailViewController alloc] initWithUserDetail:[ViewUserDetail viewUserDetailWithUserId:userId avatar:nil nickName:nickName]] autorelease];
//    [self.navigationController pushViewController:uc animated:YES];
//    return;
    
    [UserDetailViewController presentUserDetail:[ViewUserDetail viewUserDetailWithUserId:userId avatar:nil nickName:nickName] inViewController:self];
}
@end
