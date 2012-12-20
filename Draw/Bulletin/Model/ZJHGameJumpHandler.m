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
    return nil;
}

@end
