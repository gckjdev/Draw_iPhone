//
//  ZJHGameSession.m
//  Draw
//
//  Created by 王 小涛 on 12-10-23.
//
//

#import "ZJHGameSession.h"

@interface ZJHGameSession ()

@property (readwrite, retain, nonatomic) NSDictionary *usersInfo;

@end


@implementation ZJHGameSession

@synthesize usersInfo = _usersInfo;
@synthesize myTurnTimes = _myTurnTimes;

#pragma mark - life cycle
- (void)dealloc
{
    [_usersInfo release];
    [super dealloc];
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

@end
