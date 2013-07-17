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
//#import "FreeCoinsControllerViewController.h"
#import "StoreController.h"
#import "FreeIngotController.h"
#import "BBSPostDetailController.h"

#define FUNC_FEED                       @"feed"
#define FUNC_CONTEST                    @"contest"
#define FUNC_TOP                        @"top"
#define FUNC_FREE_COINS                 @"free_coins"
#define FUNC_FREE_INGOT                 @"free_ingot"
#define FUNC_SHOP                       @"shop"
#define FUNC_BBS_FREE_COIN_HELP         @"bbs_free_ingot"
#define FUNC_BBS_FEEDBACK               @"bbs_feedback"
#define FUNC_BBS_BUG_REPORT             @"bbs_bug_report"

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
//        jumpController = [[[FreeCoinsControllerViewController alloc] init] autorelease];
    }else if ([func isEqualToString:FUNC_FREE_INGOT ignoreCapital:YES]) {
        jumpController = [[[FreeIngotController alloc] init] autorelease];
    }else if ([func isEqualToString:FUNC_SHOP ignoreCapital:YES]){
        jumpController = [[[StoreController alloc] init] autorelease];
    }
    else if ([func isEqualToString:FUNC_BBS_FREE_COIN_HELP ignoreCapital:YES]){
        return [BBSPostDetailController enterFreeIngotPostController:controller animated:YES];
    }
    else if ([func isEqualToString:FUNC_BBS_BUG_REPORT ignoreCapital:YES]){
        return [BBSPostDetailController enterBugReportPostController:controller animated:YES];
    }
    else if ([func isEqualToString:FUNC_BBS_FEEDBACK ignoreCapital:YES]){
        return [BBSPostDetailController enterFeedbackPostController:controller animated:YES];
    }
    else{
        Class class = NSClassFromString(func);
        if (class != nil && [class isSubclassOfClass:[UIViewController class]]){
            jumpController = [[[class alloc] init] autorelease];
        }
        else{
            PPDebug(@"<controllerForGameId>:warnning:function is unexpected. gameId = %@, func = %@",
                    gameId, func);
        }
    }
    
    if (jumpController != nil){
        [controller.navigationController pushViewController:jumpController animated:YES];
    }
    
    return jumpController;
}

@end
