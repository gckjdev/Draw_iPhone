//
//  DrawConstants.h
//  Draw
//
//  Created by Orange on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef Draw_DrawConstants_h
#define Draw_DrawConstants_h

typedef enum {
    CLICK_WORD = 0,
    ENTER_ROOM,
    BINGO,
    WRONG,
    GAME_WIN,
    RUN_AWAY,
    QUICK_QUICK,
    WAIT_WAIT,
    
    
}Draw_sound_index;

typedef enum{
    TypeDraw = 0,       //画画给别人猜
    TypeGraffiti = 1,   //涂鸦
    TypeContest = 2,    //参赛
    TypePhoto = 3       //照片
}TargetType;

#define YOUMI_APP_ID    @"c278f8dc80295b18"
#define YOUMI_APP_KEY   @"30c93a1226f94496"

#endif
