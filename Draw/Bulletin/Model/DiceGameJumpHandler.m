//
//  DiceGameJumpHandler.m
//  Draw
//
//  Created by Kira on 12-12-20.
//
//

#import "DiceGameJumpHandler.h"
#import "SynthesizeSingleton.h"

@implementation DiceGameJumpHandler

SYNTHESIZE_SINGLETON_FOR_CLASS(DiceGameJumpHandler)

+(DiceGameJumpHandler*)defaultHandler
{
    return [DiceGameJumpHandler sharedDiceGameJumpHandler];
}

- (UIViewController *)controllerForGameId:(NSString *)gameId
                                     func:(NSString *)func
                           fromController:(UIViewController *)controller
{
    return nil;
}

//- (BOOL)isFunctionAvailable:(NSString*)func
//{
//    return NO;
//}

@end
