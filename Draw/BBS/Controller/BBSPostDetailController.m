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
#import "ReplayGraffitiController.h"
#import "ShowImageController.h"
#import "GameNetworkConstants.h"
#import "CommonUserInfoView.h"


@interface BBSPostDetailController ()
{
    BBSImageManager *_bbsImageManager;
    BBSColorManager *_bbsColorManager;
    BBSFontManager *_bbsFontManager;
    
    BBSPostActionHeaderView *_header;
    PBBBSAction *_selectedAction;
}

@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIImageView *toolBarBG;
@property (retain, nonatomic) IBOutlet UIButton *supportButton;
@property (retain, nonatomic) IBOutlet UIButton *commentButton;
@property (retain, nonatomic) IBOutlet UIButton *refreshButton;

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
    [fromController.navigationController pushViewController:pd animated:animated];
    return [pd autorelease];
}



- (void)dealloc
{
    PPRelease(_post);
    PPRelease(_backButton);
    PPRelease(_bgImageView);
    PPRelease(_toolBarBG);
    PPRelease(_supportButton);
    PPRelease(_commentButton);
    PPRelease(_header);
    [_refreshButton release];
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

- (void)initViews
{
    
    [self.bgImageView setImage:[_bbsImageManager bbsBGImage]];
    [self.refreshButton setImage:[_bbsImageManager bbsRefreshImage] forState:UIControlStateNormal];


    [BBSViewManager updateDefaultTitleLabel:self.titleLabel text:NSLS(@"kPostDetail")];
    [BBSViewManager updateDefaultBackButton:self.backButton];
    
    [self.refreshFooterView setBackgroundColor:[UIColor clearColor]];
    [self.toolBarBG setImage:[_bbsImageManager bbsDetailToolbar]];
    [BBSViewManager updateButton:self.supportButton
                         bgColor:[UIColor clearColor]
                         bgImage:[_bbsImageManager bbsDetailSupport]
                           image:nil
                            font:[_bbsFontManager detailActionFont]
                      titleColor:[_bbsColorManager detailDefaultColor]
                           title:NSLS(@"kBBSSupport")
                        forState:UIControlStateNormal];
    
    [BBSViewManager updateButton:self.commentButton
                         bgColor:[UIColor clearColor]
                         bgImage:[_bbsImageManager bbsDetailComment]
                           image:nil
                            font:[_bbsFontManager detailActionFont]
                      titleColor:[_bbsColorManager detailDefaultColor]
                           title:NSLS(@"kBBSReply")
                        forState:UIControlStateNormal];


}

- (NSInteger)defaultTabID
{
    return _defaultTabIndex + Support;
}


- (void)viewDidLoad
{
    [self setPullRefreshType:PullRefreshTypeFooter];
    [super viewDidLoad];
    [self initViews];
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
    
    [[BBSService defaultService] getBBSActionListWithPostId:self.post.postId
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
            return  [BBSPostDetailCell getCellHeightWithBBSPost:self.post];
        }
        case SectionActionList:
        {
            PBBBSAction *action = [self.tabDataList objectAtIndex:indexPath.row];
            return [BBSPostActionCell getCellHeightWithBBSAction:action];
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
            return _header;
        }
        default:
            break;
    }
    return nil;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBBBSAction *action = [self actionForIndexPath:indexPath];
    if (action && action.canDelete) {
        return YES;
    }
    return NO;
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
    if (action && action.canDelete) {
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
- (void)didGetBBSDrawActionList:(NSMutableArray *)drawActionList
                         postId:(NSString *)postId
                       actionId:(NSString *)actionId
                     fromRemote:(BOOL)fromRemote
                     resultCode:(NSInteger)resultCode
{
    PPDebug(@"<didGetBBSDrawActionList> resultCode = %d, list count = %d",resultCode, [drawActionList count]);
    [self hideActivity];
    if (resultCode == 0) {
        ReplayGraffitiController *pg = [[ReplayGraffitiController alloc]
                                        initWithDrawActionList:drawActionList];
        [self.navigationController pushViewController:pg animated:YES];
        [pg release];
    }else{
        PPDebug(@"<didGetBBSDrawActionList> fail!, resultCode = %d",resultCode);
    }
}
- (IBAction)clickSupportButton:(id)sender {
    [[BBSService defaultService] createActionWithPostId:self.post.postId
                                                PostUid:self.post.postUid
                                               postText:self.post.postText
                                           sourceAction:nil
                                             actionType:ActionTypeSupport
                                                   text:nil
                                                  image:nil
                                         drawActionList:nil
                                              drawImage:nil
                                               delegate:self];
}

- (IBAction)clickReplyButton:(id)sender {
    [CreatePostController enterControllerWithSourecePost:self.post
                                            sourceAction:nil
                                          fromController:self].delegate = self;
}

- (void)didDeleteBBSAction:(NSString *)actionId resultCode:(NSInteger)resultCode
{
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

- (void)didClickUserAvatar:(PBBBSUser *)user
{
    //TODO show user info
    PPDebug(@"<didClickUserAvatar>, userId = %@",user.userId);
    [CommonUserInfoView showPBBBSUser:user
                         inController:self
                           needUpdate:YES
                              canChat:YES];
}

- (void)didClickImageWithURL:(NSURL *)url
{
    [ShowImageController enterControllerWithImageURL:url fromController:self animated:YES];
}

- (void)didClickDrawImageWithAction:(PBBBSAction *)action
{
    [[BBSService defaultService] getBBSDrawDataWithPostId:nil
                                                 actionId:action.actionId
                                                 delegate:self];
}

- (void)didClickDrawImageWithPost:(PBBBSPost *)post
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [[BBSService defaultService] getBBSDrawDataWithPostId:post.postId
                                                 actionId:nil
                                                 delegate:self];    
}

- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setTitleLabel:nil];
    [self setBgImageView:nil];
    [self setToolBarBG:nil];
    [self setSupportButton:nil];
    [self setCommentButton:nil];
    [self setRefreshButton:nil];
    [super viewDidUnload];
}
@end
