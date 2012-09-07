//
//  TableTab.m
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TableTab.h"

@implementation TableTab

@synthesize status = _status;
@synthesize tabID = _tabID;
@synthesize index = _index;
@synthesize offset = _offset;
@synthesize limit= _limit;
@synthesize hasMoreData = _hasMoreData;
@synthesize currentTab = _currentTab;
@synthesize dataList = _dataList;
@synthesize noDataDesc = _noDataDesc;

- (void)dealloc
{
    PPRelease(_dataList);
    PPRelease(_noDataDesc);
    [super dealloc];
}

- (id)initWithTabID:(NSInteger)tabID
              index:(NSInteger)index
             offset:(NSInteger)offset
              limit:(NSInteger)limit 
         noDataDesc:(NSString *)noDataDesc
        hasMoreData:(BOOL)hasMoreData 
       isCurrentTab:(BOOL)isCurrentTab
{
    self = [super init];
    if (self) {
        self.tabID = tabID;
        self.index = index;
        self.offset = offset;
        self.limit = limit;
        self.hasMoreData = hasMoreData;
        self.currentTab = isCurrentTab;
        self.noDataDesc = noDataDesc;
        self.dataList = [NSMutableArray array];
        self.status = TableTabStatusUnload;
    }
    return self;
}

+ (TableTab *)tabWithID:(NSInteger)tabID
                  index:(NSInteger)index
                 offset:(NSInteger)offset
                  limit:(NSInteger)limit 
             noDataDesc:(NSString *)noDataDesc
            hasMoreData:(BOOL)hasMoreData 
           isCurrentTab:(BOOL)isCurrentTab
{
    return [[[TableTab alloc] initWithTabID:tabID 
                                      index:index 
                                     offset:offset 
                                      limit:limit 
                                 noDataDesc:noDataDesc
                                hasMoreData:hasMoreData 
                               isCurrentTab:isCurrentTab] autorelease];
}

@end
