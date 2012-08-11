//
//  DiceGameSession.m
//  Draw
//
//  Created by  on 12-7-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceGameSession.h"
#import "PPDebug.h"

@implementation DiceGameSession

@synthesize userDiceList = _userDiceList;
@synthesize lastCallDiceUserId = _lastCallDiceUserId;
@synthesize lastCallDice = _lastCallDice;
@synthesize lastCallDiceCount = _lastCallDiceCount;
@synthesize openDiceUserId = _openDiceUserId;
@synthesize openType = _openType;
@synthesize gameResult = _gameResult;
@synthesize wilds = _wilds;
@synthesize isMeAByStander = _isMeAByStander;

- (void)dealloc{
    PPRelease(_userDiceList);
    PPRelease(_lastCallDiceUserId);
    PPRelease(_openDiceUserId);
    PPRelease(_gameResult);
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        [self reset];
    }
    
    return self;
}

- (void)reset
{
    self.userDiceList = nil;
    self.lastCallDiceUserId = nil;    
    self.lastCallDice = 0;
    self.lastCallDiceCount = 0;
    self.openDiceUserId = nil;
    self.openType = 0;
    self.gameResult = nil;
    self.wilds = false;
    self.isMeAByStander = YES;
}

@end
