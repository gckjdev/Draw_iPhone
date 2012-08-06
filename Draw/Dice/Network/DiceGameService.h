//
//  DiceGameService.h
//  Draw
//
//  Created by  on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonGameNetworkService.h"
#import "DiceGameSession.h"
#import "Dice.pb.h"
#import "DiceNetworkClient.h"

@interface DiceGameService : CommonGameNetworkService

+ (DiceGameService*)defaultService;
- (DiceGameSession*)diceSession;
- (NSArray *)myDiceList;

- (void)callDice:(int)dice count:(int)count;
- (void)autoCallDice;


- (NSString *)lastCallUserId;
- (int)lastCallDice;
- (int)lastCallDiceCount;

- (void)openDiceWithOpenType:(int)openType;
- (void)creatRoomWithName:(NSString*)name;
@end
