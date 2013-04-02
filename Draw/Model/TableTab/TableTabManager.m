//
//  TableTabManager.m
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TableTabManager.h"


@implementation TableTabManager

- (void)dealloc
{
    PPRelease(_tabList);
    [super dealloc];
}

- (id)initWithTabIDList:(NSArray *)tabIDs
              titleList:(NSArray *)titleList 
         noDataDescList:(NSArray *)noDataList
                  limit:(NSInteger)limit 
        currentTabIndex:(NSInteger)index
{
    self = [super init];
    if(self){
        _tabList = [[NSMutableArray alloc] init];
        NSInteger i = 0;
        for (NSNumber *tabID in tabIDs) {
            NSString *desc = (i < [noDataList count] ? 
                              [noDataList objectAtIndex:i] : nil);
            NSString *title = (i < [titleList count] ? 
                              [noDataList objectAtIndex:i] : nil);

            TableTab *tab = [TableTab tabWithID:tabID.integerValue
                                          index:i++ 
                                          title:title
                                         offset:0 
                                          limit:limit 
                                     noDataDesc:desc
                                    hasMoreData:YES 
                                   isCurrentTab:NO];
            [_tabList addObject:tab];
        }
        i = (index < 0 || index >= i) ? 0 : index; 
        TableTab *tab = [_tabList objectAtIndex:i];
        [tab setCurrentTab:YES];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _tabList = [[NSMutableArray array] retain];
    }
    return self;
}
- (void)addTab:(TableTab *)tab
{
    [_tabList addObject:tab];
}

- (NSArray *)tabList
{
    return _tabList;
}
- (TableTab *)tabAtIndex:(NSInteger)index
{
    if(index < 0 || index >= [_tabList count])
    {
        return nil;
    }
    return [_tabList objectAtIndex:index];
}
- (TableTab *)tabForID:(NSInteger)tabID
{
    for (TableTab *tab in _tabList) {
        if (tab.tabID == tabID) {
            return tab;
        }
    }
    return nil;
}
- (TableTab *)currentTab
{
    for (TableTab *tab in _tabList) {
        if ([tab isCurrentTab]) {
            return tab;
        }
    }
    return nil;

}
- (void)setCurrentTab:(TableTab *)tab
{
    [self.currentTab setCurrentTab:NO];
    [tab setCurrentTab:YES];
}

- (NSMutableArray *)dataListForTabID:(NSInteger)tabID
{
    return [[self tabForID:tabID] dataList];
}
- (void)setDataList:(NSArray *)list ForTabID:(NSInteger)tabID
{
    TableTab *tab = [self tabForID:tabID];
    if ([list count] == 0) {
        [tab.dataList removeAllObjects];
    }else{
        tab.dataList = [NSMutableArray arrayWithArray:list];
    }
}
- (void)addDataList:(NSArray *)list toTab:(NSInteger)tabID
{
    TableTab *tab = [self tabForID:tabID];
    if ([list count] != 0) {
        [tab.dataList addObjectsFromArray:list];
    }
}

- (void)cleanData
{
    [_tabList removeAllObjects];
    PPDebug(@"<TableTabManager>: cleanData");
}

@end
