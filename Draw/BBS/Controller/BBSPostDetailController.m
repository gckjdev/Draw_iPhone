//
//  BBSPostDetailController.m
//  Draw
//
//  Created by gamy on 12-11-17.
//
//

#import "BBSPostDetailController.h"
#import "BBSPostActionCell.h"


@interface BBSPostDetailController ()
@property (nonatomic, retain)PBBBSPost *post;

@end

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
    [super viewDidLoad];
    [self clickTabButton:self.currentTabButton];
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
	return [BBSPostActionCell getCellHeightWithBBSAction:action];
}


- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [BBSPostActionCell getCellIdentifier];
	BBSPostActionCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [BBSPostActionCell createCell:self];
	}
    PBBBSAction *action = [self actionForIndexPath:indexPath];
    [cell updateCellWithBBSAction:action];
	return cell;	
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
        if (tab == self.currentTab) {
            [self.dataTableView reloadData];
            //TODO change Setcion
//            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
//            [self.dataTableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}


@end
