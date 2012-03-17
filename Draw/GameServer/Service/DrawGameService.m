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
#import "GameSession.h"


@implementation DrawGameService

static DrawGameService* _defaultService;

@synthesize userId = _userId;
@synthesize nickName = _nickName;
@synthesize drawDelegate = _drawDelegate;
@synthesize roomDelegate = _roomDelegate;
@synthesize session = _session;

- (void)dealloc
{
    [_session release];
    [_nickName release];
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
    [_networkClient start:@"192.168.1.100" port:8080];
    srand(time(0));
//    self.userId = [NSString stringWithFormat:@"GamyDevice_%d",rand() % 100];
//    start = NO;
//    
//    if(start)
//    {
//        self.userId = @"GamyDevice";
//    }else{
//        self.userId = @"Simulator";
//    }

    
    return self;
}



#pragma Message Handle Methods

- (void)handleJoinGameResponse:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        
        // create game session
        PBGameSession* pbSession = [[message joinGameResponse] gameSession];
        self.session = [GameSession fromPBGameSession:pbSession userId:_userId];
        PPDebug(@"Create Session = %@", [self.session description]);
        
        if ([_roomDelegate respondsToSelector:@selector(didJoinGame:)]){
            [_roomDelegate didJoinGame:message];
        }
    });
}

- (void)joinGame
{
    [_networkClient sendJoinGameRequest:_userId nickName:_nickName];
}

- (void)startGame
{
    [_networkClient sendStartGameRequest:_userId sessionId:[_session sessionId]];             
}

- (void)handleStartGameResponse:(GameMessage*)message
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_roomDelegate respondsToSelector:@selector(didStartGame:)]){
            [_roomDelegate didStartGame:message];
        }
    });
}

- (void)handleGameStartNotification:(GameMessage*)message
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_roomDelegate respondsToSelector:@selector(didGameStart:)]){
            [_roomDelegate didGameStart:message];
        }
    });
}

- (void)handlNewUserJoinNotification:(GameMessage*)message
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_roomDelegate respondsToSelector:@selector(didNewUserJoinGame:)]){
            [_roomDelegate didNewUserJoinGame:message];
        }
    });
}

- (void)handlUserQuitJoinNotification:(GameMessage*)message
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_roomDelegate respondsToSelector:@selector(didUserQuitGame:)]){
            [_roomDelegate didUserQuitGame:message];
        }
    });
}


- (void)handleNewDrawDataNotification:(GameMessage*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{        
        NSLog(@"<Receive Draw Data>:");
        if ([_drawDelegate respondsToSelector:@selector(didReceiveDrawData:)]) {
            [_drawDelegate didReceiveDrawData:message];
        }
    });
}

- (void)handleCleanDraw:(GameMessage *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{        
        if ([_drawDelegate respondsToSelector:@selector(didReceiveRedrawResponse:)]) {
            [_drawDelegate didReceiveRedrawResponse:message];
        }
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
            [self handleGameStartNotification:message];
            break;
            
        case GameCommandTypeUserJoinNotificationRequest:
            [self handlNewUserJoinNotification:message];
            break;
            
        case GameCommandTypeUserQuitNotificationRequest:
            [self handlUserQuitJoinNotification:message];
            break;

        case GameCommandTypeNewDrawDataNotificationRequest:
            [self handleNewDrawDataNotification:message];
            break;
            
        case GameCommandTypeHostChangeNotificationRequest:
            break;

        case GameCommandTypeCleanDrawNotificationRequest:
            [self handleCleanDraw:message];

        default:
            break;
    }
    
    
}

#pragma CommonNetworkClientDelegate

- (void)didConnected
{
//    self.userId = ;
//    [_networkClient sendJoinGameRequest:self.userId nickName:@"Benson"];
//    self.userId = @"User_ID2";
//    [_networkClient sendJoinGameRequest:@"User_ID2" nickName:@"Gamy"];        
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
                              sessionId:[_session sessionId]
                              pointList:pointList
                                  color:color
                                  width:width];
}

- (void)cleanDraw
{
    [_networkClient sendCleanDraw:_userId
                        sessionId:[_session sessionId]];    
}

@end
