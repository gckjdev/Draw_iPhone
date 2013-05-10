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
#import "CMPopTipView.h"


@interface LittleGeeHomeController ()

@property(nonatomic, retain)HomeBottomMenuPanel *homeBottomMenuPanel;
@property (nonatomic, retain) CustomActionSheet* optionSheet;
@property (nonatomic, retain) CustomActionSheet* drawActionSheet;

@end

@implementation LittleGeeHomeController

- (void)dealloc
{
    PPRelease(_homeBottomMenuPanel);
    PPRelease(_optionSheet);
    PPRelease(_drawActionSheet);
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
    [self initTabButtons];
    [self initDrawActions];
    // Do any additional setup after loading the view from its nib.
}

- (void)initDrawActions
{
    self.drawActionSheet = [[[CustomActionSheet alloc] initWithTitle:nil delegate:self buttonTitles:nil] autorelease];
    [self.drawActionSheet addButtonWithTitle:NSLS(@"kDrawTo") image:nil];
    [self.drawActionSheet addButtonWithTitle:NSLS(@"kDraft") image:nil];
    [self.drawActionSheet addButtonWithTitle:NSLS(@"kBegin") image:nil];
    [self.drawActionSheet addButtonWithTitle:NSLS(@"kContest") image:nil];
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
        case HomeMenuTypeLittleGeeOptions: {
            if (!_optionSheet) {
                self.optionSheet = [[[CustomActionSheet alloc] initWithTitle:nil delegate:self imageArray:[UIImage imageNamed:@"bm_chat.png"], [UIImage imageNamed:@"bm_chat.png"], [UIImage imageNamed:@"bm_chat.png"], [UIImage imageNamed:@"bm_chat.png"], nil] autorelease];
//                [self.actionSheet.popView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_pattern.png"]]];
            }
            if ([_optionSheet isVisable]) {
                [_optionSheet hideActionSheet];
            } else {
                [_optionSheet showInView:self.view onView:menu WithContainerSize:CGSizeMake(40, 400) columns:1 showTitles:NO itemSize:CGSizeMake(30, 30) backgroundImage:[UIImage imageNamed:@"wood_bg.jpg"]];
            }
            
        }break;
            
        default:
            break;
    }
     [menu updateBadge:0];
}

#pragma mark - custom action sheet delegate
- (void)customActionSheet:(CustomActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
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
    CGFloat width = [RankView widthForRankViewType:RankViewTypeNormal];
    CGFloat height = [RankView heightForRankViewType:RankViewTypeNormal];
    
    CGFloat space =  WIDTH_SPACE;
    CGFloat x = 0;
    CGFloat y = 0;
    for (DrawFeed *feed in feeds) {
        RankView *rankView = [RankView createRankView:self type:RankViewTypeNormal];
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
    return [RankView heightForRankViewType:RankViewTypeNormal] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
    //        PPDebug(@"startIndex = %d",startIndex);
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

- (int)tabIDFromType:(LittleGeeHomeGalleryType)type
{
    return type + OFFSET;
}

- (LittleGeeHomeGalleryType)littleGeeTypeFromFeedListType:(FeedListType)type
{
    int littleGeeType = 0;
    switch (type) {
        case FeedListTypeHistoryRank:
            littleGeeType = LittleGeeHomeGalleryTypeAnnual;
            break;
        case FeedListTypeHot:
            littleGeeType = LittleGeeHomeGalleryTypeWeekly;
            break;
        case FeedListTypeLatest:
            littleGeeType = LittleGeeHomeGalleryTypeLatest;
        default:
            break;
    }
    return littleGeeType;
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
    
    return [self tabIDFromType:types[index]];
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *titles[] = {NSLS(@"kRankHistory"),NSLS(@"kRankHot"),NSLS(@"kRankNew"),NSLS(@"kLittleGeeRecommend"),NSLS(@"kFriend")};
    return titles[index];
}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    [self showActivityWithText:NSLS(@"kLoading")];
    TableTab *tab = [_tabManager tabForID:tabID];
    int type = [self typeFromTabID:tabID];
    if (tab) {
        if (type == LittleGeeHomeGalleryTypeLatest) {
            [[FeedService defaultService] getFeedList:FeedListTypeLatest offset:tab.offset limit:tab.limit delegate:self];
        }else if(type == LittleGeeHomeGalleryTypeFriend){
//            [[UserService defaultService] getTopPlayer:tab.offset limit:tab.limit delegate:self];
        }else if (type == LittleGeeHomeGalleryTypeAnnual) {
            [[FeedService defaultService] getFeedList:FeedListTypeHistoryRank offset:tab.offset limit:tab.limit delegate:self];
        }else if (type == LittleGeeHomeGalleryTypeWeekly) {
            [[FeedService defaultService] getFeedList:FeedListTypeHot offset:tab.offset limit:tab.limit delegate:self];
        }
        else if (type == LittleGeeHomeGalleryTypeRecommend){
            [self hideActivity];
//            [[FeedService defaultService] getFeedList:FeedListTypeHistoryRank offset:tab.offset limit:tab.limit delegate:self];
        }
        
    }
    
}

#pragma mark - feed service delegate

- (void)didGetFeedList:(NSArray *)feedList
          feedListType:(FeedListType)type
            resultCode:(NSInteger)resultCode
{
    PPDebug(@"<didGetFeedList> list count = %d ", [feedList count]);
    [self hideActivity];
    if (resultCode == 0) {
        for (DrawFeed *feed in feedList) {
            //            PPDebug(@"%d: feedId = %@, word = %@", i++, feed.feedId,feed.wordText);
        }
        [self finishLoadDataForTabID:[self tabIDFromType:[self littleGeeTypeFromFeedListType:type]] resultList:feedList];
    }else{
        [self failLoadDataForTabID:[self tabIDFromType:[self littleGeeTypeFromFeedListType:type]]];
    }
    

}

//- (void)didGetTopPlayerList:(NSArray *)playerList
//                 resultCode:(NSInteger)resultCode
//{
//    PPDebug(@"<didGetTopPlayerList> list count = %d ", [playerList count]);
//    [self hideActivity];
//    if (resultCode == 0) {
//        [self finishLoadDataForTabID:LittleGeeHomeGalleryTypeFriend resultList:playerList];
//    }else{
//        [self failLoadDataForTabID:LittleGeeHomeGalleryTypeFriend];
//    }
//}



@end
