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
@synthesize userResultList = _userResultList;

- (void)dealloc{
    PPRelease(_userDiceList);
    PPRelease(_lastCallDiceUserId);
    PPRelease(_openDiceUserId);
    PPRelease(_userResultList);
    [super dealloc];
}




@end
