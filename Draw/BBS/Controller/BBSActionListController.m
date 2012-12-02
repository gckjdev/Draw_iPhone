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
#import "ShowImageController.h"
#import "CreatePostController.h"
#import "BBSPostDetailController.h"
#import "BBSManager.h"

@interface BBSActionListController ()
{
    PBBBSAction *_selectedAction;
}
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@end

#define TAB_ID 100

@implementation BBSActionListController


+ (BBSActionListController *)enterActionListControllerFromController:(UIViewController *)fromController animated:(BOOL)animated
{
    BBSActionListController *ba = [[BBSActionListController alloc] init];
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
    BBSFontManager *_bbsFontManager = [BBSFontManager defaultManager];
    BBSColorManager *_bbsColorManager = [BBSColorManager defaultManager];

    [self.backButton setImage:[_bbsImageManager bbsBackImage] forState:UIControlStateNormal];
    [self.bgImageView setImage:[_bbsImageManager bbsBGImage]];
    
    
    [BBSViewManager updateLable:self.titleLabel
                        bgColor:[UIColor clearColor]
                           font:[_bbsFontManager bbsTitleFont]
                      textColor:[_bbsColorManager bbsTitleColor]
                           text:NSLS(@"kMyComment")];
    
    [self.refreshFooterView setBackgroundColor:[UIColor clearColor]];
    [self.refreshHeaderView setBackgroundColor:[UIColor clearColor]];

    
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
                         postId:(NSString *)postId
                       actionId:(NSString *)actionId
                     fromRemote:(BOOL)fromRemote
                     resultCode:(NSInteger)resultCode
{
    if (resultCode == 0) {
        ReplayGraffitiController *pg = [[ReplayGraffitiController alloc]
                                        initWithDrawActionList:drawActionList];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedAction = [self actionForIndexPath:indexPath];
    //show action sheet
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLS(@"kOption")
                                  delegate:self
                                  cancelButtonTitle:NSLS(@"kCancel")
                                  destructiveButtonTitle:NSLS(@"kReply")
                                  otherButtonTitles:NSLS(@"kPostDetail"), nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

#pragma mark - cell delegate
- (void)didClickUserAvatar:(PBBBSUser *)user
{
    //TODO show user info
    PPDebug(@"<didClickUserAvatar>, userId = %@",user.userId);
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

#pragma mark - action sheet delegate

enum{
    IndexReply = 0,
    IndexDetail = 1,
//    IndexDelete = 2,
};

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *postId = _selectedAction.source.postId;
    switch (buttonIndex) {
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
    [_backButton release];
    [_bgImageView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setBgImageView:nil];
    [super viewDidUnload];
}
@end
