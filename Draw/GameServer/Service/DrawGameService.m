//
//  DrawGameService.m
//  Draw
//
//  Created by  on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawGameService.h"
#import "GameMessage.pb.h"
#import "PPDebug.h"

@implementation DrawGameService

static DrawGameService* _defaultService;

- (void)dealloc
{
    [_networkClient disconnect];
    [_networkClient release];
    [super dealloc];
}

+ (DrawGameService*)defaultService
{
    if (_defaultService != nil)
        return _defaultService;
    
    _defaultService = [[DrawGameService alloc] init];    
    return _defaultService;
}

- (id)init
{
    self = [super init];
    _networkClient = [[GameNetworkClient alloc] init];
    [_networkClient setDelegate:self];
    [_networkClient start:@"127.0.0.1" port:8080];
    return self;
}

- (void)handleData:(GameMessage*)message
{
    if ([message hasJoinGameResponse]){
        
        long sessionId = [[[message joinGameResponse] gameSession] sessionId];
        
        PPDebug(@"Join Game Response, session id = %qi", 
                [[[message joinGameResponse] gameSession] sessionId]);        
        
        [_networkClient sendStartGameRequest:@"User_ID1" sessionId:sessionId]; 
    }
}

#pragma CommonNetworkClientDelegate

- (void)didConnected
{
    [_networkClient sendJoinGameRequest:@"User_ID1" nickName:@"Benson"];
    [_networkClient sendJoinGameRequest:@"User_ID2" nickName:@"Gamy"];        
}

- (void)didBroken
{    
}


@end
