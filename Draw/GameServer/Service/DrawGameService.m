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
#import "UIUtils.h"

@implementation DrawGameService

static DrawGameService* _defaultService;

@synthesize userId = _userId;

- (void)dealloc
{
    [_userId release];
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



#pragma Message Handle Methods

- (void)handleJoinGameResponse:(GameMessage*)message
{
    if ([message resultCode] != 0){
        // TODO, notify UI for result
        return;
    }
    
    if ([message hasJoinGameResponse]){
        
        _sessionId = [[[message joinGameResponse] gameSession] sessionId];
        
        PPDebug(@"Join Game Response, session id = %qi", 
                [[[message joinGameResponse] gameSession] sessionId]);        
        
        [_networkClient sendStartGameRequest:@"User_ID1" sessionId:_sessionId]; 
    }

}

- (void)handleStartGameResponse:(GameMessage*)message
{
    if ([message resultCode] != 0){
        // TODO, notify UI for result
        
    }
    
    // TODO, notify UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIUtils alert:[NSString stringWithFormat:@"Start Game At Session %qi", [message sessionId]]]; 
    });
}

- (void)handleNewDrawDataNotification:(GameMessage*)message
{
    if ([message hasNotification] == NO){
        // TODO error
        return;
    }
    
    // display this in UI 
    dispatch_async(dispatch_get_main_queue(), ^{        
        // TODO
        [[message notification] pointsList];
    });
}

- (void)handleData:(GameMessage*)message
{
    switch ([message command]) {
        case GameCommandTypeJoinGameResponse:   
            [self handleJoinGameResponse:message];
            break;
            
        case GameCommandTypeStartGameResponse:   
            [self handleStartGameResponse:message];
            break;

        case GameCommandTypeGameStartNotificationRequest:
            break;
            
        case GameCommandTypeUserJoinNotificationRequest:
            break;
            
        case GameCommandTypeNewDrawDataNotificationRequest:
            [self handleNewDrawDataNotification:message];
            break;

        default:
            break;
    }
    
    
}

#pragma CommonNetworkClientDelegate

- (void)didConnected
{
    self.userId = @"User_ID1";
    
    [_networkClient sendJoinGameRequest:@"User_ID1" nickName:@"Benson"];
    [_networkClient sendJoinGameRequest:@"User_ID2" nickName:@"Gamy"];        
}

- (void)didBroken
{    
}


#pragma Methods for External

- (void)sendDrawDataRequestWithPointList:(NSArray*)pointList 
                                   color:(int)color
                                   width:(float)width
{
    [_networkClient sendDrawDataRequest:_userId
                              sessionId:_sessionId
                              pointList:pointList
                                  color:color
                                  width:width];
}


@end
