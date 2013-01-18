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
#import "StatisticManager.h"

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
    [BBSViewManager updateDefaultTitleLabel:self.titleLabel text:NSLS(@"kBBS")];
    [BBSViewManager updateDefaultBackButton:self.backButton];
    [BBSViewManager updateDefaultTableView:self.dataTableView];

    
    [self.myPostButton setImage:[_bbsImageManager bbsBoardMineImage] forState:UIControlStateNormal];
    
    [self.myActionButton setImage:[_bbsImageManager bbsBoardCommentImage] forState:UIControlStateNormal];

    //badge
    [BBSViewManager updateButton:self.badge
                         bgColor:[UIColor clearColor]
                         bgImage:[_bbsImageManager bbsBadgeImage]
                           image:nil
                            font:[_bbsFontManager indexBadgeFont]
                      titleColor:[_bbsColorManager badgeColor]
                           title:nil
                        forState:UIControlStateNormal];
    [self.badge setUserInteractionEnabled:NO];
    [self.badge setHidden:YES];
    //back ground
    [self.bgImageView setImage:[_bbsImageManager bbsBGImage]];
    
    [self.refreshHeaderView setBackgroundColor:[UIColor clearColor]];
}

- (void)updateBadge
{
    long number = [[StatisticManager defaultManager] bbsActionCount];
    if (number > 0 ) {
        [self.badge setTitle:[NSString stringWithFormat:@"%ld",number] forState:UIControlStateNormal];
        self.badge.hidden = NO;
    }else{
        [self.badge setTitle:nil forState:UIControlStateNormal];
        self.badge.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateBadge];
}

- (void)updateBoardList
{
    [[BBSService defaultService] getBBSBoardList:self];
    if ([[[BBSManager defaultManager] boardList] count] != 0) {
        [self showActivityWithText:NSLS(@"kLoading")];
    }
}

- (void)viewDidLoad
{
    [self setSupportRefreshHeader:YES];
    [super viewDidLoad];
    [self initViews];
    [self updateBoardList];
//    // Do any additional setup after loading the view from its nib.
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
    [[StatisticManager defaultManager] setBbsActionCount:0];
    [BBSActionListController enterActionListControllerFromController:self animated:YES];
}

#pragma mark bbs borad delegate

- (void)didGetBBSBoardList:(NSArray *)boardList
               resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    [self dataSourceDidFinishLoadingNewData];   
    if (resultCode == 0) {
        self.parentBoardList = [_bbsManager parentBoardList];
        [_openBoardSet removeAllObjects];
        if ([_parentBoardList count] != 0) {
            NSObject *firstSection = [_parentBoardList objectAtIndex:0];
            [_openBoardSet addObject:firstSection];
        }
    }else{
        PPDebug(@"<didGetBBSBoardList>: fail.");
    }
    [self.dataTableView reloadData];
}


#pragma mark table view delegate

- (BOOL)isIndexPathLastCell:(NSIndexPath *)indexPath
{
    PBBBSBoard *pBoard = [_parentBoardList objectAtIndex:indexPath.section];
    NSArray *subList = [_bbsManager sbuBoardListForBoardId:pBoard.boardId];
    if ([subList count] != 0 && indexPath.row == ([subList count] - 1)) {
        return YES;
    }
    return NO;
}

- (void)didClickBoardSection:(BBSBoardSection *)boardSection
                    bbsBoard:(PBBBSBoard*)bbsBoard
{
    if (![_openBoardSet containsObject:bbsBoard]) {
        [_openBoardSet removeAllObjects];
        [_openBoardSet addObject:bbsBoard];
    }else{
        [_openBoardSet removeObject:bbsBoard];
    }
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _parentBoardList.count)];
    
    [self.dataTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];

}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    BBSBoardSection *header = [BBSBoardSection createBoardSectionView:self];
    PBBBSBoard *board = [_parentBoardList objectAtIndex:section];
    BOOL isOpen = [_openBoardSet containsObject:board];

    [header setViewWithBoard:board isOpen:isOpen];
    
    return header;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [[[UIView alloc] init] autorelease];
    [footer setBackgroundColor:[UIColor clearColor]];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [BBSBoardSection getViewHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [DeviceDetection isIPAD] ? 20 : 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL flag = [self isIndexPathLastCell:indexPath];
	CGFloat height = [BBSBoardCell getCellHeightLastBoard:flag];
    return height;
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
    BOOL flag = [self isIndexPathLastCell:indexPath];
    [cell updateCellWithBoard:sBoard isLastBoard:flag];
    
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBBBSBoard *sBoard = [self boardForIndexPath:indexPath];
    [BBSPostListController enterPostListControllerWithBBSBoard:sBoard fromController:self];
}

- (void)dealloc {
    PPRelease(_backButton);
    PPRelease(_myPostButton);
    PPRelease(_myActionButton);
    PPRelease(_badge);
    PPRelease(_titleLabel);
    PPRelease(_bgImageView);
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setMyPostButton:nil];
    [self setMyActionButton:nil];
    [self setBadge:nil];
    [self setTitleLabel:nil];
    [self setBgImageView:nil];
//    [[BBSManager defaultManager] setBoardList:nil];
//    [[[BBSManager defaultManager] boardDict] removeAllObjects];
    [super viewDidUnload];
}


#pragma mark - header pulling refresh
- (void)reloadTableViewDataSource
{
    [self updateBoardList];
}
@end
