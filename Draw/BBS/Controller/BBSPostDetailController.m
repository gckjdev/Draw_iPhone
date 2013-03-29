//
//  BBSPostDetailController.m
//  Draw
//
//  Created by gamy on 12-11-17.
//
//

#import "BBSPostDetailController.h"
#import "BBSPostActionCell.h"
#import "BBSPostDetailCell.h"
#import "ReplayView.h"
#import "GameNetworkConstants.h"
#import "CommonUserInfoView.h"
#import "BBSPostCommand.h"
#import "BBSPostCommandPanel.h"
#import "BBSPermissionManager.h"

@interface BBSPostDetailController ()
{
    BBSImageManager *_bbsImageManager;
    BBSColorManager *_bbsColorManager;
    BBSFontManager *_bbsFontManager;
    BBSPostActionHeaderView *_header;
    PBBBSAction *_selectedAction;
    
    UITextView *_helpTextView;
    
}

@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIImageView *toolBarBG;
@property (retain, nonatomic) IBOutlet UIButton *refreshButton;

@property (retain, nonatomic) NSString *postID;

@end

typedef enum{
    SectionDetail = 0,
    SectionAction = 1,
    SectionActionList = 2,
    SectionCount,
}Section;

//typedef enum {
//    DetailRowUser = -1,
//    DetailRowContent = 0,
//    DetailRowCount,
//}DetailRow;

typedef enum{
    Support = 100,
    Comment = 101,
}TabID;

@implementation BBSPostDetailController
@synthesize post = _post;

+ (BBSPostDetailController *)enterPostDetailControllerWithPost:(PBBBSPost *)post
                                                fromController:(UIViewController *)fromController
                                                      animated:(BOOL)animated
{
    BBSPostDetailController *pd = [[BBSPostDetailController alloc] init];
    pd.post = post;
    pd.postID = post.postId;
    [fromController.navigationController pushViewController:pd animated:animated];
    return [pd autorelease];
}


+ (BBSPostDetailController *)enterPostDetailControllerWithPostID:(NSString *)postID
                                                  fromController:(UIViewController *)fromController
                                                        animated:(BOOL)animated
{
    BBSPostDetailController *pd = [[BBSPostDetailController alloc] init];
    pd.postID = postID;
    [fromController.navigationController pushViewController:pd animated:animated];
    return [pd autorelease];
}



- (void)dealloc
{
    PPRelease(_post);
    PPRelease(_backButton);
    PPRelease(_bgImageView);
    PPRelease(_toolBarBG);
    PPRelease(_header);
    PPRelease(_refreshButton);
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _defaultTabIndex = 1;
        
        _bbsImageManager = [BBSImageManager defaultManager];
        _bbsFontManager = [BBSFontManager defaultManager];
        _bbsColorManager = [BBSColorManager defaultManager];
    }
    return self;
}

- (NSArray *)commandList
{
    NSMutableArray *list = [NSMutableArray array];
    BBSPermissionManager *pm = [BBSPermissionManager defaultManager];
    PBBBSPost *post = self.post;
    if ([pm canWriteOnBBBoard:post.boardId]) {
        BBSPostReplyCommand *rc = [[[BBSPostReplyCommand alloc] initWithPost:post controller:self] autorelease];
        [list addObject:rc];
        BBSPostSupportCommand *sc = [[[BBSPostSupportCommand alloc] initWithPost:post controller:self] autorelease];
        [list addObject:sc];
    }
    if ([pm canDeletePost:post onBBBoard:post.boardId]) {
        BBSPostDeleteCommand *dc = [[[BBSPostDeleteCommand alloc] initWithPost:post controller:self] autorelease];
        [list addObject:dc];
    }
    if ([pm canTransferPost:post fromBBBoard:post.boardId]) {
        BBSPostTransferCommand *tc = [[[BBSPostTransferCommand alloc] initWithPost:post controller:self] autorelease];
        [list addObject:tc];
    }
    if ([pm canTopPost:post onBBBoard:post.boardId]) {
        BBSPostTopCommand *tc = [[[BBSPostTopCommand alloc] initWithPost:post controller:self] autorelease];
        [list addObject:tc];
    }
    return list;
}

