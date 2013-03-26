//
//  SelfUserDetail.m
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import "SelfUserDetail.h"
#import "UserManager.h"

@implementation SelfUserDetail


- (id)init
{
    self = [super init];
    if (self) {
        self.relation = RelationTypeNo;
    }
    return self;
}

+ (id<UserDetailProtocol>)createDetail
{
    return [[[SelfUserDetail alloc] init] autorelease];
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

- (BOOL)canFollow
{
    return NO;
}
- (BOOL)canChat
{
    return NO;
}
- (BOOL)canDraw
{
    return NO;
}

- (BOOL)canBlack
{
    return NO;
}

- (BOOL)canSuperBlack
{
    return NO;
}

- (RelationType)relation
{
    return RelationTypeSelf;
}

- (void)setRelation:(RelationType)relation
{
    
}
@end
