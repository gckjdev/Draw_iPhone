//
//  ShareImageManager.h
//  Draw
//
//  Created by  on 12-3-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

// buttons images
#import "LocaleUtils.h"
#import "UserManager.h"

//#define DEFAULT_AVATAR_BUNDLE   ([[UserManager defaultManager] defaultAvatar])

#define SETTING_BUTTON_IMAGE    @"home_setting.png"
#define FEEDBACK_BUTTON_IMAGE   @"feedback.png"

// background
#define ROOM_BACKGROUND         @"room.png"
#define SHOWCASE_BACKGROUND         @"buyitems_bg.png"

//cell background
#define WORD_EASY_CELL_BACKGROUND @"easy.png"
#define WORD_NORMAL_CELL_BACKGROUND @"normal.png"
#define WORD_HARD_CELL_BACKGROUND @"hard.png"

@interface ShareImageManager : NSObject

+ (ShareImageManager*)defaultManager;

- (UIImage*)woodImage;
- (UIImage*)greenImage;
- (UIImage*)redImage;
- (UIImage*)orangeImage;
- (UIImage *)buyButtonImage;
- (UIImage*)showcaseBackgroundImage;
- (UIImage *)coinImage;
- (UIImage *)toolImage;
- (UIImage *)popupImage;
- (UIImage *)popupChatImageLeft;
- (UIImage *)popupChatImageRight;

- (UIImage *)whitePaperImage;
- (UIImage *)pickEasyWordCellImage;
- (UIImage *)pickNormakWordCellImage;
- (UIImage *)pickHardWordCellImage;

//- (UIImage *)blackColorImage;
//- (UIImage *)redColorImage;
//- (UIImage *)greenColorImage;
//- (UIImage *)blueColorImage;
//- (UIImage *)yellowColorImage;
//- (UIImage *)orangeColorImage;
//- (UIImage *)pinkColorImage;
//- (UIImage *)brownColorImage;
//- (UIImage *)skyColorImage;
//- (UIImage *)whiteColorImage;

- (UIImage *)addColorImage;


- (UIImage *)selectedPointImage;
- (UIImage *)unSelectedPointImage;
- (UIImage *)toolPopupImage;
- (UIImage *)drawingMarkSmallImage;
- (UIImage *)drawingMarkLargeImage;
- (UIImage *)scoreBackgroundImage;
- (UIImage *)toolNumberImage;

- (UIImage *)inputImage;
- (UIImage *)avatarUnSelectImage;
- (UIImage *)avatarSelectImage;

- (UIImage*)femaleDefaultAvatarImage;
- (UIImage*)maleDefaultAvatarImage;

- (UIImage *)savePercentImage;

- (UIImage *)penMaskImage;
- (UIImage *)colorMaskImage;

- (UIImage *)myFoucsImage;
- (UIImage *)myFoucsSelectedImage;
- (UIImage *)foucsMeImage;
- (UIImage *)foucsMeSelectedImage;
- (UIImage *)normalButtonImage;
- (UIImage *)sinaWeiboImage;
- (UIImage *)qqWeiboImage;
- (UIImage *)facebookImage;
- (UIImage *)messageImage;
//- (UIImage *)snowImage;

- (UIImage *)penImage;
- (UIImage *)pencilImage;
- (UIImage *)waterPenImage;
- (UIImage *)iceImage;
- (UIImage *)quillImage;
@end
