//
//  GroupNoticeController.m
//  Draw
//
//  Created by Gamy on 13-11-26.
//
//

#import "GroupNoticeController.h"
#import "GroupService.h"
#import "GroupNoticeCell.h"
#import "BBSUserActionCell.h"
#import "BBSActionSheet.h"
#import "CreatePostController.h"
#import "BBSPostDetailController.h"

typedef enum{
    GroupComment = 100,
    GroupRequest = 101,
    GroupNotice = 102
}TabID;

@interface GroupNoticeController ()
{
    PBGroupNotice *_selectedNotice;
    PBBBSAction *_selectedAction;
}
@end

@implementation GroupNoticeController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.forGroup = YES;
    }
    return self;
}

- (void)updateBadge
{
//     [self tabButtonWithTabID:GroupComment];
    GroupManager *gm = [GroupManager defaultManager];
    [self setBadge:gm.commentBadge onTab:GroupComment];
    [self setBadge:gm.noticeBadge onTab:GroupNotice];
    [self setBadge:gm.requestBadge onTab:GroupRequest];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.titleView setTitle:NSLS(@"kAtMe")];
    [self.titleView setTransparentStyle];
    [self initTabButtons];
    [self updateBadge];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id data = self.tabDataList[indexPath.row];
    
    if (self.currentTab.tabID == GroupComment) {
        return [BBSUserActionCell getCellHeightWithBBSAction:data];
    }else{
        return [GroupNoticeCell getCellHeightByNotice:data];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class cellClass = nil;

    if (self.currentTab.tabID == GroupComment) {
        cellClass = [BBSUserActionCell class];
    }else{
        cellClass = [GroupNoticeCell class];
    }
    NSString *identifier = [cellClass getCellIdentifier];
    id cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [cellClass createCell:self];
    }
    id data = self.tabDataList[indexPath.row];
    [cell setCellInfo:data];
    return cell;
}


typedef enum{
    NOTICE_OPTION_ACCEPT = 0,
    NOTICE_OPTION_REJECT = 1,
    NOTICE_OPTION_IGNORE = 2,
    NOTICE_OPTION_CANCEL = 3,

    COMMENT_OPTION_REPLY = 0,
    COMMENT_OPTION_DETAIL = 1,
    COMMENT_OPTION_CANCEL = 2,

}OptionIndex;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TabID tabId = [self currentTabID];
    PPDebug(@"did select at row = %d", indexPath.row);
    if (tabId == GroupRequest) {
        _selectedNotice = [self tabDataList][indexPath.row];
        NSArray *titles = @[NSLS(@"kAccept"),NSLS(@"kDecline"),NSLS(@"kIgnore"),NSLS(@"kCancel")];
        
        BBSActionSheet *sheet = [[BBSActionSheet alloc] initWithTitles:titles delegate:self];
        [sheet showInView:self.view
              showAtPoint:self.view.center
                 animated:YES];
        [sheet release];
    }else if(tabId == GroupComment){
        _selectedAction = [self tabDataList][indexPath.row];
        NSArray *titles = [NSArray arrayWithObjects:NSLS(@"kReply"),NSLS(@"kPostDetail"),NSLS(@"kCancel"), nil];
        BBSActionSheet *actionSheet = [[BBSActionSheet alloc] initWithTitles:titles delegate:self];
        [actionSheet showInView:self.view showAtPoint:self.view.center animated:YES];
    }
}

