//
//  DiceGameJumpHandler.h
//  Draw
//
//  Created by Kira on 12-12-20.
//
//

#import "JumpHandler.h"
#import "GameJumpHandlerProtocol.h"

@interface DiceGameJumpHandler : GameJumpHandler <GameJumpHandlerProtocol>

+ (DiceGameJumpHandler*)defaultHandler;

@end
