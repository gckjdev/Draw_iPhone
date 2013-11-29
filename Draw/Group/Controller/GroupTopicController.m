//
//  GroupTopicController.m
//  Draw
//
//  Created by Gamy on 13-11-19.
//
//

#import "GroupTopicController.h"
#import "DetailFooterView.h"
#import "GroupInfoView.h"
#import "BBSPostCell.h"
#import "BBSModelExt.h"
#import "Group.pb.h"
#import "GroupService.h"
#import "BBSPostDetailController.h"
#import "BBSManager.h"
#import "SearchPostController.h"

typedef enum{
    NewestTopic = 1,
    MarkedTopic = 2,
}TopicType;

typedef enum {
    RowGroupInfo = 0,
    RowTopicHeader,
    BasicRowCount,
}CellRow;

@interface GroupTopicController ()
{
    BBSService *topicService;
    GroupPermissionManager *permissonManager;
    GroupService *groupService;
}
@property(nonatomic, retain)BBSPostActionHeaderView *topicHeader;
@property(nonatomic, retain)UITableViewCell *infoCell;
@property(nonatomic, retain)PBGroup *group;
@property (retain, nonatomic) IBOutlet DetailFooterView *footerView;
@end

@implementation GroupTopicController

+ (GroupTopicController *)enterWithGroup:(PBGroup *)group
                          fromController:(PPViewController *)controller;
{
    GroupTopicController *gt = [[GroupTopicController alloc] init];
    gt.group = group;
    [controller.navigationController pushViewController:gt animated:YES];
    return [gt autorelease];
}

- (id)init
{
    self = [super init];
    if (self) {
        topicService = [BBSService groupTopicService];
        groupService = [GroupService defaultService];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_topicHeader);
    PPRelease(_infoCell);
    PPRelease(_group);
    PPRelease(permissonManager);
    [_footerView release];
    [[BBSManager defaultManager] setTempPostList:nil];
    [super dealloc];
}

- (void)clickJoinOrQuit:(id)sender
{
    UIButton *button = sender;
    if ([permissonManager canJoinGroup]) {
        [self showActivityWithText:NSLS(@"kJoiningGroup")];
        [groupService joinGroup:_group.groupId message:nil callback:^(NSError *error) {
            [self hideActivity];
            if (!error) {
                POSTMSG(NSLS(@"kSentRequest"));
                button.hidden = YES;
            }
        }];
    }else if ([permissonManager canQuitGroup]) {
        [self showActivityWithText:NSLS(@"kQuitingGroup")];
        //TODO to comfirm
        [groupService quitGroup:_group.groupId callback:^(NSError *error) {
            [self hideActivity];
            if (!error) {
                POSTMSG(NSLS(@"kQuitedGroup"));
                PBGroup *group = [groupService buildGroupWithDefaultRelation:self.group];
                [self updateGroup:group];
            }
        }];
    }else if([permissonManager canDismissalGroup]){
        //TODO dissmissal
    }
}

- (void)updateFooterView
{
    [self.footerView removeFromSuperview];
    self.footerView = [DetailFooterView footerViewWithDelegate:self];
    NSArray *types = [GroupManager defaultTypesInGroupTopicFooter:_group];
    NSArray *images = [GroupUIManager imagesForFooterActionTypes:types];
    [self.footerView setButtonsWithCustomTypes:types images:images];
    [self.view addSubview:self.footerView];
}

- (void)detailFooterView:(DetailFooterView *)footer
        didClickAtButton:(UIButton *)button
                    type:(NSInteger)type
{
    PPDebug(@"click type  = %d", type);
    switch (type) {
        case GroupCreateTopic:
        {
            if (![permissonManager canCreateTopic]) {
                POSTMSG(NSLS(@"kCanotCreateTopic"));
                return;
            }
            CreatePostController* cpc = [CreatePostController enterControllerWithGroup:_group fromController:self];
            cpc.delegate = self;
            break;
        }
        case GroupChat:
            if (![permissonManager canGroupChat]) {
                POSTMSG(NSLS(@"kCanotGroupChat"));
                return;
            }
            
            break;
            
        case GroupSearchTopic:
        {
            SearchPostController *spc = [[SearchPostController alloc] init];
            spc.forGroup = YES;
            spc.group = self.group;
            [self.navigationController pushViewController:spc animated:YES];
            [spc release];
        }
            break;
            
        default:
            break;
    }
}

- (void)updateTitleView
{
    [self.titleView setTransparentStyle];
    [self.titleView setTitle:_group.name];
    [self.titleView setRightButtonSelector:@selector(clickJoinOrQuit:)];
}

- (void)updateGroup:(PBGroup *)group
{
    permissonManager.group = group;
    self.group = group;
    
    [self.titleView.rightButton setHidden:NO];
    if ([permissonManager canJoinGroup]) {
        [self.titleView setRightButtonTitle:NSLS(@"kJoinGroup")];
    }else if([permissonManager canQuitGroup]){
        [self.titleView setRightButtonTitle:NSLS(@"kQuitGroup")];
    }else if([permissonManager canDismissalGroup]){
        [self.titleView setRightButtonTitle:NSLS(@"kDissolveGroup")];
    }else{
        [self.titleView.rightButton setHidden:YES];
    }
}

