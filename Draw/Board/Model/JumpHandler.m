//
//  JumpHandler.m
//  Draw
//
//  Created by  on 12-8-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JumpHandler.h"
#import "FeedController.h"
#import "LmWallService.h"

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
            
        case JumpTypeTel:
            return [[[TelJumpHandler alloc] init]autorelease];
            
        case JumpTypeMsg:
            return [[[MessageJumpHandler alloc] init]autorelease];
            
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

@end


#pragma mark - GameJumpHandler
@implementation GameJumpHandler

- (UIViewController *)controllerForGameId:(NSString *)gameId
{
    if ([gameId isEqualToString:@"feed"]) {
        return [[[FeedController alloc] init] autorelease];
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
    UIViewController *gameController = [self controllerForGameId:gameId];
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
    
    NSString *url = [URL.queryComponents objectForKey:BOARD_PARA_URL];
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

