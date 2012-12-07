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
#define ZJH_APP_BUNDLE_ID       @"com.orange.zhajinhua"

// App ID
#define DRAW_APP_ID             @"513819630"
#define DRAW_PRO_APP_ID         @"541354772"
#define DICE_PRO_APP_ID         @"557072001"
#define DICE_APP_ID             @"557072001"
#define ZJH_APP_ID              @"585525675"
#define CANDY_APP_ID            @"test"

// game ID
#define DRAW_GAME_ID            @"Draw"
#define DICE_GAME_ID            @"Dice"
#define CANDY_GAME_ID           @"Candy"
#define ZHAJINHUA_GAME_ID       @"Zhajinhua"

// Umeng ID
#define DRAW_UMENG_ID           @"4f83980852701565c500003a"
#define DICE_UMENG_ID           @"503b13225270150f45000059"
#define CANDY_UMENG_ID          @"4f83980852701565c500003a" // TO BE CHANGED
#define ZJH_UMENG_ID            @"50c1883752701537100000af" 

// Lm Ad Wall ID
#define DRAW_LM_WALL_ID         @"ed21340370b99ad5bd2a5e304e3ea6c4"
#define DICE_LM_WALL_ID         @"e1533257a9cd82ab88fe853d71bd11c5"
#define CANDY_LM_WALL_ID        @"ed21340370b99ad5bd2a5e304e3ea6c4" // TO BE CHANGED
#define ZJH_LM_WALL_ID          @"e1533257a9cd82ab88fe853d71bd11c5"

// Lm Ad ID
#define DRAW_LM_AD_ID           @"eb4ce4f0a0f1f49b6b29bf4c838a5147"
#define DICE_LM_AD_ID           @"eb4ce4f0a0f1f49b6b29bf4c838a5147"
#define CANDY_LM_AD_ID          @"eb4ce4f0a0f1f49b6b29bf4c838a5147" // TO BE CHANGED
#define ZJH_LM_AD_ID            @"eb4ce4f0a0f1f49b6b29bf4c838a5147"

// Ader Ad ID
#define DRAW_ADER_AD_ID         @"3b47607e44f94d7c948c83b7e6eb800e"
#define DICE_ADER_AD_ID         @"661f38bed5974599abfad68e6ef402a3"
#define CANDY_ADER_AD_ID        @"3b47607e44f94d7c948c83b7e6eb800e" // TO BE CHANGED
#define ZJH_ADER_AD_ID          @"661f38bed5974599abfad68e6ef402a3"

// Mango Ad ID
#define DRAW_MANGO_AD_ID        @"ad29f0cf8361452db392ffdef8057eff"
#define DICE_MANGO_AD_ID        @"65d242132f684a798194044936c6133a"
#define CANDY_MANGO_AD_ID       @"ad29f0cf8361452db392ffdef8057eff" // TO BE CHANGED
#define ZJH_MANGO_AD_ID         @"65d242132f684a798194044936c6133a"


// Lm Ad ID

#define DRAW_BACKGROUND         @"wood_bg@2x.png"
#define DICE_BACKGROUND         @"dice_room_background@2x.jpg"
#define ZJH_BACKGROUND          @"dice_room_background@2x.jpg"
#define CANDY_BACKGROUND        @""


typedef enum {
    GameAppTypeUnknow = 0,
    GameAppTypeCandy = 1,
    GameAppTypeDraw = 2,
    GameAppTypeDice = 3,
    GameAppTypeZJH = 4,
    
}GameAppType;

#define GameApp                 (getGameApp())

extern NSObject<GameAppProtocol>* getGameApp();
extern BOOL isDrawApp();
extern BOOL isDiceApp();
extern BOOL isZhajinhuaApp();
extern GameAppType gameAppType();

#endif
