//
//  Header.h
//  ifengNewsOrderDemo
//
//  Created by zer0 on 14-2-26.
//  Copyright (c) 2014年 zer0. All rights reserved.
//

#import "CommonTitleView.h"
#import "ShareImageManager.h"

#ifndef ifengNewsOrderDemo_Header_h
#define ifengNewsOrderDemo_Header_h

#define KOrderButtonFrameOriginX 257.0
#define KOrderButtonFrameOriginY 20
#define KOrderButtonFrameSizeX 63
#define KOrderButtonFrameSizeY 45

//以上是OrderButton的frame值
#define KOrderButtonImage @"topnav_orderbutton.png"
#define KOrderButtonImageSelected @"topnav_orderbutton_selected_unselected.png"

//以上是OrderButton的背景图片
#define KDefaultCountOfUpsideList 10

//默认订阅频道数

//按钮之间的间距
#define BUTTON_LABEL_INDENT (ISIPAD ? 8 : 4)

//按钮的大小
#define KButtonWidth  (ISIPAD ? 160 : 80)
#define KButtonHeight (ISIPAD ? 80 : 40)

#define COLUMN_PER_ROW 4

#define LABEL_WIDTH             (ISIPAD ? 400 : 200)
#define LABEL_HEIGHT            (ISIPAD ? 80 : 40)
#define TAG_LABEL_START_Y       (COMMON_TITLE_VIEW_HEIGHT + STATUS_BAR_HEIGHT + 25)
#define SELECT_LABEL_START_Y    (COMMON_TITLE_VIEW_HEIGHT + STATUS_BAR_HEIGHT + 5)
#define LIST_LABEL_SPACE        20

#define KTableStartPointX (([UIScreen mainScreen].bounds.size.width - KButtonWidth*COLUMN_PER_ROW)/2)
#define KTableStartPointY (SELECT_LABEL_START_Y + LABEL_HEIGHT + LIST_LABEL_SPACE) //120

// colors
#define TAG_LABEL_BG_COLOR              ([UIColor clearColor])
#define TAG_LABEL_TEXT_COLOR            (COLOR_BROWN)
#define TAG_BUTTON_BG_COLOR             (COLOR_ORANGE)
#define TAG_BUTTON_TEXT_COLOR           (COLOR_WHITE)

//#define CLASS_BUTTON_BG_COLOR           ([UIColor greenColor])
//#define CLASS_BUTTON_TEXT_COLOR         ([UIColor grayColor])

#define TAG_LABEL_FONT_SIZE             (ISIPAD ? [UIFont systemFontOfSize:28] : [UIFont systemFontOfSize:14])
#define TAG_BUTTON_FONT_SIZE            (ISIPAD ? [UIFont systemFontOfSize:24] : [UIFont systemFontOfSize:12])

#endif
