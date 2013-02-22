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
#import "ItemType.h"
#import "GCServer.h"



@implementation DiceGameService

static DiceGameService* _defaultService;

@synthesize ruleType = _ruleType;

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
    _ruleType = DiceGameRuleTypeRuleNormal;
    return self;
}

//- (void)handleNextPlayerStartNotification:(GameMessage*)message
//{
//    // update game status and fire notification
//    [self.diceSession setCurrentPlayUserId:message.currentPlayUserId];
//    [self postNotification:NOTIFICATION_NEXT_PLAYER_START message:message];
//}

- (void)handleRollDiceBegin:(GameMessage*)message
{
    [self.diceSession reset];
    self.diceSession.isMeAByStander = NO;
    self.diceSession.status = GameStatusPlaying;

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
    self.diceSession.lastCallDice = 2;
    self.diceSession.lastCallDiceCount = [[self session] playingUserCount];
    
    [self postNotification:NOTIFICATION_ROLL_DICE_END message:message];
}

- (void)updateCallDiceModel:(GameMessage*)message
{
    // Update Model.
    self.diceSession.lastCallDiceUserId = message.userId;
    self.diceSession.lastCallDice = message.callDiceRequest.dice;
    self.diceSession.lastCallDiceCount = message.callDiceRequest.num;
    self.diceSession.wilds = message.callDiceRequest.wilds;
    self.diceSession.callCount ++;
}

- (void)handleCallDiceRequest:(GameMessage *)message
{
    if (message.resultCode == 0) {
        [self updateCallDiceModel:message];
        [self postNotification:NOTIFICATION_CALL_DICE_REQUEST message:message];
    }
}

- (void)handleCallDiceResponse:(GameMessage *)message
{
//    BOOL bol1 = (message.resultCode == 0);
//    BOOL bol2 = ([message.userId isEqualToString:[self userId]]);
    if (message.resultCode == 0 && [message.userId isEqualToString:[self userId]]) {
        [self updateCallDiceModel:message];
        
        [self postNotification:NOTIFICATION_CALL_DICE_RESPONSE message:message];
    }
}

- (void)updateOpenDiceModel:(GameMessage*)message
{
    // Update open dice model
    self.diceSession.openDiceUserId = message.userId;
    self.diceSession.openType = message.openDiceRequest.openType;
}

- (void)handleOpenDiceRequest:(GameMessage*)message
{
    if (message.resultCode == 0) {
        // Update open dice model
        [self updateOpenDiceModel:message];
        [self postNotification:NOTIFICATION_OPEN_DICE_REQUEST message:message];
    }
}

- (void)handleOpenDiceResponse:(GameMessage*)message
{
    if (message.resultCode == 0 && [message.userId isEqualToString:[self userId]]) {
        // Update open dice model
        [self updateOpenDiceModel:message];
        [self postNotification:NOTIFICATION_OPEN_DICE_RESPONSE message:message];
    }
}

- (void)handleMoreOnGameOverNotificationRequest:(GameMessage *)message
{
    NSMutableDictionary *resultDic= [NSMutableDictionary dictionary];
    for(PBUserResult *result in [[[message gameOverNotificationRequest] gameResult] userResultList])
    {
        [resultDic setObject:result forKey:result.userId];
    }
    self.diceSession.gameResult = resultDic;
    
    NSMutableDictionary *finalDic = [NSMutableDictionary dictionary];
    for (PBDiceFinalCount *finalCount in [[[message gameOverNotificationRequest] gameResult] finalCountList]) {
        [finalDic setObject:finalCount forKey:finalCount.userId];
    }
    self.diceSession.finalCount = finalDic;
    
    [self postNotification:NOTIFICATION_GAME_OVER_REQUEST message:message];
}

- (void)handleUserDiceNotification:(GameMessage *)message
{
    if (message.userDiceNotification.cleanAll) {
        // clean all exist data
        [self.diceSession.userDiceList removeAllObjects];
        for(PBUserDice *userDice in message.userDiceNotification.userDiceList)
        {
            [self.diceSession.userDiceList setObject:userDice.dicesList forKey:userDice.userId];
        }
    }
    else{
        // update exist data
        for (PBUserDice *userDice in message.userDiceNotification.userDiceList) {
            [self changeDiceList:userDice.userId diceList:userDice.dicesList];
        }
    }
    
    if ([message.userDiceNotification hasIsWild]){
        [self.diceSession setWilds:message.userDiceNotification.isWild];
    }
  
    // TODO handle dice notification to update wild display?
    [self postNotification:NOTIFICATION_USER_DICE message:message];
}

- (void)handleUseItemResponse:(GameMessage *)message
{
    if (message.resultCode == 0) {
        if (message.useItemResponse.itemId == ItemTypeRollAgain) {
            [self changeDiceList:message.userId diceList:message.useItemResponse.dicesList];
        }
        [self postNotification:NOTIFICATION_USE_ITEM_RESPONSE message:message];
    }
}

