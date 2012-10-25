//
//  ZJHGameSession.h
//  Draw
//
//  Created by 王 小涛 on 12-10-23.
//
//

#import "CommonGameSession.h"
#import "ZJHUserInfo.h"

@interface ZJHGameSession : CommonGameSession

@property (assign, nonatomic) int totalBet;
@property (assign, nonatomic) int singleBet;
@property (assign, nonatomic) int myTurnTimes;

- (ZJHUserInfo *)userInfo:(NSString *)userId;

- (int)betCountOfUser:(NSString *)userId;

- (BOOL)user:(NSString *)userId canBeCompare:(BOOL)canBeCompare;
- (BOOL)user:(NSString *)userId hasShield:(BOOL)hasShield;

@end
