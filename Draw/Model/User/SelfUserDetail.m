//
//  SelfUserDetail.m
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import "SelfUserDetail.h"
#import "SynthesizeSingleton.h"
#import "UserManager.h"

@implementation SelfUserDetail

SYNTHESIZE_SINGLETON_FOR_CLASS(SelfUserDetail)

+ (id<UserDetailProtocol>)createDetail
{
    return [SelfUserDetail sharedSelfUserDetail];
}

- (NSString*)getUserId
{
    return [[UserManager defaultManager] userId];
}
- (PBGameUser*)queryUser
{
    return [UserManager defaultManager].pbUser;
}
- (BOOL)canEdit
{
    return YES;
}

- (BOOL)needUpdate
{
    return NO;
}

@end