- (void)removeNoticeFromTable:(PBGroupNotice *)notice
{
    if(notice == nil){
        PPDebug(@"<removeNoticeFromTable> but notice is null");
        return;
    }
    
    NSInteger row = [self.tabDataList indexOfObject:notice];
    if (row == NSNotFound) {
        PPDebug(@"tab is changed.");
        return;
    }
    [self.tabDataList removeObject:notice];

    PPDebug(@"<removeNoticeFromTable> notice id = %@, row = %d", notice.noticeId, row);
    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
    [self.dataTableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (void)ignoreNotice:(PBGroupNotice *)notice
{
    [self showActivityWithText:NSLS(@"kIgnoring")];
    [[GroupService defaultService] ignoreNotice:notice.noticeId noticeType:notice.type callback:^(NSError *error) {
        [self hideActivity];
        if (!error) {
            [self removeNoticeFromTable:notice];
        }
    }];
}

- (void)handleRequestNotice:(PBGroupNotice *)notice accept:(BOOL)accpet
{
    if (notice == nil) {
        PPDebug(@"<handleRequestNotice> error!! notice is nil");
        return;
    }
    NSString *showTitle = (accpet ? NSLS(@"kAccepting") : NSLS(@"kRejecting"));    
    [self showActivityWithText:showTitle];
    [[GroupService defaultService] handleUserRequestNotice:notice accept:accpet reason:nil callback:^(NSError *error) {
        [self hideActivity];
        if (!error) {
            [self removeNoticeFromTable:notice];
        }
    }];
}

- (void)optionView:(BBSOptionView *)optionView didSelectedButtonIndex:(NSInteger)index
{
    TabID tabId = [self currentTabID];
    if (tabId == GroupRequest) {
        if (index == NOTICE_OPTION_ACCEPT || index == NOTICE_OPTION_REJECT) {
            BOOL accept = (index == NOTICE_OPTION_ACCEPT);
            [self handleRequestNotice:_selectedNotice accept:accept];
        }else if (index == NOTICE_OPTION_IGNORE) {
            [self ignoreNotice:_selectedNotice];
        }else{
            //do nothing
        }
        _selectedNotice = nil;

    }else if(tabId == GroupComment){
        
        switch (index) {
            case COMMENT_OPTION_REPLY:
            {                
                NSString *postId = _selectedAction.source.postId;
                NSString *postUid = _selectedAction.source.postUid;
                CreatePostController*cpc = [CreatePostController
                                            enterControllerWithSourecePostId:postId
                                                                     postUid:postUid
                                                                    postText:nil
                                                                sourceAction:_selectedAction
                                                              fromController:self];
                cpc.forGroup = YES;
                break;
            }
            case COMMENT_OPTION_DETAIL:
            {
                [self showActivityWithText:NSLS(@"kLoading")];
                NSString *postId = _selectedAction.source.postId;
                [[self bbsService] getBBSPostWithPostId:postId delegate:self];
            }
                break;
            default:
                break;
        }
        
        _selectedAction = nil;
    }
}

- (void)didGetBBSPost:(PBBBSPost *)post
               postId:(NSString *)postId
           resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        //TODO get the correct group
        PBGroup *group = [[GroupManager defaultManager] findGroupById:post.boardId];
        [BBSPostDetailController enterPostDetailControllerWithPost:post group:group fromController:self animated:YES];
    }else{
        
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.currentTabID == GroupNotice;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLS(@"kIgnore");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBGroupNotice *notice = self.tabDataList[indexPath.row];
    [self ignoreNotice:notice];
}



- (NSInteger)tabCount
{
    return 3;
}
- (NSInteger)currentTabIndex
{
    return 0;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 15;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabIDs[] = {GroupComment,GroupRequest,GroupNotice};
    return tabIDs[index];
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSArray *titles = @[NSLS(@"kGroupComment"),NSLS(@"kGroupRequest"),NSLS(@"kGroupNotice")];
    return titles[index];
}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    TableTab *tab = [_tabManager tabForID:tabID];
    [self showActivityWithText:NSLS(@"kLoading")];
    switch (tabID) {
        case GroupComment:
        {
            NSString *userID = [[UserManager defaultManager] userId];
            [[self bbsService] getBBSActionListWithTargetUid:userID
                                                      offset:tab.offset
                                                       limit:tab.limit
                                                    delegate:self];
            break;
        }
        case GroupRequest:
        case GroupNotice:
        {
            GroupNoticeType type = ((tabID == GroupRequest) ? GroupNoticeTypeRequest :GroupNoticeTypeNotice);
            
            [[GroupService defaultService] getGroupNoticeByType:type
                                                         offset:tab.offset
                                                          limit:tab.limit
                                                       callback:^(NSArray *list, NSError *error) {
               [self hideActivity];
               if (error) {
                   [self failLoadDataForTabID:tabID];
               }else{
                   if (tab.offset == 0) {
                       [self setBadge:0 onTab:tabID];
                       if (tabID == GroupRequest) {
                           [[GroupManager defaultManager] setRequestBadge:0];
                       }else{
                           [[GroupManager defaultManager] setNoticeBadge:0];
                       }
                   }
                   [self finishLoadDataForTabID:tabID resultList:list];
               }
            }];
            break;
        }
        default:
            [self hideActivity];
            break;
    }
}

- (void)didGetActionList:(NSArray *)actionList
               targetUid:(NSString *)targetUid
              resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        PPDebug(@"<didGetActionList> count = %d",[actionList count]);
        [self setBadge:0 onTab:GroupComment];
        [[GroupManager defaultManager] setCommentBadge:0];
        [self finishLoadDataForTabID:GroupComment resultList:actionList];
    }else{
        PPDebug(@"<didGetActionList> fail!");
        [self failLoadDataForTabID:GroupComment];
    }
}


@end