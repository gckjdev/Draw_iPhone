//
//  BBSBoardController.m
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import "BBSBoardController.h"
#import "BBSBoardCell.h"
#import "CreatePostController.h"

@interface BBSBoardController ()
{
    NSArray *_parentBoardList;
    BBSManager *_bbsManager;
    NSMutableSet *_openBoardSet;
}
@property(nonatomic, retain)NSArray *parentBoardList;

@end

@implementation BBSBoardController
@synthesize parentBoardList = _parentBoardList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _bbsManager = [BBSManager defaultManager];
        _openBoardSet = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[BBSService defaultService] getBBSBoardList:self];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)openAllSubBoards
//{
////    for (PBBBSBoard *pBoard in self.parentBoardList) {
////        NSArray *sBoards = [_bbsManager sbuBoardListForBoardId:pBoard.boardId];
////        [_openBoardSet addObjectsFromArray:sBoards];
////    }
//}

#pragma mark bbs borad delegate

- (void)didGetBBSBoardList:(NSArray *)boardList
               resultCode:(NSInteger)resultCode
{
    if (resultCode == 0) {
        self.parentBoardList = [_bbsManager parentBoardList];
        [_openBoardSet removeAllObjects];
        [_openBoardSet addObjectsFromArray:_parentBoardList];
    }else{
        PPDebug(@"<didGetBBSBoardList>: fail.");
    }
    [self.dataTableView reloadData];
}


#pragma mark table view delegate

- (void)didClickBoardSection:(BBSBoardSection *)boardSection
                    bbsBoard:(PBBBSBoard*)bbsBoard
{
    if (![_openBoardSet containsObject:bbsBoard]) {
        [_openBoardSet addObject:bbsBoard];
    }else{
        [_openBoardSet removeObject:bbsBoard];
    }
    NSInteger section = [_parentBoardList indexOfObject:bbsBoard];
    if (section != NSNotFound) {
        [self.dataTableView reloadSections:[NSIndexSet indexSetWithIndex:section]
                          withRowAnimation:UITableViewRowAnimationFade];
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    PBBBSBoard *board = [_parentBoardList objectAtIndex:section];
    BBSBoardSection *header = [BBSBoardSection createBoardSectionView:self];
    [header setViewWithBoard:board];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [BBSBoardSection getViewHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	return [BBSBoardCell getCellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_parentBoardList count];
}

- (NSArray *)subBoardListForSection:(NSInteger)section {
    if (section < [_parentBoardList count] && section >= 0) {
        PBBBSBoard *pBoard = [_parentBoardList objectAtIndex:section];
        NSArray *subList = [_bbsManager sbuBoardListForBoardId:pBoard.boardId];
        return subList;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PBBBSBoard *board = [_parentBoardList objectAtIndex:section];
    if ([_openBoardSet containsObject:board]) {
        return [[self subBoardListForSection:section] count];
    }
    return 0;
}


- (PBBBSBoard *)boardForIndexPath:(NSIndexPath *)indexPath
{
    PBBBSBoard *pBoard = [_parentBoardList objectAtIndex:indexPath.section];
    NSArray *subList = [_bbsManager sbuBoardListForBoardId:pBoard.boardId];
    if ([subList count] == 0) {
        return pBoard;
    }
    PBBBSBoard *sBoard = [subList objectAtIndex:indexPath.row];
    return sBoard;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [BBSBoardCell getCellIdentifier];
	BBSBoardCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [BBSBoardCell createCell:self];
	}
    PBBBSBoard *sBoard = [self boardForIndexPath:indexPath];
    [cell updateCellWithBoard:sBoard];
    
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBBBSBoard *sBoard = [self boardForIndexPath:indexPath];
    [CreatePostController enterControllerWithBoard:sBoard fromController:self];
}

@end
