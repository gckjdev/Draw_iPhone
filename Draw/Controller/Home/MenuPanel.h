//
//  MenuPanel.h
//  Draw
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuButton.h"

@class HomeController;
@interface MenuPanel : UIView<UIScrollViewDelegate, MenuButtonDelegate>
{
    GameAppType _gameAppType;
}
@property (retain, nonatomic) IBOutlet UILabel *versionLabel;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) HomeController *controller;
@property (assign, nonatomic) GameAppType gameAppType;

+ (MenuPanel *)menuPanelWithController:(UIViewController *)controller
                           gameAppType:(GameAppType)gameAppType;
- (IBAction)changePage:(id)sender;
- (void)loadMenu;
- (MenuButton *)getMenuButtonByType:(MenuButtonType)type;
- (void)setMenuBadge:(NSInteger)badge forMenuType:(MenuButtonType)type;

@end