- (void)handleUseItemRequest:(GameMessage *)message
{
    [self postNotification:NOTIFICATION_USE_ITEM_REQUEST message:message];
}

- (void)handleBetDiceRequest:(GameMessage *)message
{
    [self postNotification:NOTIFICATION_BET_DICE_REQUEST message:message];
}

- (void)handleBetDiceResponse:(GameMessage *)message
{
    if (message.resultCode == 0) {
        [self postNotification:NOTIFICATION_BET_DICE_RESPONSE message:message];
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
            
//        case GameCommandTypeNextPlayerStartNotificationRequest:
//            [self handleNextPlayerStartNotification:message];
//            break;
            
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
            
//        case GameCommandTypeGameOverNotificationRequest:
//            [self handleGameOverNotificationRequest:message];
//            break;
            
        case GameCommandTypeUserDiceNotification:
            [self handleUserDiceNotification:message];
            break;
            
        case GameCommandTypeUseItemResponse:
            [self handleUseItemResponse:message];
            break;
            
        case GameCommandTypeUseItemRequest:
            [self handleUseItemRequest:message];
            break;
            
        case GameCommandTypeBetDiceRequest:
            [self handleBetDiceRequest:message];
            break;
            
        case GameCommandTypeBetDiceResponse:
            [self handleBetDiceResponse:message];
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
    return [self.diceSession.userDiceList objectForKey:[self userId]];
}

- (void)callDice:(int)dice count:(int)count wilds:(BOOL)wilds
{
    PPDebug(@"****************** ME CALL DICE: %d * %d %@ **********************", count, dice, wilds?@"斋":@"");
//
//    // Update Model.
//    self.diceSession.lastCallDiceUserId = [self userId];
//    self.diceSession.lastCallDice = dice;
//    self.diceSession.lastCallDiceCount = count;
//    self.diceSession.wilds = wilds;
//    
//    // Send command.
//    [(DiceNetworkClient *)_networkClient sendCallDiceRequest:self.lastCallUserId
//                                                   sessionId:self.session.sessionId
//                                                        dice:self.lastCallDice
//                                                       count:self.lastCallDiceCount
//                                                       wilds:wilds];
    
    // Send command.
    [(DiceNetworkClient *)_networkClient sendCallDiceRequest:[self userId]
                                                   sessionId:self.session.sessionId
                                                        dice:dice
                                                       count:count
                                                       wilds:wilds];
}

- (void)userItem:(int)itemId
{
    // Send command.
    [(DiceNetworkClient *)_networkClient sendUserItemRequest:[self userId] 
                                                   sessionId:self.session.sessionId
                                                      itemId:itemId]; 
    
    [self.diceSession increaseItemUseCount:itemId];
}

- (void)userTimeItem:(int)itemId 
                time:(int)time
{
    // Send command.
    [(DiceNetworkClient *)_networkClient sendUserItemRequest:[self userId] 
                                                   sessionId:self.session.sessionId
                                                      itemId:itemId 
                                                  extendTime:time]; 
    
    [self.diceSession increaseItemUseCount:itemId];
}

- (void)changeDiceList:(NSString *)userId diceList:(NSArray *)diceList
{
    if (![[self.diceSession.userDiceList allKeys] containsObject:userId]) {
        return;
    }
    
    [self.diceSession.userDiceList removeObjectForKey:userId];
    [self.diceSession.userDiceList setObject:diceList forKey:userId];
}

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

- (OpenType)openType
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
    
    OpenType openType = [[self userId] isEqualToString:self.diceSession.currentPlayUserId] ? OpenTypeNormal : OpenTypeScramble;
    
//    self.diceSession.openDiceUserId = [self userId];
//    self.diceSession.openType = openType;
    
    [(DiceNetworkClient *)_networkClient sendOpenDiceRequest:[self userId]
                                                   sessionId:self.session.sessionId
                                                    openType:openType
                                                    multiple:1]; 
}

- (NSString *)getServerListString
{
    switch (_ruleType) {
        case DiceGameRuleTypeRuleNormal:
            return [ConfigManager getDiceServerListStringWithNormal];
            break;
            
        case DiceGameRuleTypeRuleHigh:
            return [ConfigManager getDiceServerListStringWithHightRule];
            break;
            
        case DiceGameRuleTypeRuleSuperHigh:
            return [ConfigManager getDiceServerListStringWithSuperHightRule];
            break;
            
        default:
            break;
    }
}

- (int)ante
{
    int ante = 100;
    if (self.diceSession.ruleType == DiceGameRuleTypeRuleSuperHigh) {
        ante = 50 * (self.diceSession.callCount + 1);
    }
    
    return ante;
}

