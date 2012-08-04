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

- (void)dealloc{
    PPRelease(_userDiceList);
    [super dealloc];
}




@end
