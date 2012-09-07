//
//  TableTab.h
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum{
    TableTabStatusUnload = 1,
    TableTabStatusLoading = 2,
    TableTabStatusLoaded = 3,
}TableTabStatus;

@interface TableTab : NSObject
{
    NSInteger _tabID;
    NSInteger _index;
    NSInteger _offset;
    NSInteger _limit;
    BOOL _hasMoreData;
    BOOL _currentTab;
    NSMutableArray *_dataList;
    TableTabStatus _status;
}
@property(nonatomic, assign)TableTabStatus status;
@property(nonatomic, assign)NSInteger tabID;
@property(nonatomic, assign)NSInteger index;
@property(nonatomic, assign)NSInteger offset;
@property(nonatomic, assign)NSInteger limit;
@property(nonatomic, assign)BOOL hasMoreData;
@property(nonatomic, assign, getter = isCurrentTab)BOOL currentTab;
@property(nonatomic, retain)NSMutableArray *dataList;


- (id)initWithTabID:(NSInteger)tabID
              index:(NSInteger)index
             offset:(NSInteger)offset
              limit:(NSInteger)limit 
        hasMoreData:(BOOL)hasMoreData 
       isCurrentTab:(BOOL)isCurrentTab;

+ (TableTab *)tabWithID:(NSInteger)tabID
              index:(NSInteger)index
             offset:(NSInteger)offset
              limit:(NSInteger)limit 
        hasMoreData:(BOOL)hasMoreData 
       isCurrentTab:(BOOL)isCurrentTab;

@end
