//
//  DecTimeItemAction.m
//  Draw
//
//  Created by Orange on 12-9-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DecTimeItemAction.h"
#import "ItemType.h"
#import "ConfigManager.h"
#import "DiceGamePlayController.h"
#import "UserManager.h"
#import "DiceAvatarView.h"
#import "GameMessage.pb.h"

@implementation DecTimeItemAction

- (BOOL)useScene
{
    return [self isMyTurn] && ([_gameService.diceSession itemUseCount:_itemType] < 1);
}

- (void)showItemAnimation:(NSString *)userId 
                 itemType:(int)itemType 
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view
{
    [self showGifViewOnUserAvatar:userId
                          gifFile:@"hurryup.gif"
                       controller:controller
                             view:view];
}

- (void)useItemSuccess:(DiceGamePlayController *)controller
                  view:(UIView *)view 
              response:(UseItemResponse *)response
{
    PBGameUser* itemTarget = [_gameService.session getUserByUserId:response.nextPlayUserId];
    PPDebug(@"<DecTimeItemAction> I use an urge item, urge user %@(sit ad %d)", itemTarget.nickName, itemTarget.seatId);
    [controller urgeUser:response.nextPlayUserId];
}

- (void)someoneUseItem:(NSString *)userId
            controller:(DiceGamePlayController *)controller
                  view:(UIView *)view 
               request:(UseItemRequest *)request
{
    PBGameUser* itemUser = [_gameService.session getUserByUserId:userId];
    PBGameUser* itemTarget = [_gameService.session getUserByUserId:request.nextPlayUserId];
    PPDebug(@"<DecTimeItemAction> %@(sit at %d) use an urge item, urge user %@(sit ad %d)", itemUser.nickName, itemUser.seatId,  itemTarget.nickName, itemTarget.seatId);
    [controller urgeUser:request.nextPlayUserId];
}
@end
