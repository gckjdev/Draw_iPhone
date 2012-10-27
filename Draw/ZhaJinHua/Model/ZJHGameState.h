//
//  ZJHGameState.h
//  Draw
//
//  Created by 王 小涛 on 12-10-23.
//
//
#import <Foundation/Foundation.h>
#import "ZJHUserInfo.h"

@interface ZJHGameState : NSObject

@property (assign, nonatomic) int totalBet;
@property (assign, nonatomic) int singleBet;
@property (assign, nonatomic) int myTurnTimes;

- (ZJHGameState *)fromPBZJHGameState:(PBZJHGameState *)gameState;

- (ZJHUserInfo *)userInfo:(NSString *)userId;
- (int)betCountOfUser:(NSString *)userId;
- (BOOL)user:(NSString *)userId canBeCompare:(BOOL)canBeCompare;
- (BOOL)user:(NSString *)userId hasShield:(BOOL)hasShield;

@end
