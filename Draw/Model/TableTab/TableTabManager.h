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
}

- (id)initWithTabIDList:(NSArray *)tabIDs 
                  limit:(NSInteger)limit 
        currentTabIndex:(NSInteger)index;

- (NSArray *)tabList;
- (TableTab *)tabAtIndex:(NSInteger)index;
- (TableTab *)tabForID:(NSString *)tabID;

- (TableTab *)currentTab;
- (void)setCurrentTab:(TableTab *)tab;
@end
