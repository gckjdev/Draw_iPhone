//
//  DiceGameSession.m
//  Draw
//
//  Created by  on 12-7-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceGameSession.h"
#import "PPDebug.h"
#import "GameConstants.pb.h"

@implementation DiceGameSession

@synthesize userDiceList = _userDiceList;
@synthesize lastCallDiceUserId = _lastCallDiceUserId;
@synthesize lastCallDice = _lastCallDice;
@synthesize lastCallDiceCount = _lastCallDiceCount;
@synthesize openDiceUserId = _openDiceUserId;
@synthesize openType = _openType;
@synthesize gameResult = _gameResult;
@synthesize finalCount = _finalCount;
@synthesize wilds = _wilds;
@synthesize isMeAByStander = _isMeAByStander;
@synthesize gameState = _gameState;
@synthesize callCount = _callCount;
@synthesize betWin = _betWin;

- (void)dealloc{
    PPRelease(_userDiceList);
    PPRelease(_lastCallDiceUserId);
    PPRelease(_openDiceUserId);
    PPRelease(_gameResult);
    PPRelease(_finalCount);
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        self.userDiceList = [NSMutableDictionary dictionary];
        [self reset];
    }
    
    return self;
}

- (void)reset
{
    [self.userDiceList removeAllObjects];
    self.lastCallDiceUserId = nil;    
    self.lastCallDice = 0;
    self.lastCallDiceCount = 0;
    self.openDiceUserId = nil;
    self.openType = OpenTypeNormal;
    self.gameResult = nil;
    self.finalCount = nil;
    self.wilds = false;
    self.isMeAByStander = YES;
    self.gameState = GameStateGameOver;
    self.callCount = 0;
    self.betWin = NO;
}

@end