#define PANEL_TAG 20130124
- (void)updateFooterView
{
    UIView *view = [self.toolBarBG viewWithTag:PANEL_TAG];
    [view removeFromSuperview];
    BBSPostCommandPanel *panel = [BBSPostCommandPanel panelWithCommandList:[self commandList]];
    panel.tag = PANEL_TAG;
    panel.frame = self.toolBarBG.bounds;
    [self.toolBarBG setUserInteractionEnabled:YES];
    [self.toolBarBG addSubview:panel];
}

- (void)initViews
{
    
    [self.bgImageView setImage:[_bbsImageManager bbsBGImage]];
    [self.refreshButton setImage:[_bbsImageManager bbsRefreshImage] forState:UIControlStateNormal];


    [BBSViewManager updateDefaultTitleLabel:self.titleLabel text:NSLS(@"kPostDetail")];
    [BBSViewManager updateDefaultBackButton:self.backButton];
    
    [self.refreshFooterView setBackgroundColor:[UIColor clearColor]];
    [self.toolBarBG setImage:[_bbsImageManager bbsDetailToolbar]];

    [self updateFooterView];
    
    _helpTextView = [[[UITextView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)] autorelease];
    UIFont * font = [[BBSFontManager defaultManager] postContentFont];
    [_helpTextView setFont:font];
    _helpTextView.hidden = YES;
    [self.view addSubview:_helpTextView];
    
}

- (NSInteger)defaultTabID
{
    return _defaultTabIndex + Support;
}


- (void)loadPost
{
    if (self.post == nil) {
        [self showActivityWithText:NSLS(@"kLoading")];
        [[BBSService defaultService] getBBSPostWithPostId:self.postID delegate:self];
    }
}

- (void)didGetBBSPost:(PBBBSPost *)post postId:(NSString *)postId resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        self.post = post;
        [self.dataTableView reloadData];
    }
}

- (void)viewDidLoad
{
    [self setPullRefreshType:PullRefreshTypeFooter];
    [super viewDidLoad];
    [self initViews];
    [self loadPost];
//    if ([self defaultTabID] == Support) {
//        [_header clickSupport:_header.support];
//    }else{
//        [_header clickComment:_header.comment];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Tab controller delegate
- (NSInteger)tabCount
{
    return 2;
}
- (NSInteger)currentTabIndex
{
    return _defaultTabIndex;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 20;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabIDs[] = {Comment, Support};
    return tabIDs[index];
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *titles[] = {NSLS(@"kSupport"),NSLS(@"kComment")};
    return titles[index];
}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    BBSActionType type = ActionTypeNO;
    if (tabID == Support) {
        type = ActionTypeSupport;
    }else if(tabID == Comment){
        type = ActionTypeComment;
    }
    
    TableTab *tab = [_tabManager tabForID:tabID];
    
    [[BBSService defaultService] getBBSActionListWithPostId:self.postID
                                                 actionType:type
                                                     offset:tab.offset
                                                      limit:tab.limit
                                                   delegate:self];
    [self showActivityWithText:NSLS(@"kLoading")];
}


#pragma mark - bbs service delegate

- (void)didGetActionList:(NSArray *)actionList
               belowPost:(NSString *)postId
              actionType:(BBSActionType)actionType
              resultCode:(NSInteger)resultCode
{
    NSInteger tabID = (actionType == ActionTypeSupport) ? Support : Comment;
    
    if (resultCode == 0) {
        PPDebug(@"<didGetActionList> action list count = %d", actionList.count);
        [self finishLoadDataForTabID:tabID resultList:actionList];
    }else{
        PPDebug(@"<didGetActionList> fail to get action list");
        [self failLoadDataForTabID:tabID];
    }
}


