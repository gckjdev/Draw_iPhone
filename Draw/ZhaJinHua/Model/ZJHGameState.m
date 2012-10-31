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

- (id)initWithPBZJHGameState:(PBZJHGameState *)gameState
{
    if (self = [super init]) {
        self.totalBet = gameState.totalBet;
        self.singleBet = gameState.singleBet;
        self.myTurnTimes = 0;
        self.usersInfo = [self usersPlayInfoFromPBZJHUserPlayInfoList:gameState.usersInfoList];
    }
    
    return self;
}

+ (ZJHGameState *)fromPBZJHGameState:(PBZJHGameState *)gameState
{
    return [[[ZJHGameState alloc] initWithPBZJHGameState:gameState] autorelease];
}

- (ZJHUserPlayInfo *)userPlayInfo:(NSString *)userId
{
    return [_usersInfo objectForKey:userId];
}

- (int)betCountOfUser:(NSString *)userId
{
    return [[self userPlayInfo:userId] betCount];
}

- (BOOL)user:(NSString *)userId canBeCompare:(BOOL)canBeCompare
{
    return [[self userPlayInfo:userId] canBeCompare];
}

- (BOOL)user:(NSString *)userId hasShield:(BOOL)hasShield
{
    return [[self userPlayInfo:userId] hasShield];
}


#pragma mark -  pravite methods

- (NSDictionary *)usersPlayInfoFromPBZJHUserPlayInfoList:(NSArray *)pbUserPlayInfoList
{
    NSMutableDictionary *usersInfo = [NSMutableDictionary dictionary];
    
    for (PBZJHUserPlayInfo *pbUserPlayInfo in pbUserPlayInfoList) {
        [usersInfo setValue:[ZJHUserPlayInfo fromPBZJHUserPlayInfo:pbUserPlayInfo] forKey:pbUserPlayInfo.userId];
    }
    
    return usersInfo;
}

@end
