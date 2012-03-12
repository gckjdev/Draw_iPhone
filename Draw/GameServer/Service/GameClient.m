//
//  GameClient.m
//  Draw
//
//  Created by  on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameClient.h"

@implementation GameClient

static GameClient* _defaultGameClient;

#pragma LifeCycle Management

- (void)dealloc
{
    [super dealloc];
}

+ (GameClient*)defaultInstance
{
    if (_defaultGameClient != nil)
        return _defaultGameClient;
    
    _defaultGameClient = [[GameClient alloc] init];
    return _defaultGameClient;
}

- (void)start:(NSString*)serverAddress port:(int)port
{
    [self connect:serverAddress port:port autoReconnect:YES];
}

#pragma CommonNetworkClientDelegate

- (void)didConnected
{
}

- (void)didBroken
{
    
}

@end
