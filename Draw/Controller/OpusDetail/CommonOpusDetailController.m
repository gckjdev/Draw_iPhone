//
//  CommonOpusDetailController.m
//  Draw
//
//  Created by 王 小涛 on 13-5-31.
//
//


#define SPACE_CELL_FONT_SIZE ([DeviceDetection isIPAD] ? 26 : 13)
#define SPACE_CELL_FONT_HEIGHT ([DeviceDetection isIPAD] ? 110 : 44)
#define SPACE_CELL_COUNT 7

enum{
    SectionUserInfo = 0,
    SectionOpusInfo,
    SectionActionInfo,
    SectionNumber
};


#import "CommonOpusDetailController.h"
#import "UserDetailViewController.h"
#import "SelfUserDetail.h"
#import "ViewUserDetail.h"
#import "OpusService.h"
#import "CommentCell.h"
#import "PBOpus+Extend.h"
#import "CommonCommentController.h"

@interface CommonOpusDetailController (){
    
}

@property (retain, nonatomic) CommonActionHeader *commonActionHeader;

@end

@implementation CommonOpusDetailController

- (void)dealloc {
    [_commonActionHeader release];
    [_pbOpus release];
    [super dealloc];
}

- (void)viewDidUnload {

    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [self setPullRefreshType:PullRefreshTypeFooter];

    _defaultTabIndex = 0;
    [super viewDidLoad];
    
    [self initTabButtons];
    // Do any additional setup after loading the view from its nib.
    
    self.commonActionHeader = [[_actionHeaderClass class] createHeader:self];
    [_commonActionHeader setDelegate:self];
    [_commonActionHeader setViewInfo:_pbOpus];
    [_commonActionHeader setSeletType:CommentTypeComment];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SectionNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SectionUserInfo:
        case SectionOpusInfo:
            return 1;
        case SectionActionInfo:
            self.noMoreData = ![[_tabManager currentTab] hasMoreData];
            if ([self.feedList count] < SPACE_CELL_COUNT) {
                return SPACE_CELL_COUNT;
            }
            return [self.feedList count];
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    return 0;
    return (section == SectionActionInfo) ? [self heightForActionHeader] : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
            
        case SectionUserInfo:
            return [self heightForUserInfoCell];
            
        case SectionOpusInfo:
            return [self heightForOpusInfoCell];
            
        case SectionActionInfo:
            return [self heightForCommentInfoCellAtRow:indexPath.row];
            
        default:
            return 0;
    }
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == SectionActionInfo){
        return [self headerForAction];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SectionUserInfo:
        {
            return [self cellForUserInfo];
        }
        case SectionOpusInfo:
        {
            return [self cellForOpusInfo];
        }
        case SectionActionInfo:
        {
            return [self cellForCommentInfoAtRow:indexPath.row];
        }
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == SectionUserInfo) {
        [self clickOnAuthor:_pbOpus.author];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != SectionActionInfo) {
        return false;
    }
    if (indexPath.row < [[self feedList] count]) {
        CommentFeed *feed = [[self feedList] objectAtIndex:indexPath.row];
        //can only delete comment feed, but flower and tomato.
        return [feed isMyFeed] || ([_pbOpus isMyOpus] && feed.feedType == FeedTypeComment);
    }
    return NO;
}

- (UIView *)headerForAction{
    
    [_commonActionHeader updateTimes:_pbOpus];
    return _commonActionHeader;
}

- (UITableViewCell *)cellForUserInfo{
    
    CommonUserInfoCell *cell = [self.dataTableView dequeueReusableCellWithIdentifier:[[_userInfoCellClass class] getCellIdentifier]];

    if (cell == nil) {
        cell = [[_userInfoCellClass class] createCell:self];
    }
    
    [cell setUserInfo:_pbOpus.author];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    return cell;
}

- (UITableViewCell *)cellForOpusInfo{
    CommonOpusInfoCell *cell = [self.dataTableView dequeueReusableCellWithIdentifier:[[_opusInfoCellClass class] getCellIdentifier]];
    
    if (cell == nil) {
        cell = [[_opusInfoCellClass class] createCell:self];
    }
    
    [cell setOpusInfo:_pbOpus];
    
    return cell;
}

