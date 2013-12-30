//
//  CommonTabController.h
//  Draw
//
//  Created by  on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPTableViewController.h"
#import "TableTabManager.h"
#import "CommonViewConstants.h"
#import "CommonTitleView.h"

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
- (UIColor *)tabButtonTitleColorForNormal:(NSInteger)index;
- (UIColor *)tabButtonTitleColorForSelected:(NSInteger)index;

@end

typedef enum{
 
    PullRefreshTypeNone = 0,
    PullRefreshTypeHeader = 1,
    PullRefreshTypeFooter = 0x1 << 1,
    PullRefreshTypeBoth = PullRefreshTypeHeader | PullRefreshTypeFooter,

}PullRefreshType;

@interface CommonTabController : PPTableViewController<CommonTabControllerDelegate, UIGestureRecognizerDelegate>
{
    TableTabManager *_tabManager;
    NSInteger _defaultTabIndex;
}




//common xib and action
@property(nonatomic, retain)IBOutlet CommonTitleView *titleView;
@property(nonatomic, retain)IBOutlet UILabel *titleLabel;
@property(nonatomic, retain)IBOutlet UILabel *noDataTipLabl;
@property(nonatomic, assign)PullRefreshType pullRefreshType;
@property(nonatomic, assign, getter = isAutoResizeTabButton)BOOL autoResizeTabButton;
//@property(nonatomic, assign)BOOL cleanFrontDataWhenViewDisappear;


- (IBAction)clickBackButton:(id)sender;
- (IBAction)clickTabButton:(id)sender;
- (IBAction)clickRefreshButton:(id)sender;



- (void)clickTab:(NSInteger)tabID;
- (id)initWithDefaultTabIndex:(NSInteger)index;

- (void)setDefaultTabIndex:(int)tabIndex;

+ (void)enterControllerWithIndex:(NSInteger)index
                  fromController:(UIViewController *)controller 
                        animated:(BOOL)animated;

- (void)initTabButtons;
- (BOOL)isCurrentTabLoading;

//used by the sub class.
- (NSMutableArray *)tabDataList;
- (TableTab *)currentTab;
- (NSInteger)currentTabID;
- (UIButton *)currentTabButton;
- (UIButton *)tabButtonWithTabID:(NSInteger)tabID;
- (void)startToLoadDataForTabID:(NSInteger)tabID;
- (void)setBadge:(NSInteger)badge onTab:(NSInteger)tabID;

- (void)finishLoadDataForTabID:(NSInteger)tabID resultList:(NSArray *)list;
- (void)failLoadDataForTabID:(NSInteger)tabID;
- (void)finishDeleteData:(NSObject *)data ForTabID:(NSInteger)tabID;
- (void)cleanFrontData;

- (void)setTab:(NSInteger)tabID titleNumber:(NSInteger)number;

- (BOOL)noData;

//- (void)startToLoadNewDataForTabID:(NSInteger)tabID;
@end
