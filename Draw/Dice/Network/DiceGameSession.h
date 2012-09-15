//
//  DiceGameSession.h
//  Draw
//
//  Created by  on 12-7-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonGameSession.h"

typedef enum {
    OpenTypeNormal = 0,
    OpenTypeScramble = 1,
    OpenTypeCut = 2,
}OpenType;

typedef enum {
    GameStateGameOver = 0,
    GameStatePlaying = 1,
}DiceGameState;

@interface DiceGameSession : CommonGameSession

@property (retain, nonatomic) NSMutableDictionary *userDiceList;

@property (retain, nonatomic) NSString *lastCallDiceUserId;
@property (assign, nonatomic) int lastCallDice;
@property (assign, nonatomic) int lastCallDiceCount;

@property (retain, nonatomic) NSString* openDiceUserId;
@property (assign, nonatomic) OpenType openType;

@property (retain, nonatomic) NSDictionary *gameResult;
@property (retain, nonatomic) NSDictionary *finalCount;


@property (assign, nonatomic) BOOL wilds;
@property (nonatomic, assign) BOOL isMeAByStander;
@property (assign, nonatomic) DiceGameState gameState;
@property (assign, nonatomic) int callCount;

- (void)reset;
- (int)ante;

@end
