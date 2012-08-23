//
//  BottomMenuPanel.h
//  Draw
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//#import "MenuPanel.h"
#import "BottomMenu.h"
@interface BottomMenuPanel : UIView<MenuButtonDelegate>


@property (retain, nonatomic) UIViewController *controller;

+ (BottomMenuPanel *)panelWithController:(UIViewController *)controller;
- (void)loadMenu;
- (BottomMenu *)getMenuButtonByType:(MenuButtonType)type;
- (void)setMenuBadge:(NSInteger)badge forMenuType:(MenuButtonType)type;

@end
