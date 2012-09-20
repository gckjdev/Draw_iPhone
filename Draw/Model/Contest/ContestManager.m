//
//  ContestManager.m
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ContestManager.h"
#import "Contest.h"

static ContestManager *_staticContestManager;
@implementation ContestManager

+ (ContestManager *)defaultManager
{
    if (_staticContestManager == nil) {
        _staticContestManager = [[ContestManager alloc] init];
    }
    return _staticContestManager;
}

- (NSArray *)parseContestList:(NSArray *)jsonArray
{
    if ([jsonArray count] != 0) {
        NSMutableArray *list = [NSMutableArray array];
        for (NSDictionary *dict in jsonArray) {
            if ([dict isKindOfClass:[NSDictionary class]]) {
                Contest *contest = [Contest contestWithDict:dict];
                [list addObject:contest];                
            }
        }        
        return list;
    }
    return nil;
}
@end
