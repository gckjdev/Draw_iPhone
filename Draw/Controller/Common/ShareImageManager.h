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

@interface ShareImageManager : NSObject

+ (ShareImageManager*)defaultManager;

- (UIImage*)woodImage;
- (UIImage*)greenImage;
- (UIImage*)orangeImage;

@end
