//
//  JumpHandler.h
//  Draw
//
//  Created by  on 12-8-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoardView.h"
#import "XQueryComponents.h"

typedef enum{
    JumpTypeGame = 1, // game page
    JumpTypeIntegral = 2, // Integral
    JumpTypeWeb = 3, //webview
    JumpTypeSafari = 4, //safari
//    JumpTypeTel = 5, //tel
//    JumpTypeMsg = 6 //message    
}JumpType;


#define BOARD_HOST @"board"

#define BOARD_SCHEME_BOARD @"tgb"
#define BOARD_SCHEME_HTTP @"http"
#define BOARD_SCHEME_HTTPS @"https"
#define BOARD_SCHEME_FILE @"file"
#define BOARD_SCHEME_TEL @"tel"
#define BOARD_SCHEME_SMS @"sms"


#define BOARD_PARA_TYPE @"type"
#define BOARD_PARA_GAME @"game"
#define BOARD_PARA_FUNC @"func"
#define BOARD_PARA_URL @"url"


@interface JumpHandler : NSObject

+ (JumpHandler *)createJumpHandlerWithType:(JumpType)type;

//override by sub classes
- (void)handleJump:(BoardView *)boardView 
        controller:(UIViewController *)controller 
               URL:(NSURL *)URL;

+ (void)handleJump:(UIViewController*)controller
            gameId:(NSString*)gameId
              func:(NSString*)func;

@end


#pragma mark - GameJumpHandler
@interface GameJumpHandler : JumpHandler
@end

#pragma mark - IntergralJumpHandler
@interface IntergralJumpHandler : JumpHandler
@end


#pragma mark - WebViewHandler
@interface WebViewHandler : JumpHandler
@end


#pragma mark - SafariJumpHandler
@interface SafariJumpHandler : JumpHandler
@end

/*
#pragma mark - TelJumpHandler
@interface TelJumpHandler : JumpHandler
@end

#pragma mark - MessageJumpHandler
@interface MessageJumpHandler : JumpHandler
@end
*/

