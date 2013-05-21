//
//  TableTabManager.h
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableTab.h"
//@class TableTab;
@interface TableTabManager : NSObject
{
    NSMutableArray *_tabList;
    NSMutableArray *_bgList;
    BOOL _hasCleanFrontData;
}

- (id)initWithTabIDList:(NSArray *)tabIDs
              titleList:(NSArray *)titleList 
         noDataDescList:(NSArray *)noDataList
                  limit:(NSInteger)limit 
        currentTabIndex:(NSInteger)index;


- (id)init;
- (void)addTab:(TableTab *)tab;
- (NSArray *)tabList;
- (TableTab *)tabAtIndex:(NSInteger)index;
- (TableTab *)tabForID:(NSInteger)tabID;

- (TableTab *)currentTab;
- (void)setCurrentTab:(TableTab *)tab;

- (NSMutableArray *)dataListForTabID:(NSInteger)tabID;
- (void)setDataList:(NSArray *)list ForTabID:(NSInteger)tabID;
- (void)addDataList:(NSArray *)list toTab:(NSInteger)tabID;
- (void)cleanData;

- (void)reset;


- (void)cleanFrontData;
- (void)resetFrontData;
- (BOOL)needResetFrontData;

@end
