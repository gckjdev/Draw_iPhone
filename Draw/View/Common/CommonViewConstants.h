//
//  CommonViewConstants.h
//  Draw
//
//  Created by 王 小涛 on 13-8-21.
//
//


#define COMMON_TITLE_VIEW_WIDTH  ([UIScreen mainScreen].bounds.size.width) //(ISIPAD ? 768 : 320)
#define DELTA (ISIOS7?20:0)
#define COMMON_TITLE_VIEW_HEIGHT ((ISIPAD ? 88 : 44) + DELTA)

#define COMMON_TAB_BUTTON_Y      COMMON_TITLE_VIEW_HEIGHT
#define COMMON_TAB_BUTTON_HEIGHT (ISIPAD ? 65 : 30)

#define STATUS_BAR_HEIGHT (ISIOS7?0:20)

// 20 is status bar height
#define COMMON_TAB_TABLE_VIEW_HEIGHT ([UIScreen mainScreen].bounds.size.height - COMMON_TAB_BUTTON_HEIGHT - COMMON_TITLE_VIEW_HEIGHT - STATUS_BAR_HEIGHT)-(ISIPHONE5?88:0)

#define NORMAL_TABLE_VIEW_HEIGHT ([UIScreen mainScreen].bounds.size.height - COMMON_TITLE_VIEW_HEIGHT - STATUS_BAR_HEIGHT)

// 设置tableview的frame，根据titleview高度和tab controller高度自动设置frame的y取值
#define SET_COMMON_TAB_TABLE_VIEW_Y(t)     ( \
    t.frame = CGRectMake(t.frame.origin.x, COMMON_TAB_BUTTON_Y + COMMON_TAB_BUTTON_HEIGHT, t.frame.size.width, COMMON_TAB_TABLE_VIEW_HEIGHT))

// 设置tableview的frame，根据titleview高度自动设置frame的y取值
#define SET_NORMAL_TABLE_VIEW_Y(t)     ( \
t.frame = CGRectMake(t.frame.origin.x, COMMON_TITLE_VIEW_HEIGHT, t.frame.size.width, NORMAL_TABLE_VIEW_HEIGHT) )

#define SET_NORMAL_CONTROLLER_VIEW_FRAME(XXXview)     { \
CGRect rectxxx = [UIScreen mainScreen].bounds;\
rectxxx.size.height -= 20; \
XXXview.frame = rectxxx;}

