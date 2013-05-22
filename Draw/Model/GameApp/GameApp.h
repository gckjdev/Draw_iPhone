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
#define DRAW_APP_BUNDLE_ID                  @"com.orange.draw"
#define DRAW_APP_PRO_BUNDLE_ID              @"com.orange.drawpro"
#define DICE_APP_BUNDLE_ID                  @"com.orange.newdice"
#define OLD_DICE_APP_BUNDLE_ID              @"com.orange.dice"
#define ZJH_APP_BUNDLE_ID                   @"com.orange.zhajinhua"
#define LEARNDRAW_APP_BUNDLE_ID             @"com.orange.learndraw"
#define PUREDRAW_APP_BUNDLE_ID              @"com.orange.puredraw"
#define PUREDRAWFREE_APP_BUNDLE_ID          @"com.orange.puredrawfree"
#define PHOTODRAW_APP_BUNDLE_ID             @"com.orange.photodraw"
#define PHOTODRAWFREE_APP_BUNDLE_ID         @"com.orange.photodrawfree"
#define DREAMAVATAR_APP_BUNDLE_ID           @"com.orange.dreamavatar"
#define DREAMAVATARFREE_APP_BUNDLE_ID       @"com.orange.dreamavatarfree"
#define DREAMLOCKSCREEN_APP_BUNDLE_ID       @"com.orange.dreamlockscreen"
#define DREAMLOCKSCREENFREE_APP_BUNDLE_ID   @"com.orange.dreamlockscreenfree"
#define LITTLE_GEE_APP_BUNDLE_ID            @"com.orange.littlegee"
#define SING_APP_BUNDLE_ID                  @"com.orange.sing"

// App ID
#define DRAW_APP_ID                     @"513819630"
#define DRAW_PRO_APP_ID                 @"541354772"
#define DICE_PRO_APP_ID                 @"606131564"
#define DICE_APP_ID                     @"606131564"
#define OLD_DICE_APP_ID                 @"557072001"
#define ZJH_APP_ID                      @"585525675"
#define CANDY_APP_ID                    @"test"
#define LEARN_DRAW_APP_ID               @"635820146"
#define PURE_DRAW_APP_ID                @"639593519"
#define PURE_DRAW_FREE_APP_ID           @"639593939"
#define PHOTO_DRAW_APP_ID               @"639595333"
#define PHOTO_DRAW_FREE_APP_ID          @"639596045"
#define DREAM_AVATAR_APP_ID             @"648176144" //@"645412087"
#define DREAM_AVATAR_FREE_APP_ID        @"645413029"
#define DREAM_LOCKSCREEN_APP_ID         @"645413042"
#define DREAM_LOCKSCREEN_FREE_APP_ID    @"648179189" // @"645413811"
#define LITTLE_GEE_APP_ID               @"645475970"

// game ID
#define DRAW_GAME_ID                    @"Draw"
#define DICE_GAME_ID                    @"Dice"
#define CANDY_GAME_ID                   @"Candy"
#define ZHAJINHUA_GAME_ID               @"Zhajinhua"
#define LEARN_DRAW_GAME_ID              @"Learndraw"
#define PURE_DRAW_GAME_ID               @"Puredraw"
#define PURE_DRAW_FREE_GAME_ID          @"Puredrawfree"
#define PHOTO_DRAW_GAME_ID              @"Photodraw"
#define PHOTO_DRAW_FREE_GAME_ID         @"Photodrawfree"
#define DREAM_AVATAR_GAME_ID            @"DreamAvatar"
#define DREAM_AVATAR_FREE_GAME_ID       @"DreamAvatarFree"
#define DREAM_LOCKSCREEN_GAME_ID        @"DreamLockscreen"
#define DREAM_LOCKSCREEN_FREE_GAME_ID   @"DreamLockscreenFree"
#define LITTLE_GEE_GAME_ID              @"Draw"

