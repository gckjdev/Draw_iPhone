//
//  StatisticManager.h
//  Draw
//
//  Created by haodong on 12-9-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatisticManager : NSObject

@property (assign, nonatomic) long feedCount;
@property (assign, nonatomic) long commentCount;
@property (assign, nonatomic) long drawToMeCount;
@property (assign, nonatomic) long messageCount;;
@property (assign, nonatomic) long fanCount;
@property (assign, nonatomic) long roomCount;
@property (assign, nonatomic) long bbsActionCount;
@property (assign, nonatomic) long recoveryCount;
//@property (assign, nonatomic) long bulletinCount;
+ (StatisticManager *)defaultManager;

+ (NSString *)badgeStringFromIntValue:(int)badge;
+ (NSString *)badgeStringFromLongValue:(long)badge;
- (int)bulletinCount;

@end