- (UITableViewCell *)cellForCommentInfoAtRow:(int)row{
    
    if (row >= [self.feedList count]) {
        NSString * identifier = @"emptyCell";
        UITableViewCell *cell = [self.dataTableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
        }
        if (row == 0) {
            [cell.textLabel setTextAlignment:UITextAlignmentCenter];
            [cell.textLabel setFont:[UIFont systemFontOfSize:SPACE_CELL_FONT_SIZE]];
            TableTab *tab = [_tabManager currentTab];
            if (tab.status == TableTabStatusLoading) {
                [cell.textLabel setText:NSLS(@"kLoading")];
            }else if(tab.status == TableTabStatusLoaded){
                [cell.textLabel setText:tab.noDataDesc];
            }
        }else{
            [cell.textLabel setText:nil];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    NSString * identifier = [CommentCell getCellIdentifier];
    CommentCell *cell = [self.dataTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [CommentCell createCell:self];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    CommentFeed *feed = [self.feedList objectAtIndex:row];
    [cell setCellInfo:feed];
    return cell;
}

- (CGFloat)heightForActionHeader{
    return [[_actionHeaderClass class] getHeaderHeight];
}

- (CGFloat)heightForUserInfoCell{
    return [[_userInfoCellClass class] getCellHeight];
}

- (CGFloat)heightForOpusInfoCell{
    return [[_opusInfoCellClass class] getCellHeightWithOpus:_pbOpus];
}

- (CGFloat)heightForCommentInfoCellAtRow:(int)row{

    if (row == 0) {
    }
    if (row >= [self.feedList count]) {
        return SPACE_CELL_FONT_HEIGHT;
    }
    CommentFeed *feed = [self.feedList objectAtIndex:row];
    CGFloat height = [CommentCell getCellHeight:feed];
    return height;
}

- (void)didClickOpusImageButton:(PBOpus *)opus{
    [self clickOnOpus:(PBOpus *)opus];
}

- (void)didClickTargetUserButton:(PBGameUser *)user{
    [self clickOnTargetUser:user];
}

- (void)clickOnAuthor:(PBGameUser *)author{
    
    PPDebug(@"click author");

    UserDetailViewController *vc = [[[UserDetailViewController alloc] initWithUserDetail:[SelfUserDetail createDetail]] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)clickOnOpus:(PBOpus *)opus{
    PPDebug(@"click opus");
}

- (void)clickOnTargetUser:(PBGameUser *)user{
    
    PPDebug(@"click user");
    
    UserDetailViewController *vc = [[[UserDetailViewController alloc] initWithUserDetail:[ViewUserDetail  viewUserDetailWithUserId:user.userId avatar:user.avatar nickName:user.nickName]] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

//- (void)clickAction:(PBOpusActionType)type{
//    
//    PPDebug(@"clickAction: %d", type);
//    if (type == PBOpusActionTypeOpusActionTypeSave) {
//        [self popupMessage:NSLS(@"kNoSaveList") title:nil];
//        return;
//    }
//    
//    _type = type;
//
//    [self clickTab:3];
//}

//- (void)didClickActionButton:(PBOpusActionType)type{
//    
//    [self clickAction:type];
//}


- (NSArray *)feedList
{
    return [[_tabManager currentTab] dataList];
}

#pragma mark-- Common Tab Controller Delegate

- (NSInteger)tabCount
{
    if ([_pbOpus.contestId length] > 0) {
        return 2;
    }
    return 3;
}

//- (NSInteger)currentTabIndex
//{
//    return _defaultTabIndex;
//}

- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 12;
}

- (NSInteger)tabIDforIndex:(NSInteger)index
{
    if ([_pbOpus isContestOpus]) {
        NSInteger tabIDs [] = {CommentTypeComment, CommentTypeFlower, CommentTypeSave};
        return tabIDs[index];
    }else{
        NSInteger tabIDs [] = {CommentTypeComment, CommentTypeGuess, CommentTypeFlower, CommentTypeSave};
        return tabIDs[index];
    }
    
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    return nil;
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{    
    PPDebug(@"<ShowFeedController> load data with tab ID = %d", tabID);
    
    TableTab *tab = [_tabManager tabForID:tabID];
    [[FeedService defaultService] getOpusCommentList:_pbOpus.opusId
                                                type:tab.tabID
                                              offset:tab.offset
                                               limit:tab.limit
                                            delegate:self];
    
//    [[FeedService defaultService] getOpusCommentList:@"512c971de4b02d50d0d20376"
//                                                type:3
//                                              offset:0
//                                               limit:12
//                                            delegate:self];
}

- (void)didGetFeedCommentList:(NSArray *)feedList
                       opusId:(NSString *)opusId
                         type:(int)type
                   resultCode:(NSInteger)resultCode
                       offset:(int)offset
{
    if (resultCode == 0) {
        [self finishLoadDataForTabID:type resultList:feedList];
    }else{
        [self failLoadDataForTabID:type];
    }
}

- (void)didSelectCommentType:(int)type
{
    [self clickTab:type];
}


#pragma mark - comment cell delegate
- (void)didStartToReplyToFeed:(CommentFeed *)feed
{
    PPDebug(@"<didStartToReplyToFeed>, feed type = %d,comment = %@", feed.feedType,feed.comment);
    
    CommonCommentController *replyController = [[CommonCommentController alloc] initWithOpus:_pbOpus feed:feed];
    [self presentModalViewController:replyController animated:YES];
    [replyController release];
}

- (void)didClickAvatar:(MyFriend *)myFriend
{
    [UserDetailViewController presentUserDetail:[ViewUserDetail viewUserDetailWithUserId:myFriend.friendUserId avatar:myFriend.avatar nickName:myFriend.nickName] inViewController:self];
}


@end
