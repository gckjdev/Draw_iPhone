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
#import "BoardAdminListView.h"

#import "DrawPlayer.h"
#import "AdService.h"
#import "UILabel+Touchable.h"
#import "MKBlockActionSheet.h"
#import "FriendController.h"

#define ADMINLISTVIEW_ORIGIN (ISIPAD ? CGPointMake(0,110+STATUSBAR_DELTA) : CGPointMake(0,49+STATUSBAR_DELTA))

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
@property (assign, nonatomic) BOOL showMarkedPosts;
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

+ (BBSPostListController *)enterMarkedPostListController:(PBBBSBoard *)board
                                          fromController:(UIViewController *)fromController
{
    BBSPostListController *pl = [[BBSPostListController alloc] init];
    [pl setBbsBoard:board];
    pl.showMarkedPosts = YES;
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
    return self.bbsBoard != nil && !self.showMarkedPosts;
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
    BoardAdminListView *adminListView = [BoardAdminListView adminListViewWithBBSUserList:self.bbsBoard.adminListList controller:self boardId:self.bbsBoard.boardId];
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

- (void)setupForBoardPosts
{
    NSString *titleName = self.bbsBoard.name;
    [self.createPostButton setImage:[_bbsImageManager bbsPostEditImage]
                           forState:UIControlStateNormal];
    [self.rankButton setImage:[_bbsImageManager bbsPostMarkImage]
                     forState:UIControlStateNormal];
    [BBSViewManager updateDefaultTitleLabel:self.titleLabel text:titleName];
}
- (void)setupForUserPosts
{
    NSString *titleName = [self.bbsUser isMe] ? NSLS(@"kMyPost") : self.bbsUser.nickName;
    self.createPostButton.hidden = YES;
    self.rankButton.hidden = YES;
    [BBSViewManager updateDefaultTitleLabel:self.titleLabel text:titleName];
}

- (void)setupForMarkedPosts
{
    self.createPostButton.hidden = YES;
    self.rankButton.hidden = YES;
    [BBSViewManager updateDefaultTitleLabel:self.titleLabel text:NSLS(@"kMarkedPosts")];
}

- (void)initViews
{
    [self.bgImageView setImage:[_bbsImageManager bbsBGImage]];
    if (self.bbsBoard) {
        if (self.showMarkedPosts) {
            [self setupForMarkedPosts];
        }else{
            [self setupForBoardPosts];
        }
    }else if(self.bbsUser){
        [self setupForUserPosts];
    }

    [BBSViewManager updateDefaultBackButton:self.backButton];
    [self.refreshFooterView setBackgroundColor:[UIColor clearColor]];
    [self.refreshHeaderView setBackgroundColor:[UIColor clearColor]];
    
    [self updateTableViewFrame];
    if ([self showBoardAdminList]) {
        [self showAdminListView];
    }
}

- (void)customBbsBg
{
    UIImage* image = [[UserManager defaultManager] bbsBackground];
    if (image) {
        [self.bgImageView setImage:image];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViews];
    [self clickTab:[self rangeTypeToTabID:_rangeType]];
    
    [self customBbsBg];
    // Do any additional setup after loading the view from its nib.
    
    if ([[UserManager defaultManager] isSuperUser]){
        [self.titleLabel addTapGuestureWithTarget:self selector:@selector(clickTitleLabel)];
    }
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.dataTableView reloadData];
    [self updateTempPostListWithTabID:self.currentTab.tabID];
/*
    self.adView = [[AdService defaultService] createAdInView:self
                                                       frame:CGRectMake(0, self.view.bounds.size.height-50, 320, 50)
                                                   iPadFrame:CGRectMake((self.view.bounds.size.width-320)/2-10, self.view.bounds.size.height-100, 320, 50)
                                                     useLmAd:YES];
  */

}

- (void)viewDidDisappear:(BOOL)animated
{
    [[AdService defaultService] clearAdView:self.adView];
    self.adView = nil;
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
    [[AdService defaultService] clearAdView:self.adView];
    self.adView = nil;
}

- (void)dealloc {
    
    [[AdService defaultService] clearAdView:self.adView];
    self.adView = nil;
    
    [_bbsManager setTempPostList:nil];
    PPRelease(_backButton);
    PPRelease(_createPostButton);
    PPRelease(_rankButton);
    PPRelease(_bgImageView);
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
    CHECK_AND_LOGIN(self.view);
    if (self.bbsBoard) {
        [CreatePostController enterControllerWithBoard:self.bbsBoard fromController:self].delegate = self;
    }else{
        PPDebug(@"<clickCreatePostButton>: board is nil");
    }
}



- (IBAction)clickRankButton:(id)sender {

    [BBSPostListController enterMarkedPostListController:self.bbsBoard fromController:self];
    return;
}

- (void)addAdmin
{
    [FriendController searchUser:self callback:^(FriendController *controller, MyFriend *selectUser) {
        if (selectUser){
            [[BBSService defaultService] addBoardAdmin:self.bbsBoard.boardId userId:selectUser.friendUserId resultBlock:^(NSInteger resultCode) {
                
            }];
        }
    }];
}

