//
//  LittleGeeHomeController.m
//  Draw
//
//  Created by Kira on 13-5-8.
//
//

#import "LittleGeeHomeController.h"
#import "RankView.h"
#import "MKBlockActionSheet.h"
#import "BBSPermissionManager.h"

@interface LittleGeeHomeController ()

@property(nonatomic, retain)HomeBottomMenuPanel *homeBottomMenuPanel;


@end

@implementation LittleGeeHomeController

- (void)dealloc
{
    PPRelease(_homeBottomMenuPanel);
    [super dealloc];
}

- (void)addBottomMenuView
{
    self.homeBottomMenuPanel = [HomeBottomMenuPanel createView:self];
    [self.view addSubview:self.homeBottomMenuPanel];
    [self.homeBottomMenuPanel updateOriginY:CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.homeBottomMenuPanel.bounds)];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBottomMenuView];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)homeBottomMenuPanel:(HomeBottomMenuPanel *)bottomMenuPanel
               didClickMenu:(HomeMenuView *)menu
                   menuType:(HomeMenuType)type
{
    switch (type) {
        case HomeMenuTypeLittleGeeOptions:
            //
            break;
            
        default:
            break;
    }
     [menu updateBadge:0];
}


//rank view delegate
- (void)playFeed:(DrawFeed *)aFeed
{

    
}

// progress download delegate
- (void)setProgress:(CGFloat)progress
{
    if (progress == 1.0f){
        // make this because after uploading data, it takes server sometime to process
        progress = 0.99;
    }
    
    NSString* progressText = [NSString stringWithFormat:NSLS(@"kLoadingProgress"), progress*100];
    [self.progressView setLabelText:progressText];
    [self.progressView setProgress:progress];
}


- (void)showFeed:(DrawFeed *)feed placeHolder:(UIImage *)placeHolder
{
    
}

- (void)didClickRankView:(RankView *)rankView
{
    
    if (![[BBSPermissionManager defaultManager] canPutDrawOnCell]) {
        [self showFeed:rankView.feed placeHolder:rankView.drawImage.image];
    }else{
        
        
    }
    
}



//table view delegate





#define NORMAL_CELL_VIEW_NUMBER 3
#define WIDTH_SPACE 1

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
    return  count / NORMAL_CELL_VIEW_NUMBER + (count % NORMAL_CELL_VIEW_NUMBER != 0);
}

- (void)setNormalRankCell:(UITableViewCell *)cell
                WithFeeds:(NSArray *)feeds
{
    CGFloat width = [RankView widthForRankViewType:RankViewTypeDrawOnCell];
    CGFloat height = [RankView heightForRankViewType:RankViewTypeDrawOnCell];
    
    CGFloat space =  WIDTH_SPACE;
    CGFloat x = 0;
    CGFloat y = 0;
    for (DrawFeed *feed in feeds) {
        RankView *rankView = [RankView createRankView:self type:RankViewTypeDrawOnCell];
        [rankView setViewInfo:feed];
        [cell.contentView addSubview:rankView];
        rankView.frame = CGRectMake(x, y, width, height);
        x += width + space;
    }
}

- (NSObject *)saveGetObjectForIndex:(NSInteger)index
{
    NSArray *list = [self tabDataList];
    if (index < 0 || index >= [list count]) {
        return nil;
    }
    return [list objectAtIndex:index];
}

- (void)clearCellSubViews:(UITableViewCell *)cell{
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[RankView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [RankView heightForRankViewType:RankViewTypeDrawOnCell] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //    TableTab *tab = [self currentTab];
    
    
    
    NSString *CellIdentifier = @"RankCell";//[RankFirstCell getCellIdentifier];
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }else{
        [self clearCellSubViews:cell];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSInteger startIndex = (indexPath.row * NORMAL_CELL_VIEW_NUMBER);
    NSMutableArray *list = [NSMutableArray array];
    for (NSInteger i = startIndex; i < startIndex+NORMAL_CELL_VIEW_NUMBER; ++ i) {
        NSObject *object = [self saveGetObjectForIndex:i];
        if (object) {
            [list addObject:object];
        }
    }
    [self setNormalRankCell:cell WithFeeds:list];
    return cell;
    
}

//table tab manager


#define OFFSET 100

- (LittleGeeHomeGalleryType)typeFromTabID:(int)tabID
{
    return tabID - OFFSET;
}

- (int)tabIDFromeType:(LittleGeeHomeGalleryType)type
{
    return type + OFFSET;
}

- (NSInteger)tabCount //default 1
{
    return 5;
}
- (NSInteger)currentTabIndex //default 0
{
    return _defaultTabIndex;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index //default 20
{
    return 15;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    
    int types[] = {
        LittleGeeHomeGalleryTypeAnnual,
        LittleGeeHomeGalleryTypeWeekly,
        LittleGeeHomeGalleryTypeLatest,
        LittleGeeHomeGalleryTypeRecommend,
        LittleGeeHomeGalleryTypeFriend};
    
    return [self tabIDFromeType:types[index]];
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *titles[] = {NSLS(@"kRankHistory"),NSLS(@"kRankHot"),NSLS(@"kRankNew"),NSLS(@"kLittleGeeRecommend"),NSLS(@"kFriend")};
    return titles[index];
}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
//    TableTab *tab = [_tabManager tabForID:tabID];
    
}

@end
