//
//  JumpHandler.m
//  Draw
//
//  Created by  on 12-8-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JumpHandler.h"
#import "HomeController.h"
#import "ContestController.h"
#import "HotController.h"
#import "MyFeedController.h"
#import "StringUtil.h"
#import "GameApp.h"
#import "CommonMessageCenter.h"
#import "Bulletin.h"
#import "GameAdWallService.h"

@implementation JumpHandler
+ (JumpHandler *)createJumpHandlerWithType:(JumpType)type
{
    switch (type) {
        case JumpTypeGame:
//            return [[[GameJumpHandler alloc] init]autorelease];
            return [GameApp getGameJumpHandler];
            
        case JumpTypeIntegral:
            return [[[IntergralJumpHandler alloc] init]autorelease];
            
        case JumpTypeWeb:
            return [[[WebViewHandler alloc] init]autorelease];
            
        case JumpTypeSafari:
            return [[[SafariJumpHandler alloc] init]autorelease];
/*            
        case JumpTypeTel:
            return [[[TelJumpHandler alloc] init]autorelease];
            
        case JumpTypeMsg:
            return [[[MessageJumpHandler alloc] init]autorelease];
 */      case JumpTypeOfferWall:
            return [[[OfferWallJumpHandler alloc] init] autorelease];
        default:
            return nil;
    }
}

////override by sub classes
//- (void)handleJump:(BoardView *)boardView 
//        controller:(UIViewController *)controller 
//               URL:(NSURL *)URL
//{
//    
//}

- (void)handleOfferWallJump:(UIViewController*)controller
                     gameId:(NSString*)gameId
                   wallType:(PBRewardWallType)wallType
{
    
}

- (void)handleUrlFromController:(UIViewController*)controller
                            Url:(NSURL*)Url
{
    
}

+ (void)handleGameJump:(UIViewController*)controller
                gameId:(NSString*)gameId
              function:(NSString*)function
                  para:(NSString *)para
{
    [[GameApp getGameJumpHandler] controllerForGameId:gameId
                                                 func:function
                                                 para:para 
                                       fromController:controller];
}

+ (void)handleBulletinJump:(UIViewController*)controller
                  bulletin:(Bulletin*)bulletin
{
    if (bulletin.type == JumpTypeGame) {
        [JumpHandler handleGameJump:controller gameId:bulletin.gameId function:bulletin.function para:bulletin.parameter];
        return;
    }
    if (bulletin.type == JumpTypeOfferWall) {
        PBRewardWallType offerWallType = [bulletin.function intValue];
        [[JumpHandler createJumpHandlerWithType:bulletin.type] handleOfferWallJump:controller gameId:bulletin.gameId wallType:offerWallType];
        return;
    }
    [[JumpHandler createJumpHandlerWithType:bulletin.type] handleUrlFromController:controller Url:[NSURL URLWithString:bulletin.url]];
    
}

+ (BOOL)canJump:(JumpType)type
{
    return (type != JumpTypeCanotJump);
}

@end


#pragma mark - GameJumpHandler
@implementation GameJumpHandler

//- (UIViewController *)controllerForGameId:(NSString *)gameId func:(NSString *)func
//{    
//    if ([gameId isEqualToString:@"draw"]) {
//        if ([func isEqualToString:@"feed"]) {
//            return [[[MyFeedController alloc] init] autorelease];            
//        }else if([func isEqualToString:@"contest"]){
//            return [[[ContestController alloc] init] autorelease];            
//        }else if([func isEqualToString:@"top"]){
//            return [[[HotController alloc] init] autorelease];            
//        }else{
//            PPDebug(@"<controllerForGameId>:warnning:function is unexpected. gameId = %@, func = %@", gameId, func);            
//            return nil;//[[[HomeController alloc] init] autorelease];               
//        }
//    }
//    return nil;
//}

//override by sub classes
/*
- (void)handleJump:(BoardView *)boardView 
        controller:(UIViewController *)controller 
               URL:(NSURL *)URL
{
    [super handleJump:boardView controller:controller URL:URL];

    NSString *gameId = [URL.queryComponents objectForKey:BOARD_PARA_GAME];
    NSString *func = [URL.queryComponents objectForKey:BOARD_PARA_FUNC];
    UIViewController *gameController = [[GameApp getGameJumpHandler] controllerForGameId:gameId func:func fromController:nil];
    if (gameController) {
        [controller.navigationController pushViewController:gameController animated:YES];
    } else {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kVersionNotSupport") delayTime:2];
    }
    //push the game controller
}
 */
@end


#pragma mark - WebViewHandler
@implementation WebViewHandler
//override by sub classes
/*
- (void)handleJump:(BoardView *)boardView 
        controller:(UIViewController *)controller 
               URL:(NSURL *)URL
{
    [super handleJump:boardView controller:controller URL:URL];
    
//    NSString *url = [URL.queryComponents objectForKey:BOARD_PARA_URL];
    //load the web view handler
    
}
 */
- (void)handleUrlFromController:(UIViewController*)controller
                            Url:(NSURL*)Url
{
    
}
@end

#pragma mark - IntergralJumpHandler
@implementation IntergralJumpHandler
//override by sub classes
/*
- (void)handleJump:(BoardView *)boardView 
        controller:(UIViewController *)controller 
               URL:(NSURL *)URL
{
    [super handleJump:boardView controller:controller URL:URL];
    [[LmWallService defaultService] show:controller];
}
 */
@end

#pragma mark - SafariJumpHandler
@implementation SafariJumpHandler

/*
//override by sub classes
- (void)handleJump:(BoardView *)boardView 
        controller:(UIViewController *)controller 
               URL:(NSURL *)URL
{
    [super handleJump:boardView controller:controller URL:URL];
    NSString *url = [URL.queryComponents objectForKey:BOARD_PARA_URL];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}
 */
- (void)handleUrlFromController:(UIViewController*)controller
                            Url:(NSURL*)Url
{
    [[UIApplication sharedApplication] openURL:Url];
    //http://  tel:// msm:// 
    
}
@end

#pragma mark - OfferWallJumpHandler
@implementation OfferWallJumpHandler

- (void)handleOfferWallJump:(UIViewController*)controller
                     gameId:(NSString*)gameId
                   wallType:(PBRewardWallType)wallType
{
    [[GameAdWallService defaultService] showInsertWall:controller wallType:wallType];
}


@end

/*
#pragma mark - TelJumpHandler
@implementation TelJumpHandler
//override by sub classes
- (void)handleJump:(BoardView *)boardView 
        controller:(UIViewController *)controller 
               URL:(NSURL *)URL
{
    [super handleJump:boardView controller:controller URL:URL];
    NSString *url = [URL.queryComponents objectForKey:BOARD_PARA_URL];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}
@end

#pragma mark - MessageJumpHandler
@implementation MessageJumpHandler
//override by sub classes
- (void)handleJump:(BoardView *)boardView 
        controller:(UIViewController *)controller 
               URL:(NSURL *)URL
{
    [super handleJump:boardView controller:controller URL:URL];
    NSString *url = [URL.queryComponents objectForKey:BOARD_PARA_URL];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}
@end

*/