//
//  ShareImageManager.h
//  Draw
//
//  Created by  on 12-3-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

// buttons images
#define SETTING_BUTTON_IMAGE    @"home_setting.png"
#define FEEDBACK_BUTTON_IMAGE   @"feedback.png"

// background
#define ROOM_BACKGROUND         @"room.png"


//cell background
#define WORD_EASY_CELL_BACKGROUND @"easy.png"
#define WORD_NORMAL_CELL_BACKGROUND @"normal.png"
#define WORD_HARD_CELL_BACKGROUND @"hard.png"

@interface ShareImageManager : NSObject

+ (ShareImageManager*)defaultManager;

- (UIImage*)woodImage;
- (UIImage*)greenImage;
- (UIImage*)orangeImage;
- (UIImage *)pickEasyWordCellImage;
- (UIImage *)pickNormakWordCellImage;
- (UIImage *)pickHardWordCellImage;


@end
