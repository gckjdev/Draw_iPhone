//
//  GameClient.m
//  Draw
//
//  Created by  on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameClient.h"
#import "GameMessage.pb.h"

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



#pragma Methods

- (void)sendJoinGameRequest:(NSString*)userId
{
    
    JoinGameRequest_Builder *joinGameRequestBuilder = [[[JoinGameRequest_Builder alloc] init] autorelease];
    [joinGameRequestBuilder setUserId:userId];
    [joinGameRequestBuilder setGameId:@""];

    GameMessage_Builder *builder = [[[GameMessage_Builder alloc] init] autorelease];
    [builder setCommand:GameCommandTypeJoinGameRequest];
    [builder setMessageId:time(0)];
    [builder setJoinGameRequest:[joinGameRequestBuilder build]];
    
    GameMessage* gameMessage = [builder build];
    [self sendData:[gameMessage data]];
}

@end