- (void)loadGroupRelation
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [groupService getRelationWithGroup:_group.groupId callback:^(PBUserRelationWithGroup *relation, NSError *error) {
        if (!error) {
            PBGroup *group = [groupService buildGroup:self.group withRelation:relation];
            [self updateGroup:group];
        }
    }];
}

- (void)viewDidLoad
{
    permissonManager = [GroupPermissionManager myManagerWithGroup:_group];
    [permissonManager retain];
    [super viewDidLoad];
    [self updateTitleView];
    [self updateFooterView];
    [self clickTab:NewestTopic];
    [self loadGroupRelation];
    self.unReloadDataWhenViewDidAppear = NO;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-- TableView delegate


- (PBBBSPost *)postInIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row - BasicRowCount;
    PBBBSPost *post = self.tabDataList[row];
    if (![post isKindOfClass:[PBBBSPost class]]) {
        PPDebug(@"<postInIndexPath> error happened.");
    }
    return post;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case RowGroupInfo:
            return [GroupInfoView getViewHeight];
        case RowTopicHeader:
            return [BBSPostActionHeaderView getViewHeight];
        default:
        {
            PBBBSPost *post = [self postInIndexPath:indexPath];
            return [BBSPostCell getCellHeightWithBBSPost:post];
        }
    }
    return 0;
}

- (void)updateTopicHeader
{
    if(self.topicHeader == nil){
        self.topicHeader = [BBSPostActionHeaderView createView:self];
        [self.topicHeader updateleftName:NSLS(@"kLatest") rightName:NSLS(@"kMarked")];
    }
}

- (void)updateGroupInfo
{
    if (self.infoCell == nil) {
        self.infoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupInfoCell"];
        GroupInfoView *infoView = [GroupInfoView infoViewWithGroup:_group];
        infoView.delegate = self;
        [self.infoCell.contentView addSubview:infoView];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    switch (row) {
        case RowGroupInfo:
        {
            [self updateGroupInfo];
            return self.infoCell;
        }
        case RowTopicHeader:
        {
            [self updateTopicHeader];
            return self.topicHeader;
        }
        default:
        {
            BBSPostCell *cell = [tableView dequeueReusableCellWithIdentifier:[BBSPostCell getCellIdentifier]];
            if (cell == nil) {
                cell = [BBSPostCell createCell:self];
            }
            PBBBSPost *post = [self postInIndexPath:indexPath];
            [cell updateCellWithBBSPost:post];
            return cell;
        }
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = [super tableView:tableView numberOfRowsInSection:section];
    return number + BasicRowCount;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= BasicRowCount) {
        [[BBSManager defaultManager] setTempPostList:[self tabDataList]];
        PBBBSPost *post = [self postInIndexPath:indexPath];
        [BBSPostDetailController enterPostDetailControllerWithPost:post group:_group fromController:self animated:YES];
    }
}

#pragma mark-- Common Tab Controller delegate

- (NSInteger)tabCount
{
    return 2;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 10;
}

- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabs[] = {NewestTopic, MarkedTopic};
    return tabs[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index{
    NSArray *names = @[NSLS(@"kLatest"), NSLS(@"kMarked")];
    return names[index];
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID{
    TableTab *tab = [_tabManager tabForID:tabID];
    [self showActivityWithText:NSLS(@"kLoading")];
    switch (tabID) {
        case NewestTopic:
        {
            [topicService getBBSPostListWithBoardId:_group.groupId
                                          targetUid:nil
                                          rangeType:RangeTypeNew
                                             offset:tab.offset
                                              limit:tab.limit
                                           delegate:self];
            break;
        }
        case MarkedTopic:
        {
            [topicService getMarkedPostList:_group.groupId
                                     offset:tab.offset
                                      limit:tab.limit
                                    hanlder:^(NSInteger resultCode, NSArray *postList, NSInteger tag) {
                [self hideActivity];
                if (resultCode == 0) {
                    [self finishLoadDataForTabID:tabID resultList:postList];
                }else{
                    [self failLoadDataForTabID:tabID];
                }
            }];
            break;
        }
        default:
            break;
    }
}

- (void)didClickSupportTabButton
{
    [self clickTab:MarkedTopic];
}
- (void)didClickCommentTabButton
{
    [self clickTab:NewestTopic];
}

- (void)groupInfoView:(GroupInfoView *)infoView didClickCustomButton:(UIButton *)button
{
    //TODO enter detail controller.
    PPDebug(@"enter detail controller.");
}

- (void)didGetBBSBoard:(NSString *)boardId
              postList:(NSArray *)postList
             rangeType:(RangeType)rangeType
            resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        [self finishLoadDataForTabID:NewestTopic resultList:postList];
    }else{
        [self failLoadDataForTabID:NewestTopic];
    }
}

- (void)didController:(CreatePostController *)controller
        CreateNewPost:(PBBBSPost *)post
{
    if (post) {
        TableTab *tab = [_tabManager tabForID:NewestTopic];
        [tab.dataList insertObject:post atIndex:0];
        if ([self currentTab] == tab) {
            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:BasicRowCount inSection:0]];
            [self.dataTableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)viewDidUnload {
    [self setFooterView:nil];
    [super viewDidUnload];
}
@end
