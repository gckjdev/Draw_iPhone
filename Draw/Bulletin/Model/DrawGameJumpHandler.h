//
//  DrawGameJumpHandler.h
//  Draw
//
//  Created by Kira on 12-12-20.
//
//

#import "JumpHandler.h"
#import "GameJumpHandlerProtocol.h"

@interface DrawGameJumpHandler : GameJumpHandler <GameJumpHandlerProtocol>

+ (DrawGameJumpHandler*)defaultHandler;

@end
