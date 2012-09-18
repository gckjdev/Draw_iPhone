//
//  DiceRobotManager.h
//  Draw
//
//  Created by Orange on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiceResult : NSObject
@property (assign, nonatomic) int dice;
@property (assign, nonatomic) int diceCount;
@property (assign, nonatomic) bool isWild;

@end

@interface DiceRobotManager : NSObject {
    // What each player last calls
    NSMutableDictionary* lastCall;
    // Does player change his/her dice, compared to last round?
    NSMutableDictionary* changeDiceValue;
}

+ (DiceRobotManager*)defaultManager;

- (DiceResult*)getWhatToCall;
- (void)newRound:(int)playerCount;
- (void)introspectRobotDices:(int[])robotDices;
- (void)resetBenchmark;
- (void) balanceAndReset:(int)playerCount;
- (BOOL)canOpenDice:(int)playerCount 
             userId:(NSString*)userId
             number:(int)num 
               dice:(int)dice 
             isWild:(BOOL)isWild;
- (void) decideWhatToCall:(int)playerCount 
                   number:(int)num 
                     dice:(int)dice 
                   isWild:(BOOL)isWild 
                   myDice:(int[])robotDices;
- (void)recordCall:(int)num 
              dice:(int)dice 
            isWild:(int)isWild 
       playerCount:(int)playerCount;
- (void)initialCall:(int)playerCount;
- (BOOL)giveUpCall;



@end
