//
//  HotController.m
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ContestOpusController.h"
#import "TableTabManager.h"
#import "ShareImageManager.h"
#import "ShowFeedController.h"
#import "UserDetailViewController.h"
#import "ViewUserDetail.h"
#import "Contest.h"
#import "UseItemScene.h"
#import "MyFriend.h"

#import "PPConfigManager.h"
#import "CellManager.h"
#import "OfflineDrawViewController.h"
#import "StatementController.h"
#import "GroupManager.h"
#import "CreateContestController.h"

typedef enum{
    OpusTypeMy = 1,
    OpusTypeRank = 2,
    OpusTypeNew = 3,
    OpusTypeGroupContestRule = 4,
    OpusTypeReport = CommentTypeContestComment,
    OpusTypePrize = 21,//FeedListTypeIdList
    
}OpusType;

#define  HISTORY_RANK_NUMBER [PPConfigManager historyRankNumber]

@implementation ContestOpusController
@synthesize contest = _contest;

- (id)initWithContest:(Contest *)contest
{
    self = [super init];
    if(self){
        self.contest = contest;
        _defaultTabIndex = 1;
    }
    return self;
}

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


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self initTabButtons];
//    [self.titleLabel setText:NSLS(@"kContestRank")];
    [self.titleView setTitle:self.contest.title]; //NSLS(@"kContestRank")];
    [self.titleView setTarget:self];
    [self.titleView setBackButtonSelector:@selector(clickBackButton:)];
    
    if ([self.contest isGroupContest]
        && [self.contest isRunning]
        && [self.contest isContesting]
//        && [self.contest canSubmit]
//        && [self.contest canUserJoined:[[UserManager defaultManager] userId]]
//        && ![self.contest commitCountEnough]
        )
    {
        [self.titleView setRightButtonTitle:NSLS(@"kJoinContest")];
        [self.titleView setRightButtonSelector:@selector(clickJoinConest)];
    }
    

    if ([self.contest isGroupContest]
        && [self.contest isRunning]
        && [self.contest isNotStart]) {
        GroupPermissionManager *permission =[GroupPermissionManager myManagerWithGroupId:[self.contest pbGroup].groupId];
        if ([permission canHoldContest]) {
            [self.titleView setRightButtonTitle:NSLS(@"kManage")];
            [self.titleView setRightButtonSelector:@selector(clickEditContest)];
        }
    }
    
    SET_COMMON_TAB_TABLE_VIEW_Y(self.dataTableView);
    self.view.backgroundColor = COLOR_WHITE;
    self.dataTableView.allowsSelection = YES;
}

- (void)clickJoinConest{
    
    CHECK_AND_LOGIN(self.view);
    
    if (![self.contest canSubmit]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kContestSubmitEnd") delayTime:1.5 isHappy:NO];
        return;
    }
    
    if (![self.contest canUserJoined:[[UserManager defaultManager] userId]]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kContestNotForUser") delayTime:1.5 isHappy:NO];
        return;
    }
    
    if([self.contest commitCountEnough]){
        NSString *title = [NSString stringWithFormat:NSLS(@"kContestCommitCountEnough"),self.contest.canSubmitCount];
        [[CommonMessageCenter defaultCenter] postMessageWithText:title
                                                       delayTime:1.5
                                                         isHappy:NO];
        return;
    }
    
    [self alertCopyrightStatement:^{
        if ([self.contest joined]) {
            [OfflineDrawViewController startDrawWithContest:self.contest
                                             fromController:self
                                            startController:self
                                                   animated:YES];
        }else{
            StatementController *sc = [[StatementController alloc] initWithContest:self.contest];
            sc.superController = self;
            [self.navigationController pushViewController:sc animated:YES];
            [sc release];
        }
    }];
}

- (void)clickEditContest{
    
    [CreateContestController enterFromController:self withContest:self.contest];
}

- (void)alertCopyrightStatement:(void (^)(void))block{
    if (![PPConfigManager isInReviewVersion]) {
        EXECUTE_BLOCK(block);
        return;
    }
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kHint") message:NSLS(@"kContestCopyright") style:CommonDialogStyleSingleButton];
    [dialog setClickOkBlock:^(id infoView){
        EXECUTE_BLOCK(block);
    }];
    [dialog showInView:self.view];
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
    switch ([[self currentTab] tabID]) {
        case OpusTypeReport:
            return [CellManager getReportStyleCellheightWithDataList:self.tabDataList
                                                           indexPath:indexPath];
            break;
            
        case OpusTypePrize:
            return [CellManager getPrizeStyleCellHeight];
            break;
            
        case OpusTypeRank:
            return [CellManager getHotStyleCellHeightWithIndexPath:indexPath];
            break;
            
        case OpusTypeNew:
        case OpusTypeMy:
            return [CellManager getLastStyleCellHeightWithIndexPath:indexPath];
            break;
            
        case OpusTypeGroupContestRule:
            return [CellManager getContestRuleCellHeight:indexPath contest:self.contest];
            break;
            
        default:
            return 0;
            break;
    }

}



- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch ([[self currentTab] tabID]) {
        case OpusTypeReport:
            return [CellManager getReportStyleCell:theTableView
                                         indexPath:indexPath
                                          delegate:self
                                          dataList:self.tabDataList
                                           contest:self.contest];
            break;
            
        case OpusTypePrize:
            return [CellManager getPrizeStyleCell:theTableView
                                        indexPath:indexPath
                                         delegate:self
                                         dataList:self.tabDataList
                                          contest:self.contest];
            break;
            
        case OpusTypeRank:
            return [CellManager getHotStyleCell:theTableView
                                      indexPath:indexPath
                                       delegate:self
                                       dataList:self.tabDataList];
            break;
        
        case OpusTypeNew:
        case OpusTypeMy:
            return [CellManager getLastStyleCell:theTableView
                                       indexPath:indexPath
                                        delegate:self
                                        dataList:self.tabDataList];
            break;
            
        case OpusTypeGroupContestRule:
            return [CellManager getContestRuleCell:theTableView
                                         indexPath:indexPath
                                          delegate:self
                                           contest:self.contest];
            break;
            
        default:
            return nil;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContestFeed *opus = nil;
    if (self.currentTab.tabID == OpusTypePrize) {        
        PBUserAward *aw = [self.currentTab.dataList objectAtIndex:indexPath.row];
        opus = [_contest getOpusWithAwardType:aw.awardType.key rank:aw.rank];
        
    }else if(self.currentTab.tabID == OpusTypeReport){
        CommentFeed *feed  = self.currentTab.dataList[indexPath.row];
        opus = (ContestFeed *)feed.drawFeed;
    }
    
    if (opus == nil) {
        PPDebug(@"<didSelectRowAtIndexPath> opus is nil");
        return;
    }else{
        UseItemScene* scene ;
        if ([self.contest isRunning]) {
            scene = [UseItemScene createSceneByType:UseSceneTypeDrawMatch feed:opus];
        } else {
            scene = [UseItemScene createSceneByType:UseSceneTypeMatchRank feed:opus];
        }
        ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:opus scene:scene];
        if (self.currentTab.tabID != OpusTypeReport) {
            [sc showOpusImageBrower];
        }
        [self.navigationController pushViewController:sc animated:YES];
        [sc release];
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];

    switch ([[self currentTab] tabID]) {
        case OpusTypeReport:
            return [CellManager getReportStyleCellCountWithDataCount:count];
            break;
            
        case OpusTypePrize:
            return [CellManager getPrizeStyleCellCountWithDataCount:count];
            break;
            
        case OpusTypeRank:
            return [CellManager getHotStyleCellCountWithDataCount:count
                                                       roundingUp:YES];
            break;
            
        case OpusTypeNew:
        case OpusTypeMy:
            return [CellManager getLastStyleCellCountWithDataCount:count
                                                        roundingUp:YES];
            break;
            
        case OpusTypeGroupContestRule:
            return [CellManager getContestRuleCellCount];
            break;
            
        default:
            return 0;
            break;
    }
}


#pragma mark common tab controller

- (NSInteger)tabCount
{
//    if ([self.contest isGroupContest]) {
//        return 3;
//    }else{
//        return 4;
//    }
    return 4;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 24;
}

- (NSInteger)tabIDforIndex:(NSInteger)index
{
    if ([self.contest isGroupContest]) {
        NSInteger tabId[] = {OpusTypeRank,OpusTypeNew,OpusTypeMy,OpusTypeGroupContestRule};
        if ([self.contest isPassed]) {
            [[self.view viewWithTag:OpusTypeNew] setTag:OpusTypePrize];
            tabId[1] = OpusTypePrize;
        }
        return tabId[index];
    }else{
        NSInteger tabId[] = {OpusTypeReport,OpusTypeRank,OpusTypeNew,OpusTypeMy};
        if ([self.contest isPassed]) {
            [[self.view viewWithTag:OpusTypeNew] setTag:OpusTypePrize];
            tabId[2] = OpusTypePrize;
        }
        return tabId[index];
    }
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    return NSLS(@"kNoData");
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    if ([self.contest isGroupContest]) {
        NSString *tabTitle[] = {NSLS(@"kOpusRank"),NSLS(@"kOpusNew"),NSLS(@"kOpusMy"),NSLS(@"kContestRule")};
        if ([self.contest isPassed]) {
            tabTitle[1] = NSLS(@"kContestPrize");
        }
        return tabTitle[index];
    }else{
        NSString *tabTitle[] = {NSLS(@"kContestReport"), NSLS(@"kOpusRank"),NSLS(@"kOpusNew"),NSLS(@"kOpusMy")};        
        if ([self.contest isPassed]) {
            tabTitle[2] = NSLS(@"kContestPrize");
        }
        return tabTitle[index];
    }
}


- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    
    [self showActivityWithText:NSLS(@"kLoading")];
    TableTab *tab = [_tabManager tabForID:tabID];
    
    switch (tab.tabID) {
        case OpusTypePrize:
            [self loadPrize];
            break;

        case OpusTypeReport:
            [self loadReport:tab];
            break;
            
        case OpusTypeMy:
        case OpusTypeNew:
        case OpusTypeRank:
            [self loadOpus:tab];
            break;
            
        case OpusTypeGroupContestRule:
            [self loadContestRules];
            break;

        default:
            break;
    }
}

- (void)loadPrize{
    //TODO get reward
    PPDebug(@"get contest reward.");
    NSArray *list = [_contest awardOpusIdList];
    [[FeedService defaultService] getFeedListByIds:list delegate:self];
}

- (void)loadReport:(TableTab *)tab{
    
    [[FeedService defaultService] getContestCommentFeedList:self.contest.contestId
                                                     offset:tab.offset
                                                      limit:tab.limit
                                                   delegate:self];
}

- (void)loadOpus:(TableTab *)tab{
    
    [[FeedService defaultService] getContestOpusList:tab.tabID
                                           contestId:self.contest.contestId
                                              offset:tab.offset
                                               limit:tab.limit
                                            delegate:self];
}

- (void)loadContestRules{
    
    
    [self performSelector:@selector(finishLoadContestRules) withObject:nil afterDelay:0.3];
}

- (void)finishLoadContestRules{
    [self hideActivity];
    [self finishLoadDataForTabID:OpusTypeGroupContestRule resultList:nil];
    [self hideTipsOnTableView];
}

#pragma mark - feed service delegate

- (void)didGetContestOpusList:(NSArray *)feedList 
                         type:(int)type 
                   resultCode:(NSInteger)resultCode
{
    PPDebug(@"<didGetFeedList> list count = %d ", [feedList count]);
    [self hideActivity];
    if (resultCode == 0) {
        if (type == OpusTypeMy || type == OpusTypeNew || type == OpusTypeRank) {
            [self finishLoadDataForTabID:type resultList:feedList];
        }
    }else{
        [self failLoadDataForTabID:type];
    }
}

//for test
- (void)didGetFeedCommentList:(NSArray *)feedList
                       opusId:(NSString *)opusId
                         type:(int)type
                   resultCode:(NSInteger)resultCode
                       offset:(int)offset
{
    if (resultCode == 0) {
        [self finishLoadDataForTabID:OpusTypeReport resultList:feedList];        
    }
}


// for report feed list
- (void)didGetFeedList:(NSArray *)feedList
          feedListType:(FeedListType)type
            resultCode:(NSInteger)resultCode
{
    PPDebug(@"<didGetFeedList> list count = %d ", [feedList count]);
    [self hideActivity];
    if (resultCode == 0) {
        if(type == OpusTypeReport){
            [self finishLoadDataForTabID:OpusTypeReport resultList:feedList];
        }else if(type == OpusTypePrize){
            [_contest setAwardOpusList:feedList];
            NSMutableArray *list = [_tabManager dataListForTabID:OpusTypePrize];
            [list removeAllObjects];
            TableTab *tab = [_tabManager tabForID:OpusTypePrize];
            [self finishLoadDataForTabID:OpusTypePrize resultList:_contest.awardList];
            tab.offset = 0;
            tab.hasMoreData = NO;
            [self.dataTableView reloadData];
        }else{
            [self finishLoadDataForTabID:OpusTypeReport resultList:feedList];
        }
    }else{
        [self failLoadDataForTabID:type];
    }
}


#pragma mark Rank View delegate
- (void)didClickRankView:(RankView *)rankView
{
    UseItemScene* scene ;
    if ([self.contest isRunning]) {
        scene = [UseItemScene createSceneByType:UseSceneTypeDrawMatch feed:rankView.feed];
    } else {
        scene = [UseItemScene createSceneByType:UseSceneTypeMatchRank feed:rankView.feed];
    }
    ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:rankView.feed scene:scene];
    [sc showOpusImageBrower];
    sc.feedList = [[self currentTab] dataList];
    [self.navigationController pushViewController:sc animated:YES];
    [sc release];
}


- (void)didClickTopPlayerView:(TopPlayerView *)topPlayerView
{
    TopPlayer *player = topPlayerView.topPlayer;
    [UserDetailViewController presentUserDetail:[ViewUserDetail viewUserDetailWithUserId:player.userId avatar:player.avatar nickName:player.nickName] inViewController:self];
}

- (void)clickTab:(NSInteger)tabID{
    [super clickTab:tabID];
    if (tabID == OpusTypeGroupContestRule) {
        [self hideTipsOnTableView];
    }
}

@end
