//
//  BBSPostListController.m
//  Draw
//
//  Created by gamy on 12-11-17.
//
//

#import "BBSPostListController.h"
#import "BBSModelExt.h"
#import "CreatePostController.h"
#import "BBSPostCell.h"
#import "BBSPostDetailController.h"
#import "ReplayView.h"
#import "CommonUserInfoView.h"
#import "BoardAdminListView.h"

#define ADMINLISTVIEW_ORIGIN (ISIPAD ? CGPointMake(0,110) : CGPointMake(0,49))

@interface BBSPostListController ()
{
    RangeType _rangeType;
    BBSImageManager *_bbsImageManager;
    BBSColorManager *_bbsColorManager;
    BBSFontManager *_bbsFontManager;
    BBSManager *_bbsManager;
}
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIView *holderView;
@property (retain, nonatomic) NSURL *tempURL;
- (void)updateTempPostListWithTabID:(NSInteger)tabID;
@end

@implementation BBSPostListController


+ (BBSPostListController *)enterPostListControllerWithBBSBoard:(PBBBSBoard *)board
                                                fromController:(UIViewController *)fromController
{
    BBSPostListController *pl = [[BBSPostListController alloc] init];
    [pl setBbsBoard:board];
    [fromController.navigationController pushViewController:pl animated:YES];
    [pl release];
    return pl;
}

+ (BBSPostListController *)enterPostListControllerWithBBSUser:(PBBBSUser *)bbsUser
                                               fromController:(UIViewController *)fromController
{
    BBSPostListController *pl = [[BBSPostListController alloc] init];
    [pl setBbsUser:bbsUser];
    [fromController.navigationController pushViewController:pl animated:YES];
    [pl release];
    return pl;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _rangeType = RangeTypeNew;
        _bbsImageManager = [BBSImageManager defaultManager];
        _bbsFontManager = [BBSFontManager defaultManager];
        _bbsColorManager = [BBSColorManager defaultManager];
        _bbsManager = [BBSManager defaultManager];
    }
    return self;
}

- (BOOL)showBoardAdminList
{
//    return NO;
    return self.bbsBoard != nil;
}

- (void)updateTableViewFrame
{
    if ([self showBoardAdminList]) {
        [self.dataTableView setFrame:self.holderView.frame];
        [self.holderView setBackgroundColor:[UIColor clearColor]];
    }else{
        [self.holderView removeFromSuperview];
    }
}

- (void)showAdminListView
{
    BoardAdminListView *adminListView = [BoardAdminListView adminListViewWithBBSUserList:self.bbsBoard.adminListList controller:self];
    CGRect frame = [adminListView frame];
    frame.origin = ADMINLISTVIEW_ORIGIN;
    adminListView.frame = frame;
    [self.view addSubview:adminListView];
    
}
//#define POST_LIST_TAB 100

- (NSInteger)rangeTypeToTabID:(RangeType)rangeType
{
    return rangeType * 100;
}

- (NSInteger)tabIDToRangeType:(NSInteger)tabID
{
    return tabID / 100;
}
- (void)initViews
{
    [self.bgImageView setImage:[_bbsImageManager bbsBGImage]];
    
    NSString *titleName = nil;
    
    if (self.bbsBoard) {
        titleName = self.bbsBoard.name;
        [self.createPostButton setImage:[_bbsImageManager bbsPostEditImage]
                               forState:UIControlStateNormal];
        [self.rankButton setImage:[_bbsImageManager bbsPostNewImage]
                         forState:UIControlStateNormal];

        [self.rankButton setImage:[_bbsImageManager bbsPostHotImage]
                               forState:UIControlStateSelected];

    }else if(self.bbsUser){
        if ([self.bbsUser isMe]) {
            titleName = NSLS(@"kMyPost");
        }else{
            titleName = self.bbsUser.nickName;
        }
        self.createPostButton.hidden = YES;
        self.rankButton.hidden = YES;
    }
    
    [BBSViewManager updateDefaultTitleLabel:self.titleLabel text:titleName];
    [BBSViewManager updateDefaultBackButton:self.backButton];
//    [BBSViewManager updateDefaultTableView:self.dataTableView];
    
    [self.refreshFooterView setBackgroundColor:[UIColor clearColor]];
    [self.refreshHeaderView setBackgroundColor:[UIColor clearColor]];
    
    [self updateTableViewFrame];
    if ([self showBoardAdminList]) {
        [self showAdminListView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViews];
    [self clickTab:[self rangeTypeToTabID:_rangeType]];
    // Do any additional setup after loading the view from its nib.
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.dataTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_bbsManager setTempPostList:nil];
    PPRelease(_backButton);
    PPRelease(_createPostButton);
    PPRelease(_rankButton);
    PPRelease(_bgImageView);
    PPRelease(_tempURL);
    [_holderView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setCreatePostButton:nil];
    [self setRankButton:nil];
    [self setBgImageView:nil];
    [_bbsManager setTempPostList:nil];
    [self setHolderView:nil];
    [super viewDidUnload];
}
- (IBAction)clickCreatePostButton:(id)sender {
    if (self.bbsBoard) {
        [CreatePostController enterControllerWithBoard:self.bbsBoard fromController:self].delegate = self;
    }else{
        PPDebug(@"<clickCreatePostButton>: board is nil");
    }
}



