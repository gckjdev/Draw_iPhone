//
//  CommonViewConstants.h
//  Draw
//
//  Created by 王 小涛 on 13-8-21.
//
//


#define COMMON_TITLE_VIEW_WIDTH  (ISIPAD ? 768 : 320)
#define COMMON_TITLE_VIEW_HEIGHT (ISIPAD ? 88 : 44)

#define COMMON_TAB_BUTTON_Y      COMMON_TITLE_VIEW_HEIGHT
#define COMMON_TAB_BUTTON_HEIGHT (ISIPAD ? 65 : 30)

// 设置tableview的frame，根据titleview高度和tab controller高度自动设置frame的y取值
#define SET_COMMON_TAB_TABLE_VIEW_Y(t)     ( \
    t.frame = CGRectMake(t.frame.origin.x, COMMON_TAB_BUTTON_Y + COMMON_TAB_BUTTON_HEIGHT, t.frame.size.width, t.frame.size.height) )

// 设置tableview的frame，根据titleview高度自动设置frame的y取值
#define SET_NORMAL_TABLE_VIEW_Y(t)     ( \
t.frame = CGRectMake(t.frame.origin.x, COMMON_TITLE_VIEW_HEIGHT, t.frame.size.width, t.frame.size.height) )
