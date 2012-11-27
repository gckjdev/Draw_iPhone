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
#import "BBSPostListController.h"
#import "BBSActionListController.h"
//#import "BBSManager.h"

@interface BBSBoardController ()
{
    NSArray *_parentBoardList;
    BBSManager *_bbsManager;
    
    BBSImageManager *_bbsImageManager;
    BBSColorManager *_bbsColorManager;
    BBSFontManager *_bbsFontManager;
    
    NSMutableSet *_openBoardSet;
}
@property(nonatomic, retain)NSArray *parentBoardList;
- (IBAction)clickBackButton:(id)sender;
- (IBAction)clickMyPostList:(id)sender;
- (IBAction)clickMyAction:(id)sender;

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *myPostButton;
@property (retain, nonatomic) IBOutlet UIButton *myActionButton;
@property (retain, nonatomic) IBOutlet UIButton *badge;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;

@end

@implementation BBSBoardController
@synthesize parentBoardList = _parentBoardList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _bbsManager = [BBSManager defaultManager];
        _bbsImageManager = [BBSImageManager defaultManager];
        _bbsFontManager = [BBSFontManager defaultManager];
        _bbsColorManager = [BBSColorManager defaultManager];
        
        _openBoardSet = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)initViews
{
    [self.backButton setImage:[_bbsImageManager bbsBackImage] forState:UIControlStateNormal];

    //title label
    [self.titleLabel setFont:[_bbsFontManager indexTitleFont]];
    [self.titleLabel setText:NSLS(@"kBBS")];
    [self.titleLabel setTextColor:[_bbsColorManager indexTitleColor]];
    
    //action button
    [self.myActionButton.titleLabel setFont:[_bbsFontManager indexTabFont]];

    [self.myActionButton setBackgroundImage:[_bbsImageManager bbsButtonLeftImage]
                                    forState:UIControlStateNormal];
    [self.myActionButton setTitle:NSLS(@"kMine") forState:UIControlStateNormal];
    [self.myActionButton setTitleColor:[_bbsColorManager tabTitleColor] forState:UIControlStateNormal];
    
    //post button
    [self.myPostButton setBackgroundImage:[_bbsImageManager bbsButtonRightImage]
                                   forState:UIControlStateNormal];
    [self.myPostButton.titleLabel setFont:[_bbsFontManager indexTabFont]];
    [self.myPostButton setTitle:NSLS(@"kComment") forState:UIControlStateNormal];
    [self.myPostButton setTitleColor:[_bbsColorManager tabTitleColor] forState:UIControlStateNormal];
    
    //badge
    [self.badge setUserInteractionEnabled:NO];
    [self.badge setBackgroundImage:[_bbsImageManager bbsBadgeImage]
                                 forState:UIControlStateNormal];
    [self.badge.titleLabel setFont:[_bbsFontManager indexBadgeFont]];
    [self.badge setTitle:@"25" forState:UIControlStateNormal];
    [self.badge setTitleColor:[_bbsColorManager badgeColor] forState:UIControlStateNormal];
    
    //back ground
    [self.bgImageView setImage:[_bbsImageManager bbsBGImage]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViews];
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

- (IBAction)clickMyPostList:(id)sender {
    [BBSPostListController enterPostListControllerWithBBSUser:[[BBSService defaultService] myself]
                                               fromController:self];
}

- (IBAction)clickMyAction:(id)sender {
    [BBSActionListController enterActionListControllerFromController:self animated:YES];
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
    [BBSPostListController enterPostListControllerWithBBSBoard:sBoard fromController:self];
}

- (void)dealloc {
    [_backButton release];
    [_myPostButton release];
    [_myActionButton release];
    [_badge release];
    [_titleLabel release];
    [_bgImageView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setMyPostButton:nil];
    [self setMyActionButton:nil];
    [self setBadge:nil];
    [self setTitleLabel:nil];
    [self setBgImageView:nil];
    [super viewDidUnload];
}
@end