- (int)maxCallCount
{
    if (self.diceSession.ruleType == DiceGameRuleTypeRuleNormal) {
        return self.session.playingUserCount * 5;
    }else {
        return self.session.playingUserCount * 7;
    }
}

- (int)betAnte
{
    int betAnte;
    switch (_ruleType) {
        case DiceGameRuleTypeRuleNormal:
            betAnte = [ConfigManager getBetAnteWithNormalRule];
            break;
            
        case DiceGameRuleTypeRuleHigh:
            betAnte = [ConfigManager getBetAnteWithHighRule];
            break;
            
        case DiceGameRuleTypeRuleSuperHigh:
            betAnte = [ConfigManager getBetAnteWithSuperHighRule];
            break;
            
        default:
            break;
    }
    
    return betAnte;
}

- (void)betOpenUserWin:(BOOL)win
{
    int option;
    if (win) {
        option = 0;
    }else {
        option = 1;
    }
    
    self.diceSession.betWin = win;
    
    CGFloat odds = [self oddsForWin:win];
    
    [(DiceNetworkClient *)_networkClient sendBetDiceRequest:[self userId]
                                                  sessionId:self.session.sessionId
                                                     option:option
                                                       ante:[self betAnte]
                                                       odds:odds]; 

}

/***********************  Odds cal **************************/

#define NUM_ODDS 90


CGFloat WinAndNotWildOdds[] = {
    /********** Win & Not wild  ***********/
    /***** For 3  players(15 dices) *****/
	100,     50,      25,      12.5,    6.25,   
    3,       1.5,     0.75,    0.32,    0.15,   
    0.07,    0.03,   0.02,     0.02,     0.01,   
    /***** For 4  players(20 dices) *****/
	100,     75,      50,      25,      12.5,   
    6.25,    3.0,     1.5,     1.2,     1.1,   
    1.0,     0.8,     0.4,     0.2,     0.12,   
    0.07,    0.03,   0.02,     0.02,     0.01,   
    /***** For 5  players(25 dices) *****/
	100,     80,      55,      25.0,    12.5,   
    6.25,    3.0,     2.0,     1.8,     1.6,   
    1.4,     1.2,     1.0,     0.8,     0.6,   
    0.5,     0.4,     0.3,     0.2,     0.12,   
    0.07,    0.03,    0.02,    0.02,    0.01,   
    /***** For 6  players(30 dices) *****/
	100,     80,      60,      40,      20,   
    12.5,    6.25,    3.0,     2.5,     2.2,   
    2.0,     1.6,     1.5,     1.2,     1.0,   
    0.9,     0.8,     0.7,     0.6,     0.5,   
    0.4,     0.3,     0.2,     0.15,     0.12,   
    0.07,    0.03,    0.02,    0.02,    0.01,   
};

CGFloat LoseAndNotWildOdds[] = {
    /********** Lose & Not wild  ***********/
    /***** For 3  players(15 dices) *****/
    0.01,   0.02,   0.04,   0.08,   0.16,   
    0.33,   0.67,   1.33,   3.32,   6.67,   
    14.3,   33.3,   50.0,   75.0,   100,   
    
    /***** For 4  players(20 dices) *****/
 	0.01,   0.02,   0.02,   0.04,   0.08,   
    0.16,   0.33,   0.67,   0.83,   0.91,   
    1.00,   1.25,   2.50,   5.00,   8.33,   
    14.3,   33.3,   50.0,   75.0,   100,    
    
    /***** For 5  players(25 dices) *****/
    0.01,   0.01,   0.02,   0.04,   0.08,   
    0.16,   0.33,   0.5,    0.56,   0.63,   
    0.71,   0.83,   1.00,   1.25,   1.67,   
    2.00,   2.50,   3.33,   5.00,   8.33,   
    14.3,   33.3,   50.0,   75.0,   100,    
    
    /***** For 6  players(30 dices) *****/
    0.01,   0.01,   0.02,   0.02,   0.05,   
    0.04,   0.16,   0.33,   0.40,   0.45,   
    0.50,   0.63,   0.67,   0.83,   1.00,   
    1.11,   1.25,   1.43,   1.67,   2.00,   
    2.5,    3.33,   5.00,   6.67,   8.33,   
    14.3,   33.3,   50.0,   75.0,   100,    
};

