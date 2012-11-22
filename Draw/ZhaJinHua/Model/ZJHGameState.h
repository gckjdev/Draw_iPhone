//
//  ZJHGameState.h
//  Draw
//
//  Created by 王 小涛 on 12-10-23.
//
//
#import <Foundation/Foundation.h>
#import "ZJHUserPlayInfo.h"

@interface ZJHGameState : NSObject

@property (assign, nonatomic) int totalBet;
@property (assign, nonatomic) int singleBet;
@property (retain, nonatomic) NSString *winner;
@property (retain, nonatomic) NSMutableDictionary *usersInfo;

+ (ZJHGameState *)fromPBZJHGameState:(PBZJHGameState *)gameState;

- (ZJHUserPlayInfo *)userPlayInfo:(NSString *)userId;
- (int)betCountOfUser:(NSString *)userId;

@end
