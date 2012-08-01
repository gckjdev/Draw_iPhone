//
//  FacetimeNetworkClient.m
//  Draw
//
//  Created by  on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FacetimeNetworkClient.h"
#import "GameMessage.pb.h"
#import "PPDebug.h"

@implementation FacetimeNetworkClient

static FacetimeNetworkClient* _defaultGameNetworkClient;

#pragma LifeCycle Management

- (void)dealloc
{
    [super dealloc];
}

+ (FacetimeNetworkClient*)defaultInstance
{
    if (_defaultGameNetworkClient != nil)
        return _defaultGameNetworkClient;
    
    _defaultGameNetworkClient = [[FacetimeNetworkClient alloc] init];
    return _defaultGameNetworkClient;
}

- (void)start:(NSString*)serverAddress port:(int)port
{
    [self connect:serverAddress port:port autoReconnect:NO];
}

#pragma Data Handler
- (void)handleData:(NSData*)data
{
    @try
    {
        GameMessage *message = [GameMessage parseFromData:data];
        PPDebug(@"RECV MESSAGE, COMMAND = %d, RESULT = %d", [message command], [message resultCode]);
        if ([self.delegate respondsToSelector:@selector(handleData:)]){
            [self.delegate performSelector:@selector(handleData:) withObject:message];
        }
    }
    @catch(NSException* ex)
    {
        PPDebug(@"catch exception while handleData, exception = %@", [ex debugDescription]);
    }
}

#pragma mark -

- (void)askFaceTime:(PBGameUser*)user
{
    FacetimeChatRequest_Builder *requestBuilder = [[[FacetimeChatRequest_Builder alloc] init] autorelease];
    [requestBuilder setUser:user];
   // [requestBuilder setChatGender:YES];// todo set gender
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeFacetimeChatRequest];
    [messageBuilder setMessageId:2012];
    [messageBuilder setFacetimeChatRequest:[requestBuilder build]];
    
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];
}

- (void)askFaceTime:(PBGameUser*)user 
             gender:(BOOL)gender
{
    FacetimeChatRequest_Builder *requestBuilder = [[[FacetimeChatRequest_Builder alloc] init] autorelease];
    [requestBuilder setUser:user];
     [requestBuilder setChatGender:gender];
    
    GameMessage_Builder *messageBuilder = [[[GameMessage_Builder alloc] init] autorelease];
    [messageBuilder setCommand:GameCommandTypeFacetimeChatRequest];
    [messageBuilder setMessageId:20120726];
    [messageBuilder setFacetimeChatRequest:[requestBuilder build]];
    
    GameMessage* gameMessage = [messageBuilder build];
    [self sendData:[gameMessage data]];
}

@end