#pragma mark - table view delegate
- (PBBBSAction *)actionForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != SectionActionList) {
        return nil;
    }
    NSArray *dList = self.tabDataList;
    if (indexPath.row >= [dList count]) {
        return nil;
    }
    PBBBSAction *action = [self.tabDataList objectAtIndex:indexPath.row];
    return action;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SectionActionList:
            return [super tableView:tableView numberOfRowsInSection:section];
            
        case SectionAction:
        case SectionDetail:
            return 1;
        default:
            return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SectionDetail:
        {
            return  [BBSPostDetailCell getCellHeightWithBBSPost:self.post inTextView:_helpTextView];
        }
        case SectionActionList:
        {
            PBBBSAction *action = [self.tabDataList objectAtIndex:indexPath.row];
            return [BBSPostActionCell getCellHeightWithBBSAction:action inTextView:_helpTextView];
        }
        case SectionAction:
            return [BBSPostActionHeaderView getViewHeight];
        default:
            break;
    }
    return 44;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == SectionAction) {
//        return [BBSPostActionHeaderView getViewHeight];
//    }
//    return 0;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (section == SectionAction) {
//        if (_header == nil) {
//            _header = [[BBSPostActionHeaderView createView:self] retain];
//        }
//        [_header updateViewWithPost:self.post];
//        return _header;
//    }
//    return nil;
//}

- (id)getTableViewCell:(UITableView *)tableView
        cellIdentifier:(NSString *)cellIdentifier
                 cellClass:(Class )classClass
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [classClass createCell:self];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionDetail:
            {
                NSString *CellIdentifier = [BBSPostDetailCell getCellIdentifier];
                BBSPostDetailCell *cell = [self getTableViewCell:theTableView cellIdentifier:CellIdentifier cellClass:[BBSPostDetailCell class]];
                [cell updateCellWithBBSPost:self.post];
                cell.delegate = self;
                return cell;
            }
        case SectionActionList:
            {
                NSString *CellIdentifier = [BBSPostActionCell getCellIdentifier];
                BBSPostActionCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [BBSPostActionCell createCell:self];
                }
                PBBBSAction *action = [self actionForIndexPath:indexPath];
                [cell updateCellWithBBSAction:action post:self.post];
                if ([self.post canPay] && action == _selectedAction && ![action isMyAction]) {
                    [cell showOption:YES];
                }else{
                    [cell showOption:NO];
                }
                return cell;
            }
        case SectionAction:
        {
            if (_header == nil) {
                _header = [[BBSPostActionHeaderView createView:self] retain];
                [_header updateViewWithPost:self.post];
                if([self defaultTabID] == Support){
                    [_header clickSupport:_header.support];
                }else{
                    [_header clickComment:_header.comment];
                }
            }
            [_header updateViewWithPost:self.post];
            return _header;
        }
        default:
            break;
    }
    return nil;
}


