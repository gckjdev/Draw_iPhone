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
#import "BBSPostDetailUserCell.h"
#import "ReplayGraffitiController.h"

@interface BBSPostDetailController ()
@property (nonatomic, retain)PBBBSPost *post;

@end

typedef enum{
    SectionDetail = 0,
    SectionAction = 1,
    SectionCount,
}Section;

typedef enum {
    DetailRowUser = 0,
    DetailRowContent = 1,
    DetailRowCount,
}DetailRow;

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
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _defaultTabIndex = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [self setPullRefreshType:PullRefreshTypeFooter];
    [super viewDidLoad];
    [self clickTab:Comment];
//    [self clickTabButton:self.currentTabButton];
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
    NSInteger tabIDs[] = {Support,Comment};
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
    if (indexPath.section != SectionAction) {
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
        case SectionDetail:
            return DetailRowCount;
            break;
        case SectionAction:
            return [super tableView:tableView numberOfRowsInSection:section];
//            return [self.tabDataList count];
        default:
            return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SectionDetail:
        {
            if (DetailRowUser == indexPath.row) {
                return [BBSPostDetailUserCell getCellHeight];
            }else if(DetailRowContent == indexPath.row){
                return  [BBSPostDetailCell getCellHeightWithPost:self.post];
            }
        }
        case SectionAction:
        {
            PBBBSAction *action = [self.tabDataList objectAtIndex:indexPath.row];
            return [BBSPostActionCell getCellHeightWithBBSAction:action];
        }
        default:
            break;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SectionAction) {
        return [BBSPostActionHeaderView getViewHeight];
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == SectionAction) {
        BBSPostActionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[BBSPostActionHeaderView getViewIdentifier]];
        if (headerView == nil) {
            headerView = [BBSPostActionHeaderView createView:self];
        }
        [headerView updateViewWithPost:self.post];
        return headerView;
    }
    return nil;
}

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
                if (DetailRowUser == indexPath.row) {
                    NSString *CellIdentifier = [BBSPostDetailUserCell getCellIdentifier];
                    BBSPostDetailUserCell *cell = [self getTableViewCell:theTableView cellIdentifier:CellIdentifier cellClass:[BBSPostDetailUserCell class]];
                    [cell updateCellWithUser:self.post.createUser];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                    
                }else if(DetailRowContent == indexPath.row){
                    NSString *CellIdentifier = [BBSPostDetailCell getCellIdentifier];
                    BBSPostDetailCell *cell = [self getTableViewCell:theTableView cellIdentifier:CellIdentifier cellClass:[BBSPostDetailCell class]];
                    [cell updateCellWithPost:self.post];
                    return cell;
                }
            }
            break;
        case SectionAction:
            {
                NSString *CellIdentifier = [BBSPostActionCell getCellIdentifier];
                BBSPostActionCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [BBSPostActionCell createCell:self];
                }
                PBBBSAction *action = [self actionForIndexPath:indexPath];
                [cell updateCellWithBBSAction:action];
                return cell;
            }
        default:
            break;
    }
    return nil;
}


#pragma mark - bbs post action cell delegate
- (void)didClickReplyButtonWithAction:(PBBBSAction *)action
{
    [CreatePostController enterControllerWithSourecePost:self.post
                                            sourceAction:action
                                          fromController:self].delegate = self;
}
- (void)didClickPayButtonWithAction:(PBBBSAction *)action
{
    PPDebug(@"<didClickPayButtonWithAction>");
}

#pragma mark - CreatePostController delegate
- (void)didController:(CreatePostController *)controller
      CreateNewAction:(PBBBSAction *)action
{
    if (action) {
        TableTab *tab = nil;
        if (action.type == ActionTypeSupport) {
            tab = [_tabManager tabForID:Support];
        }else if(action.type == ActionTypeComment){
            tab = [_tabManager tabForID:Comment];
        }
        [tab.dataList insertObject:action atIndex:0];
        [self clickTabButton:(UIButton *)[self.view viewWithTag:tab.tabID]];
    }
}

#pragma mark - BBSService delegate
- (void)didCreateAction:(PBBBSAction *)action
                 atPost:(PBBBSPost *)post
            replyAction:(PBBBSAction *)replyAction
             resultCode:(NSInteger)resultCode
{
    [self didController:nil CreateNewAction:action];
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
- (IBAction)clickSupportButton:(id)sender {
    [[BBSService defaultService] createActionWithPost:self.post
                                         sourceAction:nil
                                           actionType:ActionTypeSupport
                                                 text:nil
                                                image:nil
                                       drawActionList:nil
                                            drawImage:nil
                                             delegate:self];
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
}

- (void)didClickImageWithURL:(NSURL *)url
{
    //TODO enter show image Controller
}

- (void)didClickDrawImageWithAction:(PBBBSAction *)action
{
    [[BBSService defaultService] getBBSDrawDataWithPostId:nil
                                                 actionId:action.actionId
                                                 delegate:self];
}

@end
