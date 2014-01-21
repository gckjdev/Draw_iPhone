//
//  SingleTabController.h
//  Draw
//
//  Created by Gamy on 14-1-21.
//
//

#import "CommonTabController.h"

@interface SingleTabController : CommonTabController

//should be override
- (void)serviceLoadDataWithOffset:(NSInteger)offset
                            limit:(NSInteger)limit
                         callback:(void (^)(NSInteger code, NSArray *list))callback;

- (NSString *)noDataTips;

@end
