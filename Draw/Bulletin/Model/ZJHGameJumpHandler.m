//
//  ZJHGameJumpHandler.m
//  Draw
//
//  Created by Kira on 12-12-20.
//
//

#import "ZJHGameJumpHandler.h"
#import "SynthesizeSingleton.h"

@implementation ZJHGameJumpHandler

SYNTHESIZE_SINGLETON_FOR_CLASS(ZJHGameJumpHandler)

+(ZJHGameJumpHandler*)defaultHandler
{
    return [ZJHGameJumpHandler sharedZJHGameJumpHandler];
}

- (UIViewController *)controllerForGameId:(NSString *)gameId
                                     func:(NSString *)func
                           fromController:(UIViewController *)controller
{
    UIViewController* jumpController = nil;
    Class class = NSClassFromString(func);
    if (class != nil && [class isSubclassOfClass:[UIViewController class]]){
        jumpController = [[[class alloc] init] autorelease];
    }
    else{
        PPDebug(@"<controllerForGameId>:warnning:function is unexpected. gameId = %@, func = %@",
                gameId, func);
    }

    if (jumpController != nil){
        [controller.navigationController pushViewController:jumpController animated:YES];
    }

    return jumpController;
}

//- (BOOL)isFunctionAvailable:(NSString*)func
//{
//    return NO;
//}

@end
