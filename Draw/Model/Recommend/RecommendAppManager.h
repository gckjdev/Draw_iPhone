//
//  RecommendAppManager.h
//  FootballScore
//
//  Created by Orange on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecommendAppManager : NSObject

@property (nonatomic, retain) NSMutableArray* appList;

+ (RecommendAppManager*)defaultManager;

@end
