//
//  GameApp.h
//  Draw
//
//  Created by  on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef Draw_GameApp_h
#define Draw_GameApp_h

#import "GameAppProtocol.h"

// Bundle ID
#define DRAW_APP_BUNDLE_ID      @"com.orange.draw"
#define DRAW_APP_PRO_BUNDLE_ID  @"com.orange.drawpro"
#define DICE_APP_BUNDLE_ID      @"com.orange.dice"

// App ID
#define DRAW_APP_ID             @"513819630"
#define DRAW_PRO_APP_ID         @"541354772"
#define DICE_PRO_APP_ID         @""
#define DICE_APP_ID             @""
#define CANDY_APP_ID            @""

// game ID
#define DRAW_GAME_ID            @""
#define DICE_GAME_ID            @""
#define CANDY_GAME_ID           @""

// Umeng ID
#define DRAW_UMENG_ID           @""
#define DICE_UMENG_ID           @""
#define CANDY_UMENG_ID          @""


#define GameApp                 (getGameApp())

extern NSObject<GameAppProtocol>* getGameApp();

#endif
