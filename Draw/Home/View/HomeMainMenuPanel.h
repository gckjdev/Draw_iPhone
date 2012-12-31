//
//  HomeMainMenuView.h
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import <UIKit/UIKit.h>
#import "HomeCommonView.h"
#import "HomeMenuView.h"

@class HomeMainMenuPanel;

@protocol HomeMainMenuPanelDelegate <HomeCommonViewDelegate>

@optional
- (void)homeMainMenuPanel:(HomeMainMenuPanel *)mainMenuPanel
             didClickMenu:(HomeMenuView *)menu
                 menuType:(HomeMenuType)type;
@end


@interface HomeMainMenuPanel : HomeCommonView<HomeCommonViewProtocol, UIScrollViewDelegate, HomeMenuViewDelegate>
{
    
}
- (void)updateMenu:(HomeMenuType)type badge:(NSInteger)badge;
- (void)animatePageButtons;
- (HomeMenuView *)getMenuViewWithType:(HomeMenuType)type;
@end
