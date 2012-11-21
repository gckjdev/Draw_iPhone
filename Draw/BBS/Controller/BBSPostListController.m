//
//  BBSPostListController.m
//  Draw
//
//  Created by gamy on 12-11-17.
//
//

#import "BBSPostListController.h"
#import "Bbs.pb.h"
#import "CreatePostController.h"
#import "BBSPostCell.h"
#import "BBSPostDetailController.h"

@interface BBSPostListController ()
{
    RangeType _rangeType;
}
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
    }
    return self;
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self clickTab:[self rangeTypeToTabID:_rangeType]];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_backButton release];
    [_createPostButton release];
    [_rankButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setCreatePostButton:nil];
    [self setRankButton:nil];
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
        [self.rankButton setTitle:NSLS(@"kNew") forState:UIControlStateNormal];
    }else{
        _rangeType = RangeTypeHot;
        [self.rankButton setTitle:NSLS(@"kHot") forState:UIControlStateNormal];
    }
    NSInteger tabID = [self rangeTypeToTabID:_rangeType];
    self.rankButton.tag = tabID;
    [self clickTab:tabID];
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
//    return POST_LIST_TAB;
//    NSInteger tabs[] = {RangeTypeNew, RangeTypeHot};
//    return tabs[index];
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

#pragma mark - BBSPost cell delegate
- (void)didClickSupportButtonWithPost:(PBBBSPost *)post
{
    
}
- (void)didClickReplyButtonWithPost:(PBBBSPost *)post
{
    [CreatePostController enterControllerWithSourecePost:post
                                            sourceAction:nil
                                          fromController:self];
}

- (void)didController:(CreatePostController *)controller
        CreateNewPost:(PBBBSPost *)post
{
    if (post) {
        [self.tabDataList insertObject:post atIndex:0];
        [self.dataTableView reloadData];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBBBSPost *post = [self postForIndexPath:indexPath];
    [BBSPostDetailController enterPostDetailControllerWithPost:post
                                                fromController:self
                                                      animated:YES];
}

@end
