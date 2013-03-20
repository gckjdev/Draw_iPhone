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
#import "ReplayView.h"
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