//CGFloat WinAndWildOdds[] = {
//    /********** Win & wild  ***********/
//    /***** For 3  players(15 dices) *****/
//	100,     50,      25,      12.5,    6.25,   
//    3,       1.5,     0.75,    0.32,    0.15,   
//    0.07,    0.03,   0.02,     0.02,     0.01,   
//    /***** For 4  players(20 dices) *****/
//	100,     75,      50,      25,      12.5,   
//    6.25,    3.0,     1.5,     1.2,     1.1,   
//    1.0,     0.8,     0.4,     0.2,     0.12,   
//    0.07,    0.03,   0.02,     0.02,     0.01,   
//    /***** For 5  players(25 dices) *****/
//	100,     80,      55,      25.0,    12.5,   
//    6.25,    3.0,     2.0,     1.8,     1.6,   
//    1.4,     1.2,     1.0,     0.8,     0.6,   
//    0.5,     0.4,     0.3,     0.2,     0.12,   
//    0.07,    0.03,    0.02,    0.02,    0.01,   
//    /***** For 6  players(30 dices) *****/
//	100,     80,      60,      40,      20,   
//    12.5,    6.25,    3.0,     2.5,     2.2,   
//    2.0,     1.6,     1.5,     1.2,     1.0,   
//    0.9,     0.8,     0.7,     0.6,     0.5,   
//    0.4,     0.3,     0.2,     0.15,     0.12,   
//    0.07,    0.03,    0.02,    0.02,    0.01,   
//};
//
//CGFloat LoseAndWildOdds[] = {
//    /********** Lose & wild  ***********/
//    /***** For 3  players(15 dices) *****/
//    0.01,   0.02,   0.04,   0.08,   0.16,   
//    0.33,   0.67,   1.33,   3.32,   6.67,   
//    14.3,   33.3,   50.0,   75.0,   100,   
//    
//    /***** For 4  players(20 dices) *****/
// 	0.01,   0.02,   0.02,   0.04,   0.08,   
//    0.16,   0.33,   0.67,   0.83,   0.91,   
//    1.00,   1.25,   2.50,   5.00,   8.33,   
//    14.3,   33.3,   50.0,   75.0,   100,    
//    
//    /***** For 5  players(25 dices) *****/
//    0.01,   0.01,   0.02,   0.04,   0.08,   
//    0.16,   0.33,   0.5,    0.56,   0.63,   
//    0.71,   0.83,   1.00,   1.25,   1.67,   
//    2.00,   2.50,   3.33,   5.00,   8.33,   
//    14.3,   33.3,   50.0,   75.0,   100,    
//    
//    /***** For 6  players(30 dices) *****/
//    0.01,   0.01,   0.02,   0.02,   0.05,   
//    0.04,   0.16,   0.33,   0.40,   0.45,   
//    0.50,   0.63,   0.67,   0.83,   1.00,   
//    1.11,   1.25,   1.43,   1.67,   2.00,   
//    2.5,    3.33,   5.00,   6.67,   8.33,   
//    14.3,   33.3,   50.0,   75.0,   100,    
//};



CGFloat *oddsAddr(bool win)
{
    if (win) {
        return WinAndNotWildOdds;
    }else 
        return LoseAndNotWildOdds;
}


- (CGFloat)oddsForWin:(BOOL)win
{
    CGFloat *oddsArr = oddsAddr(win);
    int baseAddr = [self baseAddr:self.diceSession.playingUserCount];
    
    int oddsAddress = baseAddr + self.lastCallDiceCount - 1;
    if (oddsAddress >= 90 || oddsAddress < 0) {
        return 0.0;
    }
    
    CGFloat multiple = 1.0;
    if (self.diceSession.wilds) {
        multiple = win ? 0.3 : 0.7;
    }
    
    return oddsArr[oddsAddress] * multiple;
}

- (int)baseAddr:(int)playerCount
{
    int baseAddr = 0;
    switch (playerCount) {
        case 3:
            baseAddr = 0;
            break;
        case 4:
            baseAddr = 15;
            break;
        case 5:
            baseAddr = 35;
            break;
        case 6:
            baseAddr = 60;
            break;
        default:
            break;
    }
    
    return baseAddr;
}

- (NSString *)defaultRoomName
{
    NSString *name = nil;
    switch (_ruleType) {
        case DiceGameRuleTypeRuleNormal:
            name = [NSString stringWithFormat:NSLS(@"kDiceHappyRoom"),      self.diceSession.sessionId];
            break;
        case DiceGameRuleTypeRuleHigh:
            name = [NSString stringWithFormat:NSLS(@"kDiceHighRoom"), self.diceSession.sessionId];
            break;
        case DiceGameRuleTypeRuleSuperHigh:
            name = [NSString stringWithFormat:NSLS(@"kDiceSuperHighRoom"), self.diceSession.sessionId];
            break;
        default:
            break;
    }
    
    return name;
}

- (NSString *)roomName
{
    NSString *aRoomName = @"";
    if (self.diceSession.roomName == nil || self.diceSession.roomName.length <= 0) {
        aRoomName = [self defaultRoomName];
    }else {
        aRoomName = self.diceSession.roomName;
    }
    
    return aRoomName;
}

@end
