//
//  FacetimeService.m
//  Draw
//
//  Created by  on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FacetimeService.h"
#import "FacetimeNetworkClient.h"
#import "UserManager.h"
#import "GameMessage.pb.h"

@implementation FacetimeService
@synthesize connectionDelegate = _connectionDelegate;
@synthesize matchDelegate = _matchDelegate;
@synthesize serverAddress = _serverAddress;
@synthesize serverPort = _serverPort;

static FacetimeService *_defaultService;

+ (FacetimeService*)defaultService
{
    if (_defaultService == nil) {
        _defaultService = [[FacetimeService alloc] init];
    }
    return _defaultService;
}

- (void)dealloc
{
    [_networkClient release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _networkClient = [[FacetimeNetworkClient alloc] init];
        [_networkClient setDelegate:self];
    }
    return self;
}

- (BOOL)isConnected
{
    return [_networkClient isConnected];
}

- (void)connectServer:(id<FacetimeServiceDelegate>)connectionDelegate
{
    _connectionDelegate = connectionDelegate;
    
//    [self clearKeepAliveTimer];
//    [self clearDisconnectTimer];
    [_networkClient start:@"192.168.1.3" port:8191];    
    
}
- (void)disconnectServer
{
    [_networkClient disconnect];
}

- (PBGameUser*)createPBGameUser
{
    PBGameUser_Builder* builder = [[[PBGameUser_Builder alloc] init] autorelease];
    [builder setAvatar:[UserManager defaultManager].avatarURL];
    [builder setNickName:[UserManager defaultManager].nickName];
    [builder setLocation:[UserManager defaultManager].location];
    [builder setUserId:[UserManager defaultManager].userId];
    [builder setGender:[[UserManager defaultManager].gender isEqualToString:@"m"]];
    return [builder build];
}

- (void)sendFacetimeRequest:(id<FacetimeServiceDelegate>)aDelegate
{
    _matchDelegate = aDelegate;
    PBGameUser* user = [self createPBGameUser];
    [_networkClient askFaceTime:user];
}

- (void)sendFacetimeRequestWithGender:(BOOL)gender 
                                    delegate:(id<FacetimeServiceDelegate>)aDelegate
{
    _matchDelegate = aDelegate;
    PBGameUser* user = [self createPBGameUser];
    [_networkClient askFaceTime:user 
                         gender:gender];
}

#pragma mark - CommonNetworkClientDelegate
- (void)didConnected
{
    if (_connectionDelegate && [_connectionDelegate respondsToSelector:@selector(didConnected)]) {
        [_connectionDelegate didConnected];
    }
}

- (void)didBroken
{
    if (_connectionDelegate && [_connectionDelegate respondsToSelector:@selector(didBroken)]) {
        [_connectionDelegate didBroken];
    }
}

- (void)handleData:(GameMessage*)message
{
    if (_matchDelegate && [_matchDelegate respondsToSelector:@selector(didMatchUser:)]) {
        [_matchDelegate didMatchUser:[message.facetimeChatResponse userAtIndex:0]];
    }
    switch ([message command]) {
        
            
        default:
            break;
    }

}


@end
