//
//  DiceGameService.m
//  Draw
//
//  Created by  on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceGameService.h"
#import "GameMessage.pb.h"
#import "PPDebug.h"
#import "DiceNetworkClient.h"
#import "DiceGameSession.h"
#import "DiceNotification.h"


#define DICE_GAME_ID    @"LiarDice"

@implementation DiceGameService

static DiceGameService* _defaultService;

+ (DiceGameService*)defaultService
{
    if (_defaultService == nil){
        _defaultService = [[DiceGameService alloc] init];
    }
    
    return _defaultService;
}

- (id)init
{
    self = [super init];
    
    _gameId = DICE_GAME_ID;
    _networkClient = [[DiceNetworkClient alloc] init];
    [_networkClient setDelegate:self]; 
    
    return self;
}

- (void)handleNextPlayerStartNotification:(GameMessage*)message
{
    // update game status and fire notification
}

- (void)handleRollDiceBegin:(GameMessage*)message
{
    [self postNotification:NOTIFICATION_ROLL_DICE_BEGIN message:message];
}

- (void)handleRollDiceEnd:(GameMessage *)message
{
    NSMutableDictionary *diceDic= [NSMutableDictionary dictionary];
    for(PBUserDice *userDice in [[message rollDiceEndNotificationRequest] userDiceList])
    {
        [diceDic setObject:userDice.dicesList forKey:userDice.userId];
    }
    
    [self diceSession].userDiceList = diceDic;
    
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:NOTIFICATION_ROLL_DICE_END
     object:self 
     userInfo:[CommonGameNetworkService messageToUserInfo:message]];     
}

- (void)handleCustomMessage:(GameMessage*)message
{
    switch ([message command]){
        case GameCommandTypeRollDiceBeginNotificationRequest:
            [self handleRollDiceBegin:message];
            break;

        case GameCommandTypeRollDiceEndNotificationRequest:
            // TODO
            [self handleRollDiceEnd:message];
            break;

        case GameCommandTypeNextPlayerStartNotificationRequest:
            [self handleNextPlayerStartNotification:message];
            break;
            
            
        default:
            PPDebug(@"<handleCustomMessage> unknown command=%d", [message command]);
            break;
    }
}

- (CommonGameSession*)createSession
{    
    return [[[DiceGameSession alloc] init] autorelease];
}

- (DiceGameSession*)diceSession
{
    return (DiceGameSession*)(self.session);
}

- (NSArray *)myDiceList
{
    return [[[self diceSession] userDiceList] objectForKey:self.user.userId];
}

@end
