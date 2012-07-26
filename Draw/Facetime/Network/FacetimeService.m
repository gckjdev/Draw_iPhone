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

- (void)connectServer:(id<FacetimeServiceDelegate>)connectionDelegate
{
    _connectionDelegate = connectionDelegate;
    
//    [self clearKeepAliveTimer];
//    [self clearDisconnectTimer];
    [_networkClient start:_serverAddress port:_serverPort];    
    
}

- (PBGameUser*)createPBGameUser
{
    return nil;
}

- (void)sendFacetimeRequest
{
    PBGameUser* user = [self createPBGameUser];
    [_networkClient askFaceTime:user];
}

- (void)sendFacetimeRequestForMaleWithGender:(BOOL)gender
{
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
    
}



@end
