//
//  ZJHGameState.m
//  Draw
//
//  Created by 王 小涛 on 12-10-23.
//
//

#import "ZJHGameState.h"

@interface ZJHGameState ()

@property (readwrite, retain, nonatomic) NSDictionary *usersInfo;

@end


@implementation ZJHGameState

//@synthesize usersInfo = _usersInfo;
//@synthesize myTurnTimes = _myTurnTimes;

#pragma mark - life cycle
- (void)dealloc
{
    [_usersInfo release];
    [super dealloc];
}

- (ZJHGameState *)fromPBZJHGameState:(PBZJHGameState *)gameState
{
    self.totalBet = gameState.totalBet;
    self.singleBet = gameState.singleBet;
    self.myTurnTimes = 0;
    self.usersInfo = [self usersInfoFromPBZJHUserInfoList:gameState.usersInfoList];
    
    return self;
}

- (ZJHUserInfo *)userInfo:(NSString *)userId
{
    return [_usersInfo objectForKey:userId];
}

- (int)betCountOfUser:(NSString *)userId
{
    return [[self userInfo:userId] betCount];
}

- (BOOL)user:(NSString *)userId canBeCompare:(BOOL)canBeCompare
{
    return [[self userInfo:userId] canBeCompare];
}

- (BOOL)user:(NSString *)userId hasShield:(BOOL)hasShield
{
    return [[self userInfo:userId] hasShield];
}


#pragma mark -  pravite methods

- (NSDictionary *)usersInfoFromPBZJHUserInfoList:(NSArray *)pbUserInfoList
{
    NSMutableDictionary *usersInfo = [NSMutableDictionary dictionary];
    ZJHUserInfo *userInfo = [[[ZJHUserInfo alloc] init] autorelease];
    
    for (PBZJHUserInfo *pbUserInfo in pbUserInfoList) {
        [usersInfo setValue:[userInfo fromPBZJHUserInfo:pbUserInfo] forKey:pbUserInfo.userId];
    }
    
    return usersInfo;
}

@end
