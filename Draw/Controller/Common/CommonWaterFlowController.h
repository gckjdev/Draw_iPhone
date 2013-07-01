//
//  CommonWaterFlowController.h
//  Draw
//
//  Created by Kira on 13-6-30.
//
//

#import "PPViewController.h"
#import "PSCollectionView.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

//typedef  enum{
//    Lift = 0,
//    LiftAndAddMore = 1,
//    AutoAndAddMore = 2
//}FooterRefreshType;

@class PSCollectionView;

@interface CommonWaterFlowController : PPViewController <PSCollectionViewDelegate, PSCollectionViewDataSource, EGORefreshTableHeaderDelegate, EGORefreshTableFooterDelegate, UIScrollViewDelegate>

@property (retain, nonatomic) IBOutlet PSCollectionView* dataTableView;

//@property (nonatomic, assign) FooterRefreshType footerRefreshType;
@property (nonatomic, retain) UIButton *footerLoadMoreButton;

@property (nonatomic, retain) UILabel *footerLoadMoreLabel;
@property (nonatomic, retain) NSString *footerLoadMoreTitle;
@property (nonatomic, retain) NSString *footerLoadMoreLoadingTitle;

@property (nonatomic, retain) NSMutableArray* dataList;
@property (assign, nonatomic) NSInteger dataListOffset;

@property (nonatomic, retain) IBOutlet UILabel *noDataTipLabel;

#pragma mark: For pull down to refresh
// For pull down to refresh
@property(nonatomic,assign) BOOL supportRefreshHeader;
@property(nonatomic,retain) EGORefreshTableHeaderView *refreshHeaderView;
// When "pull down to refresh" in triggered, this function will be called
- (void)reloadTableViewDataSource;
// After finished loading data source, call this method to hide refresh view.
//- (void)dataSourceDidFinishLoadingNewData;

#pragma mark: For pull up to load more
// For pull up to load more
@property (nonatomic, assign) BOOL noMoreData;
@property (nonatomic, assign) BOOL supportRefreshFooter;
@property (nonatomic, retain) EGORefreshTableFooterView *refreshFooterView;
// When "pull up to load more" in triggered, this function will be called
//- (void)loadMoreTableViewDataSource;
// After finished loading data source, call this method to hide refresh view.
//- (void)dataSourceDidFinishLoadingMoreData;


//for sub class impletement
- (NSInteger)loadMoreLimit;
- (void)serviceLoadServiceFromOffset:(int)offset;
- (void)didFinishLoadData:(NSArray*)data;
- (void)didFinishLoadDataError:(int)errorCode;
- (NSString*)errorTextForCode:(int)errorCode;
- (int)maxDataCount;
@end
