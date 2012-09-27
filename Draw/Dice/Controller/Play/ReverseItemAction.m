//
//  ReverseItemAction.m
//  Draw
//
//  Created by 小涛 王 on 12-9-20.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "ReverseItemAction.h"
#import "GameMessage.pb.h"
#import "DiceGamePlayController.h"

@implementation ReverseItemAction

- (BOOL)useScene
{
    return [self isMyTurn];
}

- (void)showItemAnimation:(NSString *)userId 
                 itemType:(int)itemType 
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view
{
    [self showGifViewOnUserAvatar:userId
                          gifFile:@"reverse.gif"
                       controller:controller
                             view:view];
}

- (void)useItemSuccess:(DiceGamePlayController *)controller
                  view:(UIView *)view 
              response:(UseItemResponse *)response
{
    
    if (response.decreaseTimeForNextPlayUser) {
        [controller clearAllUrgeUser];
        [controller urgeUser:response.nextPlayUserId];
        PBGameUser* user = [_gameService.session getUserByUserId:response.nextPlayUserId];
        PPDebug(@"<ReverseItemAction> urge user %@ (sitting at %d)again!", user.nickName, user.seatId);
    }
}

- (void)someoneUseItem:(NSString *)userId
            controller:(DiceGamePlayController *)controller
                  view:(UIView *)view 
               request:(UseItemRequest *)request
{
    if (request.decreaseTimeForNextPlayUser) {
        [controller clearAllUrgeUser];
        [controller urgeUser:request.nextPlayUserId];
        PBGameUser* user = [_gameService.session getUserByUserId:request.nextPlayUserId];
        PPDebug(@"<ReverseItemAction> urge user %@ (sitting at %d)again!", user.nickName, user.seatId);
    }
}

@end