// Umeng ID
#define DRAW_UMENG_ID                   @"4f83980852701565c500003a"
#define DICE_UMENG_ID                   @"503b13225270150f45000059"
#define CANDY_UMENG_ID                  @"4f83980852701565c500003a" // TO BE CHANGED
#define ZJH_UMENG_ID                    @"50c1883752701537100000af"
#define LEARN_DRAW_UMENG_ID             @"516d181256240b096c000a83"
#define PURE_DRAW_UMENG_ID              @"5175fd3356240b501600f6d0"
#define PURE_DRAW_FREE_UMENG_ID         PURE_DRAW_UMENG_ID
#define PHOTO_DRAW_UMENG_ID             @"5175fd6e56240ba4260002d3"
#define PHOTO_DRAW_FREE_UMENG_ID        PHOTO_DRAW_UMENG_ID
#define DREAM_AVATAR_UMENG_ID           @"5187307556240babd8041f4b"
#define DREAM_AVATAR_FREE_UMENG_ID      DREAM_AVATAR_UMENG_ID
#define DREAM_LOCKSCREEN_UMENG_ID       @"5187307556240babd8041f4b"
#define DREAM_LOCKSCREEN_FREE_UMENG_ID  DREAM_LOCKSCREEN_UMENG_ID
#define LITTLE_GEE_UMENG_ID             @"518902cb56240b0c2600c457"

// Lm Ad Wall ID
//#define DRAW_LM_WALL_ID         @"ed21340370b99ad5bd2a5e304e3ea6c4"
#define DRAW_LM_WALL_ID         @"f86cc23b710f1e4d9603dcde84474588" // New, Add By Benson 2013-03-13
#define DICE_LM_WALL_ID         @"c07a27f181b8554afc43aefaf214765e" // New, Add By Benson 2013-03-13
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

#define DRAW_BACKGROUND         @"draw_main_bg@2x.jpg" //@"wood_bg@2x.png"
#define DICE_BACKGROUND         @"draw_main_bg@2x.jpg"
#define ZJH_BACKGROUND          @"draw_main_bg@2x.jpg"
#define CANDY_BACKGROUND        @""


typedef enum {
    GameAppTypeUnknow = 0,
    GameAppTypeCandy = 1,
    GameAppTypeDraw = 2,
    GameAppTypeDice = 3,
    GameAppTypeZJH = 4,
    GameAppTypeLearnDraw = 5,
    GameAppTypePureDraw = 6,
    GameAppTypePureDrawFree = 7,
    GameAppTypePhotoDraw = 8,
    GameAppTypePhotoDrawFree = 9,
    GameAppTypeDreamAvatar = 10,
    GameAppTypeDreamAvatarFree = 11,
    GameAppTypeDreamLockscreen = 12,
    GameAppTypeDreamLockscreenFree = 13,
    GameAppTypeLittleGee = 14
}GameAppType;


typedef enum {
    SellContentTypeUnknow = 0,
    SellContentTypeLearnDraw = 1,
    SellContentTypeDreamAvatar = 2,
    SellContentTypeDreamLockscreen = 3
}SellContentType;


#define GameApp                 (getGameApp())
#define ContentGameApp          (getContentGameApp())

extern NSObject<GameAppProtocol>* getGameApp();
extern NSObject<ContentGameAppProtocol>* getContentGameApp();

extern BOOL isDrawApp();
extern BOOL isDiceApp();
extern BOOL isZhajinhuaApp();
extern BOOL isSimpleDrawApp();
extern BOOL isLearnDrawApp();
extern BOOL isPureDrawApp();
extern BOOL isPureDrawFreeApp();
extern BOOL isPhotoDrawApp();
extern BOOL isPhotoDrawFreeApp();
extern BOOL isDreamAvatarApp();
extern BOOL isDreamAvatarFreeApp();
extern BOOL isDreamLockscreenApp();
extern BOOL isDreamLockscreenFreeApp();
extern BOOL isLittleGeeAPP();

extern GameAppType gameAppType();

#endif
