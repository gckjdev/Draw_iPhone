//
//  TableTab.m
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TableTab.h"

@implementation TableTab
@synthesize tabID = _tabID;
@synthesize index = _index;
@synthesize offset = _offset;
@synthesize limit= _limit;
@synthesize hasMoreData = _hasMoreData;
@synthesize currentTab = _currentTab;

- (void)dealloc
{
    PPRelease(_tabID);
    [super dealloc];
}

- (id)initWithTabID:(NSString *)tabID
              index:(NSInteger)index
             offset:(NSInteger)offset
              limit:(NSInteger)limit 
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
    }
    return self;
}

+ (TableTab *)tabWithID:(NSString *)tabID
                  index:(NSInteger)index
                 offset:(NSInteger)offset
                  limit:(NSInteger)limit 
            hasMoreData:(BOOL)hasMoreData 
           isCurrentTab:(BOOL)isCurrentTab
{
    return [[[TableTab alloc] initWithTabID:tabID 
                                      index:index 
                                     offset:offset 
                                      limit:limit 
                                hasMoreData:hasMoreData 
                               isCurrentTab:isCurrentTab] autorelease];
}

@end
