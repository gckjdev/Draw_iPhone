//
//  DiceGameService.m
//  Draw
//
//  Created by  on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceGameService.h"
#import "PPDebug.h"
#import "DiceNetworkClient.h"
#import "DiceGameSession.h"
#import "DiceNotification.h"
#import "UserManager.h"
#import "ConfigManager.h"
#import "GameMessage.pb.h"

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
    [self.diceSession setCurrentPlayUserId:message.currentPlayUserId];
    [self postNotification:NOTIFICATION_NEXT_PLAYER_START message:message];
}

- (void)handleRollDiceBegin:(GameMessage*)message
{
    [self.diceSession reset];
    self.diceSession.isMeAByStander = NO;

    NSMutableArray* newUserList = [NSMutableArray array];
    
    for (PBGameUser* user in [[self session] userList]){
        PBGameUser* newUser = [[[PBGameUser builderWithPrototype:user] setIsPlaying:YES] build];
        [newUserList addObject:newUser];
    }
    
    [self.session.userList removeAllObjects];
    [self.session.userList addObjectsFromArray:newUserList];
    
    [self postNotification:NOTIFICATION_ROLL_DICE_BEGIN message:message];
    
}

- (void)handleRollDiceEnd:(GameMessage *)message
{
    for(PBUserDice *userDice in [[message rollDiceEndNotificationRequest] userDiceList])
    {
        [self.diceSession.userDiceList setObject:userDice.dicesList forKey:userDice.userId];
    }
    
    // Init lastCallDice when game begin.
    self.diceSession.lastCallDice = 1;
    self.diceSession.lastCallDiceCount = [[self session] playingUserCount] - 1;
    
    [self postNotification:NOTIFICATION_ROLL_DICE_END message:message];
}

- (void)handleCallDiceRequest:(GameMessage *)message
{
    self.diceSession.lastCallDiceUserId = message.userId;
    self.diceSession.lastCallDice = message.callDiceRequest.dice;
    self.diceSession.lastCallDiceCount = message.callDiceRequest.num;    
    if ([message.callDiceRequest hasWilds]) {
        self.diceSession.wilds = message.callDiceRequest.wilds;
    }
        
    [self postNotification:NOTIFICATION_CALL_DICE_REQUEST message:message];
}

- (void)handleCallDiceResponse:(GameMessage *)message
{
    [self postNotification:NOTIFICATION_CALL_DICE_RESPONSE message:message];
}

- (void)handleOpenDiceRequest:(GameMessage*)message
{
    self.diceSession.openDiceUserId = message.userId;
    self.diceSession.openType = message.openDiceRequest.openType;
    
    [self postNotification:NOTIFICATION_OPEN_DICE_REQUEST message:message];
}

- (void)handleOpenDiceResponse:(GameMessage*)message
{
    [self postNotification:NOTIFICATION_OPEN_DICE_RESPONSE message:message];
}

- (void)handleGameOverNotificationRequest:(GameMessage *)message
{
    NSMutableDictionary *resultDic= [NSMutableDictionary dictionary];
    for(PBUserResult *result in [[[message gameOverNotificationRequest] gameResult] userResultList])
    {
        [resultDic setObject:result forKey:result.userId];
    }
    self.diceSession.gameResult = resultDic;
    
    [self postNotification:NOTIFICATION_GAME_OVER_REQUEST message:message];
}

- (void)handleUseItemRequest:(GameMessage *)message
{
    [self postNotification:NOTIFICATION_USE_ITEM_REQUEST message:message];
}

- (void)handleUseItemResponse:(GameMessage *)message
{
    if (message.resultCode != 0) {
        [self changeDiceList:message.userId diceList:message.useItemResponse.dicesList];
        [self postNotification:NOTIFICATION_USE_ITEM_RESPONSE message:message];
    }
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
        case GameCommandTypeCallDiceRequest:
            [self handleCallDiceRequest:message];
            break;
        case GameCommandTypeCallDiceResponse:
            [self handleCallDiceResponse:message];
            break;
            
        case GameCommandTypeOpenDiceRequest: 
            [self handleOpenDiceRequest:message];
            break;
        case GameCommandTypeOpenDiceResponse: 
            [self handleOpenDiceResponse:message];
            break;
        case GameCommandTypeGameOverNotificationRequest:
            [self handleGameOverNotificationRequest:message];
            break;
            
        case GameCommandTypeUseItemRequest:
            [self handleUseItemRequest:message];
            break;
            
        case GameCommandTypeUseItemResponse:
            [self handleUseItemResponse:message];
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
    return [self.diceSession.userDiceList objectForKey:self.user.userId];
}

- (void)callDice:(int)dice count:(int)count wilds:(BOOL)wilds
{
    PPDebug(@"****************** ME CALL DICE: %d * %d %@ **********************", count, dice, wilds?@"斋":@"");
    
    // Update Model.
    self.diceSession.lastCallDiceUserId = self.user.userId;
    self.diceSession.lastCallDice = dice;
    self.diceSession.lastCallDiceCount = count;
    self.diceSession.wilds = wilds;
    
    // Send command.
    [(DiceNetworkClient *)_networkClient sendCallDiceRequest:self.lastCallUserId
                                                   sessionId:self.session.sessionId
                                                        dice:self.lastCallDice
                                                       count:self.lastCallDiceCount
                                                       wilds:wilds]; 
}

- (void)userItem:(int)itemId
{
    // Send command.
    [(DiceNetworkClient *)_networkClient sendUserItemRequest:self.user.userId 
                                                   sessionId:self.session.sessionId
                                                      itemId:itemId]; 
}

- (void)changeDiceList:(NSString *)userId diceList:(NSArray *)diceList
{
    if (![[self.diceSession.userDiceList allKeys] containsObject:userId]) {
        return;
    }
    
    [self.diceSession.userDiceList removeObjectForKey:userId];
    [self.diceSession.userDiceList setObject:diceList forKey:userId];
}


//- (void)callDice:(int)dice count:(int)count
//{
//    if (dice == 1) {
//        [self callDice:dice count:count wilds:YES];
//        return;
//    }
//    
//    // Update Model.
//    self.diceSession.lastCallDiceUserId = self.user.userId;
//    self.diceSession.lastCallDice = dice;
//    self.diceSession.lastCallDiceCount = count;
//    
//    // Send command.
//    [(DiceNetworkClient *)_networkClient sendCallDiceRequest:self.lastCallUserId
//                                                   sessionId:self.session.sessionId
//                                                        dice:self.lastCallDice
//                                                       count:self.lastCallDiceCount]; 
//}

- (NSString *)lastCallUserId
{
    return self.diceSession.lastCallDiceUserId;
}

- (int)lastCallDice
{
    return self.diceSession.lastCallDice;
}

- (int)lastCallDiceCount
{
    return self.diceSession.lastCallDiceCount;
}

- (NSString *)openDiceUserId
{
    return self.diceSession.openDiceUserId;
}

- (int)openType
{
    return self.diceSession.openType;
}

- (NSDictionary *)gameResult
{
    return self.diceSession.gameResult;
}



- (void)openDice
{
    PPDebug(@"****************** ME OPEN DICE **********************");
    
    int openType = [self.user.userId isEqualToString:self.diceSession.currentPlayUserId] ? 0 : 1;
    
    self.diceSession.openDiceUserId = self.user.userId;
    self.diceSession.openType = openType;
    
    [(DiceNetworkClient *)_networkClient sendOpenDiceRequest:self.user.userId
                                                   sessionId:self.session.sessionId
                                                    openType:openType]; 
}

@end