- (void)addManager
{
    [FriendController searchUser:self callback:^(FriendController *controller, MyFriend *selectUser) {
        if (selectUser){
            [[BBSService defaultService] addBoardManager:self.bbsBoard.boardId userId:selectUser.friendUserId resultBlock:^(NSInteger resultCode) {
                
            }];
        }
    }];
}

- (void)deleteBoard
{
    NSString* msg = [NSString stringWithFormat:@"确认删除板块【%@】", self.bbsBoard.name];
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:@"删除板块" message:msg style:CommonDialogStyleDoubleButton];
    [dialog setClickOkBlock:^(id infoView){
        [[BBSService defaultService] deleteBoard:self.bbsBoard.boardId resultBlock:^(NSInteger resultCode) {
            
        }];
    }];
    
    [dialog showInView:self.view];
}

- (void)setBoardName
{
    CommonDialog* dialog = [CommonDialog createInputFieldDialogWith:@"请输入版块名称"];
    dialog.inputTextField.text = @"";
    
    [dialog setClickOkBlock:^(id infoView){
        NSString* name = dialog.inputTextField.text;
        [[BBSService defaultService] updateBoard:self.bbsBoard.boardId name:name seq:0 resultBlock:^(NSInteger resultCode) {
            
        }];
    }];
    
    [dialog showInView:self.view];
}

- (void)setBoardSeq
{
    CommonDialog* dialog = [CommonDialog createInputFieldDialogWith:@"请输入版块顺序"];
    dialog.inputTextField.text = @"";
    
    [dialog setClickOkBlock:^(id infoView){
        int seq = [dialog.inputTextField.text intValue];
        [[BBSService defaultService] updateBoard:self.bbsBoard.boardId name:@"" seq:seq resultBlock:^(NSInteger resultCode) {
            
        }];
    }];
    
    [dialog showInView:self.view];
}


- (void)clickTitleLabel
{
    enum{
        INDEX_ADD_ADMIN = 0,
        INDEX_ADD_MANAGER,
        INDEX_DELETE_BOARD,
        INDEX_SET_BOARD_NAME,
        INDEX_SET_BOARD_SEQ,
        INDEX_CANCEL
    };
    
    MKBlockActionSheet* actionSheet = [[MKBlockActionSheet alloc] initWithTitle:@"管理员操作"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"取消"
                                                         destructiveButtonTitle:@"设置管理员"
                                                              otherButtonTitles:@"设置版主", @"删除版块", @"设置名称", @"设置顺序", nil];
    
    [actionSheet setActionBlock:^(NSInteger buttonIndex){
        switch (buttonIndex) {
            case INDEX_ADD_ADMIN:
                PPDebug(@"select INDEX_ADD_ADMIN");
                [self addAdmin];
                break;
                
            case INDEX_ADD_MANAGER:
                PPDebug(@"select INDEX_ADD_MANAGER");
                [self addManager];
                break;
                
            case INDEX_DELETE_BOARD:
                PPDebug(@"select INDEX_DELETE_BOARD");
                [self deleteBoard];
                break;
                
            case INDEX_SET_BOARD_NAME:
                PPDebug(@"select INDEX_SET_BOARD_NAME");
                [self setBoardName];
                break;
                
            case INDEX_SET_BOARD_SEQ:
                PPDebug(@"select INDEX_SET_BOARD_SEQ");
                [self setBoardSeq];
                break;
                
            default:
                break;
        }
    }];
    
    [actionSheet showInView:self.view];
    [actionSheet release];
    
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
    TableTab *tab = [_tabManager tabForID:tabID];
    [self showActivityWithText:NSLS(@"kLoading")];
    if (self.showMarkedPosts) {

        [[self bbsService] getMarkedPostList:self.bbsBoard.boardId offset:tab.offset limit:tab.limit hanlder:^(NSInteger resultCode, NSArray *postList, NSInteger tag) {
            [self hideActivity];
            if (resultCode == 0) {
                [self finishLoadDataForTabID:tabID resultList:postList];
            }else{
                [self failLoadDataForTabID:tabID];
            }
            [self updateTempPostListWithTabID:tabID];

        }];
        return;
    }
    NSInteger rangeType = [self tabIDToRangeType:tabID];
    [[self bbsService] getBBSPostListWithBoardId:_bbsBoard.boardId
                                                 targetUid:_bbsUser.userId
                                                 rangeType:rangeType
                                                    offset:tab.offset
                                                     limit:tab.limit
                                                  delegate:self];

}

#pragma mark - bbs service delegate
- (void)didGetBBSBoard:(NSString *)boardId
              postList:(NSArray *)postList
             rangeType:(RangeType)rangeType
            resultCode:(NSInteger)resultCode
{
    [self hideActivity];
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
    cell.backgroundColor = [UIColor clearColor];
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
        [[self bbsService] deletePost:post delegate:self];
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

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    return NSLS(@"kNoPost");
}

@end
