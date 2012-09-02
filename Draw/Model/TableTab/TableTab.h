//
//  TableTab.h
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableTab : NSObject
{
    NSString *_tabID;
    NSInteger _index;
    NSInteger _offset;
    NSInteger _limit;
    BOOL _hasMoreData;
    BOOL _currentTab;
}

@property(nonatomic, retain)NSString *tabID;
@property(nonatomic, assign)NSInteger index;
@property(nonatomic, assign)NSInteger offset;
@property(nonatomic, assign)NSInteger limit;
@property(nonatomic, assign)BOOL hasMoreData;
@property(nonatomic, assign, getter = isCurrentTab)BOOL currentTab;

- (id)initWithTabID:(NSString *)tabID
              index:(NSInteger)index
             offset:(NSInteger)offset
              limit:(NSInteger)limit 
        hasMoreData:(BOOL)hasMoreData 
       isCurrentTab:(BOOL)isCurrentTab;

+ (TableTab *)tabWithID:(NSString *)tabID
              index:(NSInteger)index
             offset:(NSInteger)offset
              limit:(NSInteger)limit 
        hasMoreData:(BOOL)hasMoreData 
       isCurrentTab:(BOOL)isCurrentTab;

@end
