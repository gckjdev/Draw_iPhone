//
//  TableTabManager.m
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TableTabManager.h"


@implementation TableTabManager

- (id)initWithTabIDList:(NSArray *)tabIDs 
                  limit:(NSInteger)limit 
        currentTabIndex:(NSInteger)index
{
    self = [super init];
    if(self){
        _tabList = [[NSMutableArray alloc] init];
        NSInteger i = 0;
        for (NSString *tabID in tabIDs) {
            TableTab *tab = [TableTab tabWithID:tabID 
                                          index:i++ 
                                         offset:0 
                                          limit:limit
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
- (TableTab *)tabForID:(NSString *)tabID
{
    for (TableTab *tab in _tabList) {
        if ([tab.tabID isEqualToString:tabID]) {
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

@end
