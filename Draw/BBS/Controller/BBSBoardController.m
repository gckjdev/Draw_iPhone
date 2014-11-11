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
#import "StableView.h"
#import "SearchPostController.h"
#import "UILabel+Touchable.h"
#import "MKBlockActionSheet.h"

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
@property (retain, nonatomic) IBOutlet BadgeView *badge;
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
        self.unReloadDataWhenViewDidAppear = YES;
    }
    return self;
}

- (void)initViews
{
    [BBSViewManager updateDefaultTitleLabel:self.titleLabel text:NSLS(@"kBBS")];
    [BBSViewManager updateDefaultBackButton:self.backButton];
    [BBSViewManager updateDefaultTableView:self.dataTableView];

    
    [self.myPostButton setBackgroundImage:[_bbsImageManager bbsBoardSearchImage] forState:UIControlStateNormal];
    
    [self.myActionButton setBackgroundImage:[_bbsImageManager bbsBoardCommentImage] forState:UIControlStateNormal];

    //back ground
    [self.bgImageView setImage:[_bbsImageManager bbsBGImage]];
    
    [self.refreshHeaderView setBackgroundColor:[UIColor clearColor]];
}

- (void)updateBadge
{
    long number = [[StatisticManager defaultManager] bbsActionCount];
    [self.badge setNumber:number];
}

- (void)viewDidAppear:(BOOL)animated
{
    float width = [UIScreen mainScreen].bounds.size.width;
    
    self.adView = [[AdService defaultService] createAdInView:self
                                                       frame:CGRectMake(0, self.view.bounds.size.height-50, width, 50)
                                                   iPadFrame:CGRectMake((self.view.bounds.size.width-width)/2, self.view.bounds.size.height-100, width, 100)
                                                     useLmAd:YES];
    
    [super viewDidAppear:animated];
    [self updateBadge];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[AdService defaultService] clearAdView:self.adView];
    self.adView = nil;

    [super viewDidDisappear:animated];
}

- (void)updateBoardList
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [[BBSService defaultService] getBBSBoardList:self];
    [[BBSService defaultService] getBBSPrivilegeList];
//    if ([[[BBSManager defaultManager] boardList] count] != 0) {
    
//    }
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
    [self setSupportRefreshHeader:YES];
    [super viewDidLoad];
    [self initViews];
    [self updateBoardList];
    [self customBbsBg];
    [self updateBadge];
    
    if ([[UserManager defaultManager] isSuperUser]){
        [self.titleLabel addTapGuestureWithTarget:self selector:@selector(clickTitleLabel)];
    }
    
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

    SearchPostController *sp = [[SearchPostController alloc] init];
    [self.navigationController pushViewController:sp animated:YES];
    [sp release];
    return;
    
//    CHECK_AND_LOGIN(self.view);
//    [BBSPostListController enterPostListControllerWithBBSUser:[[BBSService defaultService] myself]
//                                               fromController:self];
}

- (IBAction)clickMyAction:(id)sender {
    CHECK_AND_LOGIN(self.view);
    [[StatisticManager defaultManager] setBbsActionCount:0];
    [BBSActionListController enterActionListControllerFromController:self animated:YES];
}


#define DEFAULT_BOARD_INDEX 800

- (void)createBoard
{
    CommonDialog* dialog = [CommonDialog createInputFieldDialogWith:@"请输入版块名称"];
    dialog.inputTextField.text = @"";
    
    int STEP = 50;
    int index = [[BBSManager defaultManager] getLastBoardIndex] + STEP;
    
    [dialog setClickOkBlock:^(id infoView){
        [[BBSService defaultService] createBoard:dialog.inputTextField.text
                                             seq:index
                                     resultBlock:^(NSInteger resultCode) {
        }];
    }];
    
    [dialog showInView:self.view];
}


- (void)clickTitleLabel
{
    enum{
        INDEX_CREATE_BOARD = 0,
        INDEX_CANCEL
    };
    
    MKBlockActionSheet* actionSheet = [[MKBlockActionSheet alloc] initWithTitle:@"管理员操作" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"创建版块" otherButtonTitles:nil];
    
    [actionSheet setActionBlock:^(NSInteger buttonIndex){
        switch (buttonIndex) {
            case INDEX_CREATE_BOARD:
                PPDebug(@"select create board");
                [self createBoard];
                break;
                
            default:
                break;
        }
    }];
    
    [actionSheet showInView:self.view];
    [actionSheet release];
    
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
    cell.backgroundColor = [UIColor clearColor];
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBBBSBoard *sBoard = [self boardForIndexPath:indexPath];
    [BBSPostListController enterPostListControllerWithBBSBoard:sBoard fromController:self];
}

- (void)dealloc {

    [[AdService defaultService] clearAdView:self.adView];
    self.adView = nil;
    
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
