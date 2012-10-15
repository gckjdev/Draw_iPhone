//
//  CommonTabController.h
//  Draw
//
//  Created by  on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPTableViewController.h"

@class TableTabManager;
@class TableTab;


@protocol CommonTabControllerDelegate <NSObject>

@required
- (NSInteger)tabCount; //default 1
- (NSInteger)currentTabIndex; //default 0
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index; //default 20
- (NSInteger)tabIDforIndex:(NSInteger)index;
- (NSString *)tabTitleforIndex:(NSInteger)index;
- (void)serviceLoadDataForTabID:(NSInteger)tabID;

@optional
- (void)serviceDeleteData:(NSObject *)data ForTabID:(NSInteger)tabID;
- (NSString *)tabNoDataTipsforIndex:(NSInteger)index;

//- (void)startToLoadDataForTabID:(NSInteger)tabID;
@end

@interface CommonTabController : PPTableViewController<CommonTabControllerDelegate>
{
    TableTabManager *_tabManager;
    NSInteger _defaultTabIndex;
}


//common xib and action
@property(nonatomic, retain)IBOutlet UILabel *titleLabel;
@property(nonatomic, retain)IBOutlet UILabel *noDataTipLabl;
@property(nonatomic, assign, getter = isSupportPullRefresh)BOOL supportPullRefresh;
- (IBAction)clickBackButton:(id)sender;
- (IBAction)clickTabButton:(id)sender;
- (IBAction)clickRefreshButton:(id)sender;
- (id)initWithDefaultTabIndex:(NSInteger)index;

+ (void)enterControllerWithIndex:(NSInteger)index
                  fromController:(UIViewController *)controller 
                        animated:(BOOL)animated;


//used by the sub class.
- (NSMutableArray *)tabDataList;
- (TableTab *)currentTab;
- (UIButton *)currentTabButton;
- (UIButton *)tabButtonWithTabID:(NSInteger)tabID;
- (void)startToLoadDataForTabID:(NSInteger)tabID;

- (void)finishLoadDataForTabID:(NSInteger)tabID resultList:(NSArray *)list;
- (void)failLoadDataForTabID:(NSInteger)tabID;
- (void)finishDeleteData:(NSObject *)data ForTabID:(NSInteger)tabID;
//- (void)startToLoadNewDataForTabID:(NSInteger)tabID;
@end
