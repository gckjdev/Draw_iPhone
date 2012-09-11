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
{
    GameAppType _gameAppType;
}

@property (retain, nonatomic) UIViewController<MenuButtonDelegate> *controller;
@property (assign, nonatomic) GameAppType gameAppType;

@property (retain, nonatomic) IBOutlet UIImageView *panelBgImage;

+ (BottomMenuPanel *)panelWithController:(UIViewController<MenuButtonDelegate> *)controller gameAppType:(GameAppType)gameAppType;
- (void)loadMenu;
- (BottomMenu *)getMenuButtonByType:(MenuButtonType)type;
- (void)setMenuBadge:(NSInteger)badge forMenuType:(MenuButtonType)type;

@end
