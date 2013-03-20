//
//  ViewUserDetail.m
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import "ViewUserDetail.h"
#import "GameBasic.pb.h"

@implementation ViewUserDetail

- (void)dealloc
{
    [_pbUser release];
    [super dealloc];
}

- (NSString*)getUserId
{
    return nil;
}
- (PBGameUser*)queryUser
{
    return nil;
}
- (BOOL)canEdit
{
    return NO;
}
- (BOOL)needUpdate
{
    return YES;
}

- (id)initWithUserId:(NSString*)userId
              avatar:(NSString*)avatar
            nickName:(NSString*)nickName
{
    self = [super init];
    if (self) {
        PBGameUser_Builder* builder = [PBGameUser builder];
        [builder setUserId:userId];
        [builder setAvatar:avatar];
        [builder setNickName:nickName];
        self.pbUser = [builder build];
    }
    return self;
}

@end