- (BOOL)actionCanDelete:(PBBBSAction *)action
{
    return  action && (action.canDelete || [[BBSPermissionManager defaultManager] canDeletePost:self.post onBBBoard:self.post.boardId]);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBBBSAction *action = [self actionForIndexPath:indexPath];
    return [self actionCanDelete:action];
//    if (action && (action.canDelete || [[BBSPermissionManager defaultManager] canDeletePost:self.post onBBBoard:self.post.boardId])) {
//        return YES;
//    }
//    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLS(@"kDelete");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBBBSAction *action = [self actionForIndexPath:indexPath];
    if ([self actionCanDelete:action]) {
        [self showActivityWithText:NSLS(@"kDeleting")];
        [[BBSService defaultService] deleteActionWithActionId:action.actionId delegate:self];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SectionActionList && [self.post canPay]) {
        PBBBSAction *action = [self actionForIndexPath:indexPath];
        if (action != _selectedAction && action.type == ActionTypeComment) {
            _selectedAction = action;
        }else{
            _selectedAction = nil;
        }
//        [tableView reloadData];
        [tableView reloadRowsAtIndexPaths:[tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - bbs post action cell delegate
- (void)didClickReplyButtonWithAction:(PBBBSAction *)action
{
    [CreatePostController enterControllerWithSourecePost:self.post
                                            sourceAction:action
                                          fromController:self].delegate = self;
    _selectedAction = nil;
}
- (void)didClickPayButtonWithAction:(PBBBSAction *)action
{
    PPDebug(@"<didClickPayButtonWithAction>");
    _selectedAction = nil;
    [[BBSService defaultService] payRewardWithPost:self.post
                                            action:action
                                          delegate:self];
}

#pragma mark - CreatePostController delegate
- (void)didController:(CreatePostController *)controller
      CreateNewAction:(PBBBSAction *)action
{
    if (action) {
        TableTab *tab = nil;
        if (action.type == ActionTypeSupport) {
            tab = [_tabManager tabForID:Support];
            [tab.dataList insertObject:action atIndex:0];
            
            self.post = [[BBSManager defaultManager] inceasePost:self.post
                                                    supportCount:1];
            
            [_header clickSupport:_header.support];
        }else if(action.type == ActionTypeComment){
            tab = [_tabManager tabForID:Comment];
            [tab.dataList insertObject:action atIndex:0];
            
            self.post = [[BBSManager defaultManager] inceasePost:self.post
                                                    commentCount:1];
            
            [_header clickComment:_header.comment];
        }
    }
}

#pragma mark - BBSService delegate
- (void)didCreateAction:(PBBBSAction *)action
                 atPost:(NSString *)postId
            replyAction:(PBBBSAction *)replyAction
             resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        [self didController:nil CreateNewAction:action];
    }else{
        PPDebug(@"<didCreatePost>create post fail.result code = %d",resultCode);
        NSString *msg = nil;
        switch (resultCode) {
            case ERROR_BBS_TEXT_TOO_SHORT:
                msg = [NSString stringWithFormat:NSLS(@"kTextTooShot"),
                       [[BBSManager defaultManager] textMinLength]];
                break;
            case ERROR_BBS_TEXT_TOO_LONG:
                msg = [NSString stringWithFormat:NSLS(@"kTextTooLong"),
                       [[BBSManager defaultManager] textMaxLength]];
                break;
            case ERROR_BBS_TEXT_TOO_FREQUENT:
                msg = [NSString stringWithFormat:NSLS(@"kTextTooFrequent"),
                       [[BBSManager defaultManager] creationFrequency]];
                break;
            case ERROR_BBS_POST_SUPPORT_TIMES_LIMIT:
                msg = [NSString stringWithFormat:NSLS(@"kSupportTimesLimit"),
                       [[BBSManager defaultManager] supportMaxTimes]];
                break;
            default:
                msg = NSLS(@"kNetworkError");
                break;
        }
        [UIUtils alert:msg];
    }

}

- (void)didPayBBSRewardWithPost:(PBBBSPost *)post
                         action:(PBBBSAction *)action
                     resultCode:(NSInteger)resultCode
{
    if (resultCode == 0) {
        [post setPay:YES];
        [self.dataTableView reloadData];
    }else{
        PPDebug(@"<didPayBBSRewardWithPost>fail to pay, postId = %@, actionId = %@",post.postId, action.actionId);
    }
}


- (void)didEditPostPost:(PBBBSPost *)post resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode != 0) {
        [self popupUnhappyMessage:NSLS(@"kEditPostFailed") title:nil];
    }else{
        [self popupHappyMessage:NSLS(@"kEditPostSucced") title:nil];
        if ([[BBSManager defaultManager] replacePost:self.post withPost:post]) {
            self.post = post;
            [self.dataTableView reloadData];
            [self updateFooterView];
        }
    }
}

- (void)didDeleteBBSPost:(PBBBSPost *)post resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode != 0) {
        [self popupUnhappyMessage:NSLS(@"kDeletePostFailed") title:nil];
    }else{
        [self popupUnhappyMessage:NSLS(@"kDeletePostSucceed") title:nil];
        [[[BBSManager defaultManager] tempPostList] removeObject:post];
        [self.navigationController popViewControllerAnimated:YES];

    }
}


- (void)didDeleteBBSAction:(NSString *)actionId resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        PBBBSAction *act = nil;
        NSInteger row = 0;
        for (PBBBSAction *action in self.tabDataList) {
            if ([action.actionId isEqualToString:actionId]) {
                act = action;
                break;
            }
            row ++;
        }
        if (act) {
            [self.tabDataList removeObject:act];
            if (act.type == ActionTypeComment) {
                self.post = [[BBSManager defaultManager] inceasePost:self.post commentCount:-1];
            }else if(act.type == ActionTypeSupport){
                self.post = [[BBSManager defaultManager] inceasePost:self.post supportCount:-1];
            }
            [self.dataTableView reloadData];
        }
    }else{
        PPDebug(@"<didDeleteBBSAction>fail to delete action, actionId = %@, resultCode = %d",actionId, resultCode);
    }
}

#pragma mark - action header view
- (void)didClickSupportTabButton
{
    [self clickTab:Support];
}
- (void)didClickCommentTabButton
{
    [self clickTab:Comment];
}


- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setTitleLabel:nil];
    [self setBgImageView:nil];
    [self setToolBarBG:nil];
    [self setRefreshButton:nil];
    PPRelease(_header);
    [super viewDidUnload];
}
@end
