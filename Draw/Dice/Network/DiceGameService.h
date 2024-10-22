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
#import "GameConstants.pb.h"

@interface DiceGameService : CommonGameNetworkService

@property (assign, nonatomic) DiceGameRuleType ruleType;

+ (DiceGameService*)defaultService;

- (DiceGameSession*)diceSession;
- (NSArray *)myDiceList;
- (NSString *)lastCallUserId;
- (int)lastCallDice;
- (int)lastCallDiceCount;
- (NSString *)openDiceUserId;
- (OpenType)openType;
- (NSDictionary *)gameResult;

- (void)callDice:(int)dice count:(int)count wilds:(BOOL)wilds;
- (void)openDice;

- (void)userItem:(int)itemId;
- (void)userTimeItem:(int)itemId 
                time:(int)time;
- (void)changeDiceList:(NSString *)userId diceList:(NSArray *)diceList;

- (int)ante;
- (int)maxCallCount;

- (int)betAnte;
- (void)betOpenUserWin:(BOOL)win;
- (CGFloat)oddsForWin:(BOOL)win;
- (NSString *)roomName;

@end