- (IBAction)clickRankButton:(id)sender {
    if (RangeTypeHot == _rangeType) {
        _rangeType = RangeTypeNew;
        self.rankButton.selected = NO;
    }else{
        _rangeType = RangeTypeHot;
        self.rankButton.selected = YES;
    }
    NSInteger tabID = [self rangeTypeToTabID:_rangeType];
    self.rankButton.tag = tabID;
    [self clickTab:tabID];
    [self updateTempPostListWithTabID:tabID];
}



#pragma mark - common tab controller delegate


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
    return 10;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    return [self rangeTypeToTabID:index];
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    return nil;
}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    NSInteger rangeType = [self tabIDToRangeType:tabID];
    TableTab *tab = [_tabManager tabForID:tabID];
    [[BBSService defaultService] getBBSPostListWithBoardId:_bbsBoard.boardId
                                                 targetUid:_bbsUser.userId
                                                 rangeType:rangeType
                                                    offset:tab.offset
                                                     limit:tab.limit
                                                  delegate:self];
    [self showActivityWithText:NSLS(@"kLoading")];
}

#pragma mark - bbs service delegate
- (void)didGetBBSBoard:(NSString *)boardId
              postList:(NSArray *)postList
             rangeType:(RangeType)rangeType
            resultCode:(NSInteger)resultCode
{
    NSInteger tabID = [self rangeTypeToTabID:rangeType];
    if (resultCode == 0) {
        [self finishLoadDataForTabID:tabID resultList:postList];
    }else{
        [self failLoadDataForTabID:tabID];
    }
    [self updateTempPostListWithTabID:tabID];
}
- (void)updateTempPostListWithTabID:(NSInteger)tabID
{
    TableTab *tab = [_tabManager tabForID:tabID];
    if (tab) {
        [_bbsManager setTempPostList:tab.dataList];
    }
}

- (void)didGetUser:(NSString *)userId
          postList:(NSArray *)postList
        resultCode:(NSInteger)resultCode
{
    NSInteger tabID = [self rangeTypeToTabID:_rangeType];
    if (resultCode == 0) {
        [self finishLoadDataForTabID:tabID resultList:postList];
    }else{
        [self failLoadDataForTabID:tabID];
    }
    [self updateTempPostListWithTabID:tabID];
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
        ReplayView *replayView = [ReplayView createReplayView];
        BOOL isNewVersion = [ConfigManager currentDrawDataVersion] < version;
        [replayView showInController:self withActionList:drawActionList isNewVersion:isNewVersion];
    }else{
        PPDebug(@"<didGetBBSDrawActionList> fail!, resultCode = %d",resultCode);
    }
}
- (void)didDeleteBBSPost:(PBBBSPost *)post resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        PBBBSPost *p = post;
        if (p) {
            NSInteger row = [self.tabDataList indexOfObject:p];
            [self.tabDataList removeObject:p];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
            [self.dataTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    }else{
        PPDebug(@"<didDeleteBBSPost>fail to delete post, postId = %@, resultCode = %d",post.postId, resultCode);
    }
}

#pragma mark - table view delegate
- (PBBBSPost *)postForIndexPath:(NSIndexPath *)indexPath
{
    NSArray *dList = self.tabDataList;
    if (indexPath.row >= [dList count]) {
        return nil;
    }
    PBBBSPost *post = [self.tabDataList objectAtIndex:indexPath.row];
    return post;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBBBSPost *post = [self.tabDataList objectAtIndex:indexPath.row];
	return [BBSPostCell getCellHeightWithBBSPost:post];
}


- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [BBSPostCell getCellIdentifier];
	BBSPostCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [BBSPostCell createCell:self];
	}
    PBBBSPost *post = [self postForIndexPath:indexPath];
    [cell updateCellWithBBSPost:post];
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBBBSPost *post = [self postForIndexPath:indexPath];
    [BBSPostDetailController enterPostDetailControllerWithPost:post
                                                fromController:self
                                                      animated:YES];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBBBSPost *post = [self postForIndexPath:indexPath];
    if (post && post.canDelete) {
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
    PBBBSPost *post = [self postForIndexPath:indexPath];
    if (post && post.canDelete) {
        [self showActivityWithText:NSLS(@"kDeleting")];
        [[BBSService defaultService] deletePost:post delegate:self];
    }
}

#pragma mark - BBSPost cell delegate
- (void)didClickSupportButtonWithPost:(PBBBSPost *)post
{
    // ENTER DETAIL CONTROLLER
   BBSPostDetailController *bbsDetail = [[BBSPostDetailController alloc]initWithDefaultTabIndex:0];
    bbsDetail.post = post;
    [self.navigationController pushViewController:bbsDetail animated:YES];
    [bbsDetail release];

}
- (void)didClickReplyButtonWithPost:(PBBBSPost *)post
{
    // ENTER DETAIL CONTROLLER
    BBSPostDetailController *bbsDetail = [[BBSPostDetailController alloc]initWithDefaultTabIndex:1];
    bbsDetail.post = post;
    [self.navigationController pushViewController:bbsDetail animated:YES];
    [bbsDetail release];

}

- (void)didController:(CreatePostController *)controller
        CreateNewPost:(PBBBSPost *)post
{
    if (post) {
        [self.tabDataList insertObject:post atIndex:0];
        NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self.dataTableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
    }
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
    self.tempURL = url;
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    // Modal
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:nc animated:YES];
    [browser release];
    [nc release];
}

- (void)didClickDrawImageWithPost:(PBBBSPost *)post
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [[BBSService defaultService] getBBSDrawDataWithPostId:post.postId actionId:nil delegate:self];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    MWPhoto *photo = [MWPhoto photoWithURL:self.tempURL];
//    photo.caption = @"test string....";
    return photo;
}

@end
