//
//  JumpHandler.m
//  Draw
//
//  Created by  on 12-8-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JumpHandler.h"
#import "LmWallService.h"
#import "HomeController.h"
#import "ContestController.h"
#import "HotController.h"
#import "MyFeedController.h"
#import "StringUtil.h"

#define FUNC_FEED    @"feed"
#define FUNC_CONTEST    @"contest"
#define FUNC_TOP    @"top"

@implementation JumpHandler
+ (JumpHandler *)createJumpHandlerWithType:(JumpType)type
{
    switch (type) {
        case JumpTypeGame:
            return [[[GameJumpHandler alloc] init]autorelease];
            
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
*/          
        default:
            return nil;
    }
}

//override by sub classes
- (void)handleJump:(BoardView *)boardView 
        controller:(UIViewController *)controller 
               URL:(NSURL *)URL
{
    
}

+ (void)handleJump:(UIViewController*)controller
            gameId:(NSString*)gameId
              func:(NSString*)func
{
    UIViewController* jumpController = nil;
    if ([gameId isEqualToString:DRAW_GAME_ID ignoreCapital:YES]) {
        if ([func isEqualToString:FUNC_FEED ignoreCapital:YES]) {
            jumpController = [[[MyFeedController alloc] init] autorelease];
        }else if([func isEqualToString:FUNC_CONTEST ignoreCapital:YES]){
            jumpController = [[[ContestController alloc] init] autorelease];
        }else if([func isEqualToString:FUNC_TOP ignoreCapital:YES]){
            jumpController = [[[HotController alloc] init] autorelease];
        }else{
            PPDebug(@"<controllerForGameId>:warnning:function is unexpected. gameId = %@, func = %@", gameId, func);
        }
    }
    [controller.navigationController pushViewController:jumpController animated:YES];
    
}

@end


#pragma mark - GameJumpHandler
@implementation GameJumpHandler

- (UIViewController *)controllerForGameId:(NSString *)gameId func:(NSString *)func
{    
    if ([gameId isEqualToString:@"draw"]) {
        if ([func isEqualToString:@"feed"]) {
            return [[[MyFeedController alloc] init] autorelease];            
        }else if([func isEqualToString:@"contest"]){
            return [[[ContestController alloc] init] autorelease];            
        }else if([func isEqualToString:@"top"]){
            return [[[HotController alloc] init] autorelease];            
        }else{
            PPDebug(@"<controllerForGameId>:warnning:function is unexpected. gameId = %@, func = %@", gameId, func);            
            return nil;//[[[HomeController alloc] init] autorelease];               
        }
    }
    return nil;
}

//override by sub classes
- (void)handleJump:(BoardView *)boardView 
        controller:(UIViewController *)controller 
               URL:(NSURL *)URL
{
    [super handleJump:boardView controller:controller URL:URL];

    NSString *gameId = [URL.queryComponents objectForKey:BOARD_PARA_GAME];
    NSString *func = [URL.queryComponents objectForKey:BOARD_PARA_FUNC];
    UIViewController *gameController = [self controllerForGameId:gameId func:func];
    if (gameController) {
        [controller.navigationController pushViewController:gameController animated:YES];
    }
    //push the game controller
}
@end


#pragma mark - WebViewHandler
@implementation WebViewHandler
//override by sub classes
- (void)handleJump:(BoardView *)boardView 
        controller:(UIViewController *)controller 
               URL:(NSURL *)URL
{
    [super handleJump:boardView controller:controller URL:URL];
    
//    NSString *url = [URL.queryComponents objectForKey:BOARD_PARA_URL];
    //load the web view handler
    
}
@end

#pragma mark - IntergralJumpHandler
@implementation IntergralJumpHandler
//override by sub classes
- (void)handleJump:(BoardView *)boardView 
        controller:(UIViewController *)controller 
               URL:(NSURL *)URL
{
    [super handleJump:boardView controller:controller URL:URL];
    [[LmWallService defaultService] show:controller];
}
@end

#pragma mark - SafariJumpHandler
@implementation SafariJumpHandler
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