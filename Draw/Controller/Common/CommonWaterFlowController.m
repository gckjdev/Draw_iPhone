//
//  CommonWaterFlowController.m
//  Draw
//
//  Created by Kira on 13-6-30.
//
//

#import "CommonWaterFlowController.h"
#import "PSCollectionView.h"
#import "CommonMessageCenter.h"

@interface CommonWaterFlowController ()

@property (assign, nonatomic) BOOL reloading;
@property (assign, nonatomic) BOOL loadingMore;
@property (retain, nonatomic) UIActivityIndicatorView *footerLoadMoreActivityView;

@end

@implementation CommonWaterFlowController

- (void)dealloc
{
    [_dataTableView release];
    PPRelease(_noDataTipLabel);
    PPRelease(_dataList);
    PPRelease(_refreshHeaderView);
    PPRelease(_refreshFooterView);
    PPRelease(_footerLoadMoreButton);
    PPRelease(_footerLoadMoreLabel);
    PPRelease(_footerLoadMoreTitle);
    PPRelease(_footerLoadMoreLoadingTitle);
    PPRelease(_footerLoadMoreActivityView);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.dataList = [[[NSMutableArray alloc] init] autorelease];
        self.dataListOffset = 0;
        self.supportRefreshFooter = YES;
        self.supportRefreshHeader = YES;
    }
    return self;
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
//    self.dataTableView.delegate = self;
    self.dataTableView.collectionViewDataSource =self;
    self.dataTableView.collectionViewDelegate = self;
    
    
    
    [super viewDidLoad];
    [self initRefreshHeaderView];
    [self initRefreshFooterView];
    
    
    self.view.backgroundColor = [UIColor clearColor];
    self.dataTableView.backgroundColor = [UIColor clearColor];
    self.dataTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //set defualt col num
    if (ISIPAD) {
        self.dataTableView.numColsPortrait = 4;
        self.dataTableView.numColsLandscape = 5;
    } else {
        self.dataTableView.numColsPortrait = 3;
        self.dataTableView.numColsLandscape = 4;
    }
    
//    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:self.dataTableView.bounds];
//    loadingLabel.text = NSLS(@"kLoading");
//    loadingLabel.textAlignment = UITextAlignmentCenter;
//    [loadingLabel setBackgroundColor:[UIColor clearColor]];
//    self.dataTableView.loadingView = loadingLabel;
    
    
//    [self createFooterLoadMoreButton];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Controller

- (EGORefreshTableHeaderView*)createRefreshHeaderView
{
    EGORefreshTableHeaderView* header =  [[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.dataTableView.bounds.size.height, self.dataTableView.frame.size.width, self.dataTableView.bounds.size.height)] autorelease];
    [header setBackgroundColor:[UIColor clearColor]];
    return header;
}


- (void)initRefreshHeaderView
{
    if (!self.supportRefreshHeader)
        return;
    
    if (self.refreshHeaderView == nil) {
        self.refreshHeaderView = [self createRefreshHeaderView];
		self.refreshHeaderView.delegate = self;
		[self.dataTableView addSubview:self.refreshHeaderView];
    }
    
    //  update the last update date
    [self.refreshHeaderView refreshLastUpdatedDate];
}

- (EGORefreshTableFooterView*)createRefreshFooterView
{
    EGORefreshTableFooterView* footer = [[EGORefreshTableFooterView alloc] initWithFrame: CGRectMake(0.0f, self.dataTableView.contentSize.height, self.dataTableView.frame.size.width, 650)];
    [footer setBackgroundColor:[UIColor clearColor]];
    return footer;
}

- (void)initRefreshFooterView
{
    if (!self.supportRefreshFooter)
        return;
    
//    if (_footerRefreshType != Lift) {
//        return;
//    }
    
	if (self.refreshFooterView == nil) {
		self.refreshFooterView = [self createRefreshFooterView];
		self.refreshFooterView.delegate = self;
		[self.dataTableView addSubview:self.refreshFooterView];
        
		self.refreshFooterView.hidden = YES;
	}
	
	//  update the last update date
	[self.refreshFooterView refreshLastUpdatedDate];
}


