//
//  DiceGameService.m
//  Draw
//
//  Created by  on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceGameService.h"
#import "GameMessage.pb.h"
#import "PPDebug.h"

@implementation DiceGameService


- (void)handleNextPlayerStartNotification:(GameMessage*)message
{
    // update game status and fire notification
}

- (void)handleCustomMessage:(GameMessage*)message
{
    switch ([message command]){
        case GameCommandTypeNextPlayerStartNotificationRequest:
            [self handleNextPlayerStartNotification:message];
            break;
            
        default:
            PPDebug(@"<handleCustomMessage> unknown command=%d", [message command]);
            break;
    }
}

@end
