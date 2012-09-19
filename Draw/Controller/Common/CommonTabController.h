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

@optional
- (NSString *)tabNoDataTipsforIndex:(NSInteger)index;

@end

@interface CommonTabController : PPTableViewController<CommonTabControllerDelegate>
{
    TableTabManager *_tabManager;
}


//used by the sub class.
- (NSMutableArray *)tabDataList;
- (TableTab *)currentTab;
- (void)startToLoadNewDataForTabID:(NSInteger)tabID;
- (void)finishLoadDataForTabID:(NSInteger)tabID resultList:(NSArray *)list;
- (void)failLoadDataForTabID:(NSInteger)tabID;

//- (void)startToLoadNewDataForTabID:(NSInteger)tabID;
@end
