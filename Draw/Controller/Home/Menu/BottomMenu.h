//
//  BottomMenu.h
//  Draw
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MenuButton.h"

@interface BottomMenu : MenuButton

#define BOTTOM_MENU_WIDTH ([DeviceDetection isIPAD] ? 105 : 50)
#define BOTTOM_MENU_HEIGHT ([DeviceDetection isIPAD] ? 86 : 43)


+ (BottomMenu *)bottomMenuWithType:(MenuButtonType)type 
                       gameAppType:(GameAppType)gameAppType;
@end
