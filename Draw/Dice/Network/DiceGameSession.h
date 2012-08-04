//
//  DiceGameSession.h
//  Draw
//
//  Created by  on 12-7-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonGameSession.h"

@interface DiceGameSession : CommonGameSession

@property (retain, nonatomic) NSDictionary *userDiceList;
@property (retain, nonatomic) NSString *lastCallDiceUserId;
@property (assign, nonatomic) int lastCallDice;
@property (assign, nonatomic) int lastCallDiceCount;
@property (retain, nonatomic) NSString* openDiceUserId;

@end
