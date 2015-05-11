//
//  GroupHomeController.m
//  Draw
//
//  Created by Gamy on 13-11-5.
//
//

#import "GroupHomeController.h"
#import "GroupService.h"
#import "DrawError.h"
#import "GroupManager.h"
#import "GroupCell.h"
#import "GroupTopicController.h"
#import "CreateGroupController.h"
#import "BBSPostCell.h"
#import "GroupNoticeController.h"
#import "SearchPostController.h"
#import "BBSPostDetailController.h"
#import "SearchGroupController.h"
#import "UIViewController+BGImage.h"
#import "ChatDetailController.h"
#import "ContestController.h"
#import "CommonUserInfoView.h"
#import "GroupFeedController.h"
#import "DrawPlayer.h"
#import "ImagePlayer.h"
#import "GroupDetailController.h"

@interface GroupHomeController ()
{
    UIButton *currentTabButton;
    UIButton *currentGroupSubButton;
    UIButton *currentTopicSubButton;
    GroupService *groupService;
}
@end



@implementation GroupHomeController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        groupService = [GroupService defaultService];
        if ([[UserManager defaultManager] hasUser]){
            [groupService syncFollowGroupIds];
            [groupService syncGroupRoles];
            [groupService syncFollowTopicIds];
        }
    }
    return self;
}

