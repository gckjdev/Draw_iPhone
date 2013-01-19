//
//  DrawGameJumpHandler.m
//  Draw
//
//  Created by Kira on 12-12-20.
//
//

#import "DrawGameJumpHandler.h"
#import "SynthesizeSingleton.h"
#import "MyFeedController.h"
#import "HotController.h"
#import "ContestController.h"
#import "StringUtil.h"
#import "FreeCoinsControllerViewController.h"

#define FUNC_FEED    @"feed"
#define FUNC_CONTEST    @"contest"
#define FUNC_TOP    @"top"
#define FUNC_FREE_COINS  @"free_coins"

@implementation DrawGameJumpHandler

SYNTHESIZE_SINGLETON_FOR_CLASS(DrawGameJumpHandler)

+(DrawGameJumpHandler*)defaultHandler
{
    return [DrawGameJumpHandler sharedDrawGameJumpHandler];
}

- (UIViewController *)controllerForGameId:(NSString *)gameId
                                     func:(NSString *)func
                           fromController:(UIViewController *)controller
{
    UIViewController* jumpController = nil;
    if ([func isEqualToString:FUNC_FEED ignoreCapital:YES]) {
        jumpController = [[[MyFeedController alloc] init] autorelease];
    }else if([func isEqualToString:FUNC_CONTEST ignoreCapital:YES]){
        jumpController = [[[ContestController alloc] init] autorelease];
    }else if([func isEqualToString:FUNC_TOP ignoreCapital:YES]){
        jumpController = [[[HotController alloc] init] autorelease];
    }else if ([func isEqualToString:FUNC_FREE_COINS ignoreCapital:YES]){
        jumpController = [[[FreeCoinsControllerViewController alloc] init] autorelease];
    }else{
        PPDebug(@"<controllerForGameId>:warnning:function is unexpected. gameId = %@, func = %@", gameId, func);
    }
    [controller.navigationController pushViewController:jumpController animated:YES];
    return jumpController;
}

//- (BOOL)isFunctionAvailable:(NSString*)func
//{
//    if ([func isEqualToString:FUNC_FEED ignoreCapital:YES]
//        || [func isEqualToString:FUNC_CONTEST ignoreCapital:YES]
//        || [func isEqualToString:FUNC_TOP ignoreCapital:YES]) {
//        return YES;
//    }
//    return NO;
//}

@end
