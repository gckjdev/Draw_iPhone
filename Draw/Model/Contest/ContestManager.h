//
//  ContestManager.h
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContestManager : NSObject

+ (ContestManager *)defaultManager;
- (NSArray *)parseContestList:(NSArray *)jsonArray;

@end