- (void)initTabButtons
{
    NSInteger count = [self tabCount];
    for (int i = 0; i < count; ++ i) {
        GroupTab tab = [self tabIDforIndex:i];
        UIButton *button;
        if ([self isSubGroupTab:tab]) {
            button = (id)[self.subTabsHolder viewWithTag:tab];
            SET_BUTTON_SQUARE_STYLE_YELLOW(button);
            [button setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
            [button setBackgroundImage:IMAGE_FROM_COLOR(COLOR_YELLOW) forState:
             UIControlStateSelected];
        }else if([self isSubTopicTab:tab]){
            button = (id)[self.subTopicTabHolder viewWithTag:tab];
            SET_BUTTON_SQUARE_STYLE_YELLOW(button);
            [button setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
            [button setBackgroundImage:IMAGE_FROM_COLOR(COLOR_YELLOW) forState:
             UIControlStateSelected];
        }else{
            button = (id)[self.tabsHolderView viewWithTag:tab];
            SET_BUTTON_AS_COMMON_TAB_STYLE(button);
        }
        NSString *title = [self tabTitleforIndex:i];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateSelected];
        [button setTitle:title forState:UIControlStateHighlighted];
    }
}

- (UIButton *)defaultTabButton
{
    return (id)[self.tabsHolderView viewWithTag:GroupTabTopic];
}


- (void)updateFooterView
{
    [self.footerView removeFromSuperview];
    NSArray *types = [GroupManager defaultTypesInGroupHomeFooterForTab:self.currentTab.tabID];
    NSArray *images = [GroupUIManager imagesForFooterActionTypes:types];
    
    self.footerView = [DetailFooterView footerViewWithDelegate:self];
    [self.footerView setButtonsWithCustomTypes:types images:images];
    [self.view addSubview:self.footerView];
    PPDebug(@"update footer view, types = %@", types);
}

- (void)updateAtMeBadge
{
    NSInteger badge = [[GroupManager defaultManager] atMeBadge];
    [self.footerView setButton:GroupAtMe badge:badge];
}

- (void)updateChatBadge
{
    NSInteger badge = [[GroupManager defaultManager] chatBadge];
    [self.footerView setButton:GroupChat badge:badge];
}

- (void)updateContestBadge
{
    NSInteger badge = [[GroupManager defaultManager] contestBadge];
    [self.footerView setButton:GroupContest badge:badge];
}

- (void)loadBadge
{
    [[GroupService defaultService] getGroupBadgeWithCallback:^(NSArray *badges, NSError *error) {
        if (!error) {
            [[GroupManager defaultManager] updateBadges:badges];
            [self updateAtMeBadge];
            [self updateChatBadge];
            [self updateContestBadge];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.titleView setTitle:NSLS(@"kGroup")];
    [self.titleView setTarget:self];
    [self.titleView setBackButtonSelector:@selector(clickBack:)];
    [self.titleView setRightButtonAsRefresh];
    [self.titleView setRightButtonSelector:@selector(clickRefreshButton:)];
    
    [self.titleView setRightButtonTitle:NSLS(@"kEnterMyGroup")];
    [self.titleView setRightButtonSelector:@selector(clickEnterMyGroup:)];
    
    [self setDefaultBGImage];
    
    [self initTabButtons];
    [self clickTabButton:[self defaultTabButton]];
    [self updateFooterView];
    [self loadBadge];

    [self registerNotificationWithName:REFRESH_FOLLOW_TOPIC_TAB
                            usingBlock:^(NSNotification *note) {
        [self setNeedRefreshFollowTopicTab];
    }];
    
    [self registerNotificationWithName:REFRESH_FOLLOW_GROUP_TAB
                            usingBlock:^(NSNotification *note) {
        [self setNeedRefreshFollowGroupTab];
    }];

}
    
- (IBAction)clickEnterMyGroup:(id)sender
{
    PBGroup* group = [[GroupManager defaultManager] userCurrentGroup];
    if(group == nil){
        POSTMSG(NSLS(@"kUserHasNoGroupYet"));
        return;
    }
    
    [GroupTopicController enterWithGroupId:group.groupId fromController:self];
}
    
    

- (void)setNeedRefreshFollowGroupTab
{
    TableTab *tab = [_tabManager tabForID:GroupTabGroupFollow];
    tab.status = TableTabStatusUnload;
    tab.offset = 0;
}

- (void)setNeedRefreshFollowTopicTab
{
    TableTab *tab = [_tabManager tabForID:GroupTabTopicFollow];
    tab.status = TableTabStatusUnload;
    tab.offset = 0;
}


- (void)viewDidAppear:(BOOL)animated
{
    [self updateAtMeBadge];
    //update edited group
    [self updateGroupsWithSharedGroup];
    [super viewDidAppear:animated];
    [self.dataTableView reloadData];
}

- (void)updateGroupsWithSharedGroup
{
    NSInteger groupTabs[] = {
        GroupTabGroupFollow,
        GroupTabGroupNew,
        GroupTabGroupBalance,
        GroupTabGroupActive,
        GroupTabGroupFame,
        -1
    };

    NSInteger i = 0;
    PBGroup *sharedGroup = [[GroupManager defaultManager] sharedGroup];
    while (sharedGroup != nil) {
        NSInteger tabID = groupTabs[i];
        if (tabID == -1) {
            break;
        }
        NSMutableArray *list = [_tabManager dataListForTabID:tabID];
        NSUInteger index = [list indexOfObject:sharedGroup];
        if (index != NSNotFound) {
            [list replaceObjectAtIndex:index withObject:sharedGroup];
        }
        ++ i;        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isMainTab:(NSInteger)tab
{
    return GroupTabTopic == tab || GroupTabGroup == tab;
}

- (BOOL)isGroupTab:(NSInteger)tab
{
    return (GroupTabGroup == tab || [self isSubGroupTab:tab]);
}

- (BOOL)isTopicTab:(NSInteger)tab
{
    return (GroupTabTopic == tab || [self isSubTopicTab:tab]);
}

- (BOOL)isSubGroupTab:(NSInteger)tab
{
    NSArray *tabs =@[
                    @(GroupTabGroupFollow),
                    @(GroupTabGroupNew),
                    @(GroupTabGroupBalance),
                    @(GroupTabGroupActive),
                    @(GroupTabGroupFame)];
    return [tabs containsObject:@(tab)];
}

- (BOOL)isSubTopicTab:(NSInteger)tab
{
    NSArray *tabs =@[
                     @(GroupTabTopicHot),
                     @(GroupTabTopicNew),
                     @(GroupTabTopicMine),
                     @(GroupTabTopicFollow),
                     @(GroupTabTopicGroup)];
    return [tabs containsObject:@(tab)];
}

- (GroupTab)defaultTopicTab
{
    if([[[GroupManager defaultManager] followedGroupIds] count] > 0){
        return GroupTabTopicGroup;
    }
    return GroupTabTopicNew;
}

- (GroupTab)defaultGroupTab
{
    if([[[GroupManager defaultManager] followedGroupIds] count] > 0){
        return GroupTabGroupFollow;
    }
    return GroupTabGroupNew;
}

#define TOPIC_TABLE_DELTA (ISIPAD?10:5)
#define TOPIC_TABLE_WIDTH (ISIPAD?700:300)
#define GROUP_TABLE_WIDTH (ISIPAD?768:320)



- (void)clickTabButton:(id)sender
{
    
    UIButton *button = (UIButton *)sender;
    
//    if ([button isSelected]) {
//        return;
//    }
    
    NSInteger tabID = button.tag;
    
    
    if ([self isMainTab:tabID]) {
        if (currentTabButton != button) {
            currentTabButton.selected = NO;
            button.selected = YES;
        }
        currentTabButton = button;
        
        if ([self isGroupTab:tabID]) {
            id subButton = currentGroupSubButton;
            if (!subButton) {
                subButton = [self.subTabsHolder viewWithTag:[self defaultGroupTab]];
            }
            self.subTabsHolder.hidden = NO;
            self.subTopicTabHolder.hidden = YES;
            
            [self clickTabButton:subButton];
        }else {
            id subButton = currentTopicSubButton;
            if (!subButton) {
                subButton = [self.subTopicTabHolder viewWithTag:[self defaultTopicTab]];
            }
            self.subTabsHolder.hidden = YES;
            self.subTopicTabHolder.hidden = NO;

            [self clickTabButton:subButton];
        }
    }else{
        if ([self isGroupTab:tabID] && currentGroupSubButton != button) {
            currentGroupSubButton.selected = NO;
            button.selected = YES;
            currentGroupSubButton = button;
        }else if ([self isTopicTab:tabID] && currentTopicSubButton != button) {
            currentTopicSubButton.selected = NO;
            button.selected = YES;
            currentTopicSubButton = button;
        }
        [self clickTab:tabID];
    }
}

- (NSInteger)tabCount
{
    return 12;
}
- (NSInteger)currentTabIndex
{
    return 0;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 20;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabs[] = {
        GroupTabGroup,
        GroupTabTopic,

        //group sub tabs
        GroupTabGroupFollow,
        GroupTabGroupNew,
        GroupTabGroupBalance,
        GroupTabGroupActive,
        GroupTabGroupFame,
        
        //topic sub tabs
        GroupTabTopicFollow,
        GroupTabTopicMine,
        GroupTabTopicGroup,
        GroupTabTopicNew,
        GroupTabTopicHot,
    };
    return tabs[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *titles[]={
        NSLS(@"kGroupTabGroup"),
        NSLS(@"kGroupTabTopic"),

        NSLS(@"kGroupTabGroupFollow"),
        NSLS(@"kGroupTabGroupNew"),
        NSLS(@"kGroupTabGroupBalance"),
        NSLS(@"kGroupTabGroupActive"),
        NSLS(@"kGroupTabGroupFame"),
        
        NSLS(@"kGroupTabTopicFollow"),
        NSLS(@"kGroupTabTopicMine"),
        NSLS(@"kGroupTabTopicGroup"),
        NSLS(@"kGroupTabTopicNew"),
        NSLS(@"kGroupTabTopicHot"),
    };
    return titles[index];
}


- (NSString *)noDataCellContent
{
    if ([self isGroupTab:[self currentTabID]]) {
        return NSLS(@"kNoGroup");
    }
    return NSLS(@"kNoTopic");
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    //test
    TableTab *tab = [_tabManager tabForID:tabID];

    ListResultBlock callback = ^(NSArray *list, NSError *error){
        [self hideActivity];
        if (error) {
            [self failLoadDataForTabID:tabID];
        }else{
            [self finishLoadDataForTabID:tabID resultList:list];
        }
    };
    [self showActivityWithText:NSLS(@"kLoading")];
    
    switch (tabID) {
        case GroupTabGroupFollow:
        case GroupTabGroupNew:
        case GroupTabGroupBalance:
        case GroupTabGroupActive:
        case GroupTabGroupFame:
        {
            [[GroupService defaultService] getGroupsWithType:tabID
                                                      offset:tab.offset
                                                       limit:tab.limit
                                                    callback:callback];
            break;
        }
        case GroupTabGroup:
        {
            [self finishLoadDataForTabID:tabID resultList:nil];
            break;
        }
        case GroupTabTopicFollow:
        {
            [[GroupService defaultService] getFollowedTopicList:tab.offset
                                                          limit:tab.limit
                                                       callback:callback];
            break;
        }
        case GroupTabTopicGroup:
        {
            [[GroupService defaultService] getTopicTimelineList:tab.offset
                                                          limit:tab.limit
                                                       callback:callback];
            break;
        }
        case GroupTabTopicHot:
        case GroupTabTopicNew:
        case GroupTabTopicMine:
            //get topic list.
        {
            [[GroupService defaultService] getTopicListByType:tabID
                                                       offset:tab.offset
                                                        limit:tab.limit
                                                     callback:callback];
            break;
        }
        
        default:
            [self finishLoadDataForTabID:tabID resultList:nil];
            [self hideActivity];
            break;
    }
}

- (void)detailFooterView:(DetailFooterView *)footer
        didClickAtButton:(UIButton *)button
                    type:(NSInteger)type
{
    switch (type) {
        case GroupCreateGroup:
        {
            if([[GroupManager defaultManager] userCurrentGroupId]){
                NSString *msg = [NSString stringWithFormat:NSLS(@"kCan'tCreateGroup"), [[GroupManager defaultManager] userCurrentGroupName]];
                POSTMSG(msg);
                return;
            }
            if (![GroupPermissionManager amIGroupTestUser]) {
                POSTMSG(NSLS(@"kNotTestUserCan'tCreateGroup"));
                return;                
            }

#ifndef DEBUG
            NSInteger minUserLevel = [PPConfigManager getUserMinLevelForCreateGroup];
            if([[UserManager defaultManager] level] < minUserLevel){
                NSString *msg = [NSString stringWithFormat:NSLS(@"kCan'tCreateGroupForUserLevel"), minUserLevel];
                POSTMSG(msg);
                return;
            }
#endif
            CreateGroupController *cgc =  [[CreateGroupController alloc] init];
            [self.navigationController pushViewController:cgc animated:YES];
            [cgc release];
            break;
        }

         case GroupSearchGroup:
        {
            if ([self currentTabISGroupTab]) {
                SearchGroupController *sgc = [[SearchGroupController alloc] init];
                [self.navigationController pushViewController:sgc animated:YES];
                [sgc release];
            }else{
                SearchPostController *spc = [[SearchPostController alloc] init];
                spc.forGroup = YES;
                [self.navigationController pushViewController:spc animated:YES];
                [spc release];                
            }
            break;
        }
         case GroupChat:
        {
//            PBGroupBuilder* builder = [PBGroup builder];
//            [builder setGroupId:@"888800000000001234567890"];
//            [builder setName:@"Test Group"];
            
            PBGroup* group = [[GroupManager defaultManager] userCurrentGroup];
            [ChatDetailController enterFromGroup:group superController:self];            
        }
            
            break;
         case GroupAtMe:
        {
            GroupNoticeController *gnc = [[GroupNoticeController alloc] init];
            [self.navigationController pushViewController:gnc animated:YES];
            [gnc release];
        }
            break;
         case GroupContest:
        {            
            ContestController *vc = [[[ContestController alloc] initWithGroupDefault] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
            break;
        case GroupTimeline:
        {
            GroupFeedController *gfc = [[GroupFeedController alloc] init];
            gfc.groupId = [[GroupManager defaultManager] userCurrentGroupId];
            [self.navigationController pushViewController:gfc animated:YES];
            [gfc release];
            break;
        }
            
        default:
            break;
    }
    PPDebug(@"click type = %d", type);
}

- (BOOL)currentTabISGroupTab
{
    return [self isGroupTab:self.currentTab.tabID];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self noData]) {
        return [self noDataCellHeight];
    }
    if ([self currentTabISGroupTab]) {
        return [GroupCell getCellHeight];
    }else{
        PBBBSPost *post = [self.tabDataList objectAtIndex:indexPath.row];
        return [BBSPostCell getCellHeightWithBBSPost:post];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
    if (count == 0 && [self noData]) {
        return 1;
    }
    return count;
}


- (BOOL)noData
{
    return [self.tabDataList count] == 0 && [self.currentTab status] == TableTabStatusLoaded;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self noData]) {
        return [self noDataCell];
    }
    Class cellClass = [self currentTabISGroupTab] ? [GroupCell class] : [BBSPostCell class];
    NSString *identifier = [cellClass getCellIdentifier];
    PPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [cellClass createCell:self];
    }
    id data = [self.tabDataList objectAtIndex:indexPath.row];
    if ([cell isKindOfClass:[GroupCell class]]) {
        [(GroupCell *)cell setShowBalance:([self currentTabID] == GroupTabGroupBalance)];
    }
    [(id)cell setCellInfo:data];
    cell.indexPath = indexPath;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return [view autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self isGroupTab:self.currentTabID]) {
        return 0;
    }
    return ISIPAD?20:8;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self noData]) {
        return;
    }

    id data = [self.tabDataList objectAtIndex:indexPath.row];
    if ([data isKindOfClass:[PBGroup class]]) {
        [GroupTopicController enterWithGroup:data fromController:self];
    }else if([data isKindOfClass:[PBBBSPost class]]){
        [BBSPostDetailController enterGroupPostDetailController:data fromController:self animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    
    if([self isNoDataCell:cell] || ![self isGroupTab:self.currentTabID]){
        cell.backgroundColor = [UIColor clearColor];        
        return;
    }
    cell.backgroundColor = (indexPath.row & 0x1)? COLOR_GRAY : COLOR_WHITE;
}

- (void)groupCell:(GroupCell *)cell goFollowGroup:(PBGroup *)group
{
    [self showActivityWithText:NSLS(@"kFollowing")];
    [[GroupService defaultService] followGroup:group.groupId
                                      callback:^(NSError *error) {
       [self hideActivity];
       if (!error) {
//           [self setNeedRefreshFollowGroupTab];
           [self.dataTableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationFade];
       }                                          
    }];
}

- (void)groupCell:(GroupCell *)cell goUnfollowGroup:(PBGroup *)group
{
    [self showActivityWithText:NSLS(@"kUnfollowing")];
    [[GroupService defaultService] unfollowGroup:group.groupId
                                        callback:^(NSError *error) {
        [self hideActivity];
        if (!error) {
            
            if (self.currentTabID == GroupTabGroupFollow) {
                [self.tabDataList removeObjectAtIndex:cell.indexPath.row];
                [self.dataTableView deleteRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }else{
//                [self setNeedRefreshFollowGroupTab];
                [self.dataTableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
                                            
    }];
}

- (void)dealloc {
    
    [[ChatService defaultService] cleanUserMessage];
    
    [_subTabsHolder release];
    [_footerView release];
    [_tabsHolderView release];
    [GroupPermissionManager clearGroupRoles];
    [_subTopicTabHolder release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setFooterView:nil];
    [self setTabsHolderView:nil];
    [self setSubTopicTabHolder:nil];
    [super viewDidUnload];
}

- (void)didClickUserAvatar:(PBBBSUser *)user
{
    PPDebug(@"<didClickUserAvatar>, userId = %@",user.userId);
    [CommonUserInfoView showPBBBSUser:user
                         inController:self
                           needUpdate:YES
                              canChat:YES];
    
}


#pragma topic cell delegate

- (void)didClickImageWithURL:(NSURL *)url
{
    [[ImagePlayer defaultPlayer] playWithUrl:url displayActionButton:YES onViewController:self];
}

- (void)didClickDrawImageWithPost:(PBBBSPost *)post
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [[BBSService groupTopicService] getBBSDrawDataWithPostId:post.postId
                                       actionId:nil
                                       delegate:self];
}


#pragma mark-- BBS Service Delegate

- (void)didGetBBSDrawActionList:(NSMutableArray *)drawActionList
                drawDataVersion:(NSInteger)version
                     canvasSize:(CGSize)canvasSize
                         postId:(NSString *)postId
                       actionId:(NSString *)actionId
                     fromRemote:(BOOL)fromRemote
                     resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        BOOL isNewVersion = [PPConfigManager currentDrawDataVersion] < version;

        ReplayObject* obj = [ReplayObject objectWithActionList:drawActionList
                                                  isNewVersion:isNewVersion
                                                    canvasSize:canvasSize
                                                        layers:[DrawLayer defaultOldLayersWithFrame:CGRectFromCGSize(canvasSize)]];
        
        DrawPlayer *player =[DrawPlayer playerWithReplayObj:obj];
        [player showInController:self];
        
    }else{
        PPDebug(@"<didGetBBSDrawActionList> fail!, resultCode = %d",resultCode);
    }
}

#pragma mark - BBSPost cell delegate
- (void)didClickSupportButtonWithPost:(PBBBSPost *)post
{
    // ENTER DETAIL CONTROLLER
    BBSPostDetailController *bbsDetail = [[BBSPostDetailController alloc]initWithDefaultTabIndex:0];
    bbsDetail.post = post;
    bbsDetail.forGroup = YES;
    [self.navigationController pushViewController:bbsDetail animated:YES];
    [bbsDetail release];
    
}
- (void)didClickReplyButtonWithPost:(PBBBSPost *)post
{
    // ENTER DETAIL CONTROLLER
    BBSPostDetailController *bbsDetail = [[BBSPostDetailController alloc]initWithDefaultTabIndex:1];
    bbsDetail.post = post;
    bbsDetail.forGroup = YES;
    [self.navigationController pushViewController:bbsDetail animated:YES];
    [bbsDetail release];
    
}

@end
