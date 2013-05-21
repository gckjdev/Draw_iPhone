//
//  ContestManager.h
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContestManager : NSObject {
    NSMutableSet* _oldContestIdList;
}

+ (ContestManager *)defaultManager;
- (NSArray *)parseContestList:(NSArray *)jsonArray;

- (int)calNewContestCount:(NSArray*)contestList;
- (void)updateHasReadContestList:(NSArray*)contestList;

@end
