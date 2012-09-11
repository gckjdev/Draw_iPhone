//
//  MenuPanel.h
//  Draw
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuButton.h"

@interface MenuPanel : UIView<UIScrollViewDelegate, MenuButtonDelegate>
{
    GameAppType _gameAppType;
    UIViewController<MenuButtonDelegate>  *_controller;
}
@property (retain, nonatomic) IBOutlet UILabel *versionLabel;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) UIViewController<MenuButtonDelegate> *controller;
@property (assign, nonatomic) GameAppType gameAppType;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;

+ (MenuPanel *)menuPanelWithController:(UIViewController<MenuButtonDelegate> *)controller gameAppType:(GameAppType)gameAppType;

- (IBAction)changePage:(id)sender;
- (void)loadMenu;
- (MenuButton *)getMenuButtonByType:(MenuButtonType)type;
- (void)setMenuBadge:(NSInteger)badge forMenuType:(MenuButtonType)type;

@end