- (NSInteger)loadMoreLimit
{
    return 8;
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    _reloading = YES;
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableFooterDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    //    _loadingMore = YES;
    _reloading = YES;
	[self loadMoreTableViewDataSource];
}

- (BOOL)egoRefreshTableFooterDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading;
    //	return _loadingMore; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableFooterDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - PSCollectionViewDelegate and DataSource
- (NSInteger)numberOfViewsInCollectionView:(PSCollectionView *)collectionView {
    return self.dataList.count;
}

- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index {
    
    
    return nil;
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index {
    //    NSDictionary *item = [self.items objectAtIndex:index];
    
    return 0;
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectView:(PSCollectionViewCell *)view atIndex:(NSInteger)index {
    //    NSDictionary *item = [self.items objectAtIndex:index];
    
    // You can do something when the user taps on a collectionViewCell here
}


#pragma mark -
#pragma mark refreshHeaderView Methods

#pragma mark - For Subclass to re-write
// When "pull down to refresh" in triggered, this function will be called
- (void) reloadTableViewDataSource
{
    self.dataListOffset = 0;
    [self serviceLoadData];
}

// After finished loading data source, call this method to hide refresh view.
- (void)dataSourceDidFinishLoadingNewData{
	
    if (self.supportRefreshHeader)
    {
        _reloading = NO;
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.dataTableView];
    }
}

#pragma mark - For Subclass to re-write
// When "pull down to refresh" in triggered, this function will be called
- (void) loadMoreTableViewDataSource
{
    [self serviceLoadData];
}

// After finished loading data source, call this method to hide refresh view.
- (void)dataSourceDidFinishLoadingMoreData{
    if (self.supportRefreshFooter) {
//        if (_footerRefreshType == Lift) {
//            //        _loadingMore = NO;
//            _reloading = NO;
//            [self.refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:self.dataTableView];
//        } else if (_footerRefreshType == LiftAndAddMore  || _footerRefreshType == AutoAndAddMore){
//            _reloading = NO;
//
//        }
        
        _reloading = NO;
        [self.refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:self.dataTableView];
    }
}


#pragma mark ScrollView Callbacks for Pull Refresh

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
    if (self.supportRefreshHeader)
    {
        [self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    if (self.supportRefreshFooter) {
        [self.refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    if (!_noMoreData) {
        CGFloat height = MAX(self.dataTableView.contentSize.height, self.dataTableView.frame.size.height);
        self.dataTableView.contentSize = CGSizeMake(self.dataTableView.contentSize.width, height);
        self.refreshFooterView.frame = CGRectMake(0.0f, self.dataTableView.contentSize.height, self.dataTableView.frame.size.width, 650);
        self.refreshFooterView.hidden = NO;
    }else {
        self.refreshFooterView.hidden = YES;
    }
    
    return;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
    if (self.supportRefreshHeader)
    {
        [self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
    if (self.supportRefreshFooter) {
        [self.refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

- (void)serviceLoadData
{
    [self showActivityWithText:NSLS(@"kLoading")];
    PPDebug(@"<serviceLoadData> implement by sub class");
}
- (void)didFinishLoadData:(NSArray*)data
{
    [self hideActivity];
    [self dataSourceDidFinishLoadingNewData];
    [self dataSourceDidFinishLoadingMoreData];
    
    if (self.dataListOffset == 0) {
        [self.dataList removeAllObjects];
    }
    
    if ([data count] == 0) {
        _noMoreData = YES;
    }else{
        _noMoreData = (self.dataList.count + data.count >= [self maxDataCount]);
        [self.dataList addObjectsFromArray:data];
        self.dataListOffset += [self loadMoreLimit];//[tab.dataList count];
    }
    [self.noDataTipLabel setHidden:(self.dataList.count == 0)];
    [self.dataTableView reloadData];
}

- (void)didFinishLoadDataError:(int)errorCode
{
    [[CommonMessageCenter defaultCenter] postMessageWithText:[self errorTextForCode:errorCode] delayTime:2];
}

- (NSString*)errorTextForCode:(int)errorCode
{
    return [NSString stringWithFormat:@"error <%d>", errorCode];
}

- (int)maxDataCount
{
    return HUGE_VAL;
}

@end
