//
//  BBSActionListController.m
//  Draw
//
//  Created by gamy on 12-11-23.
//
//

#import "BBSActionListController.h"
#import "UserManager.h"
#import "BBSUserActionCell.h"
#import "ReplayGraffitiController.h"
#import "CreatePostController.h"
#import "BBSPostDetailController.h"
#import "BBSManager.h"
#import "CommonUserInfoView.h"


@interface BBSActionListController ()
{
    PBBBSAction *_selectedAction;
}
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIButton *refreshButton;
@property (retain, nonatomic) NSURL *tempURL;
//- (IBAction)clickRefreshButton:(id)sender;
@end

#define TAB_ID 100

@implementation BBSActionListController


+ (BBSActionListController *)enterActionListControllerFromController:(UIViewController *)fromController animated:(BOOL)animated
{
    BBSActionListController *ba = [[[BBSActionListController alloc] init] autorelease];
    [fromController.navigationController pushViewController:ba animated:animated];
    return ba;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initViews
{
    
    BBSImageManager *_bbsImageManager = [BBSImageManager defaultManager];
    [BBSViewManager updateDefaultTitleLabel:self.titleLabel text:NSLS(@"kMyComment")];
    [BBSViewManager updateDefaultBackButton:self.backButton];
    [BBSViewManager updateDefaultTableView:self.dataTableView];

    [self.bgImageView setImage:[_bbsImageManager bbsBGImage]];
    [self.refreshFooterView setBackgroundColor:[UIColor clearColor]];
    [self.refreshHeaderView setBackgroundColor:[UIColor clearColor]];
    [self.refreshButton setImage:[_bbsImageManager bbsRefreshImage] forState:UIControlStateNormal];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViews];
    [self clickTab:TAB_ID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Common Tab Controller

- (NSInteger)tabCount
{
    return 1;
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
    return TAB_ID;
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    return NSLS(@"kComment");
}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    NSString *userID = [[UserManager defaultManager] userId];
    TableTab *tab = [_tabManager tabForID:tabID];
    [[BBSService defaultService] getBBSActionListWithTargetUid:userID
                                                        offset:tab.offset
                                                         limit:tab.limit
                                                      delegate:self];
    [self showActivityWithText:NSLS(@"kLoading")];
}

- (void)didGetActionList:(NSArray *)actionList targetUid:(NSString *)targetUid resultCode:(NSInteger)resultCode
{
    if (resultCode == 0) {
        PPDebug(@"<didGetActionList> count = %d",[actionList count]);
        [self finishLoadDataForTabID:TAB_ID resultList:actionList];
    }else{
        PPDebug(@"<didGetActionList> fail!");
        [self failLoadDataForTabID:TAB_ID];
    }
}

- (void)didGetBBSDrawActionList:(NSMutableArray *)drawActionList
                drawDataVersion:(NSInteger)version
                         postId:(NSString *)postId
                       actionId:(NSString *)actionId
                     fromRemote:(BOOL)fromRemote
                     resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        ReplayGraffitiController *pg = [[ReplayGraffitiController alloc]
                                        initWithDrawActionList:drawActionList];
        pg.drawDataVersion = version;
        [self.navigationController pushViewController:pg animated:YES];
        [pg release];
    }else{
        PPDebug(@"<didGetBBSDrawActionList> fail!, resultCode = %d",resultCode);
    }
}

- (void)didGetBBSPost:(PBBBSPost *)post postId:(NSString *)postId resultCode:(NSInteger)resultCode
{
    if (resultCode == 0) {
        [BBSPostDetailController enterPostDetailControllerWithPost:post
                                                    fromController:self
                                                          animated:YES];
    }else{
        PPDebug(@"<didGetBBSPost>fail to get post, postId = %@, resultCode = %d",postId, resultCode);
    }
}

#pragma mark - table view delegate
- (PBBBSAction *)actionForIndexPath:(NSIndexPath *)indexPath
{
    NSArray *dList = self.tabDataList;
    if (indexPath.row >= [dList count]) {
        return nil;
    }
    PBBBSAction *action = [self.tabDataList objectAtIndex:indexPath.row];
    return action;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBBBSAction *action = [self.tabDataList objectAtIndex:indexPath.row];
	return [BBSUserActionCell getCellHeightWithBBSAction:action];
}


- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [BBSUserActionCell getCellIdentifier];
	BBSUserActionCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [BBSUserActionCell createCell:self];
	}
    PBBBSAction *action = [self actionForIndexPath:indexPath];
    [cell updateCellWithBBSAction:action];
    
	return cell;
	
}

#define ACTION_SHEET_TAG 10212

- (void)showActionSheetInPoint:(CGPoint)point
{
    UIView *as = [self.view viewWithTag:ACTION_SHEET_TAG];
    if (as) {
        [as removeFromSuperview];
        return;
    }
    //show action sheet
    
    NSArray *titles = [NSArray arrayWithObjects:NSLS(@"kReply"),NSLS(@"kPostDetail"),NSLS(@"kCancel"), nil];
    BBSActionSheet *actionSheet = [[BBSActionSheet alloc] initWithTitles:titles delegate:self];
    actionSheet.tag = ACTION_SHEET_TAG;
    [actionSheet showInView:self.view showAtPoint:point animated:YES];
    [actionSheet setMaskViewColor:[UIColor lightGrayColor]];
    PPRelease(actionSheet);

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    _selectedAction = [self actionForIndexPath:indexPath];
    [self showActionSheetInPoint:self.view.center];
}

#pragma mark - cell delegate
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
    self.tempURL = url;
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
//    browser.displayActionButton = YES;
    // Modal
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:nc animated:YES];
    [nc release];
}

- (void)didClickDrawImageWithAction:(PBBBSAction *)action
{
    [[BBSService defaultService] getBBSDrawDataWithPostId:nil
                                                 actionId:action.actionId
                                                 delegate:self];
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return [MWPhoto photoWithURL:self.tempURL];
}

#pragma mark - action sheet delegate

enum{
    IndexReply = 0,
    IndexDetail = 1,
//    IndexDelete = 2,
};

- (void)optionView:(BBSOptionView *)optionView didSelectedButtonIndex:(NSInteger)index
{
    NSString *postId = _selectedAction.source.postId;
    switch (index) {
        case IndexReply:
        {
            NSString *postUid = _selectedAction.source.postUid;
            [CreatePostController enterControllerWithSourecePostId:postId
                                                           postUid:postUid
                                                          postText:nil
                                                      sourceAction:_selectedAction
                                                    fromController:self];
        }
            break;
        case IndexDetail:
        {
            [[BBSService defaultService] getBBSPostWithPostId:postId delegate:self];
        }
            break;
        default:
            break;
    }
}


- (void)dealloc {
    PPRelease(_tempURL);
    PPRelease(_backButton);
    PPRelease(_bgImageView);
    PPRelease(_refreshButton);
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setBgImageView:nil];
    [self setRefreshButton:nil];
    [super viewDidUnload];
}
//- (IBAction)clickRefreshButton:(id)sender {
//}
@end
