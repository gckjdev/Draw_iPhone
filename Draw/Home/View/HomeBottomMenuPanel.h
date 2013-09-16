//
//  HomeBottomMenuView.h
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import <UIKit/UIKit.h>
#import "HomeCommonView.h"
#import "HomeMenuView.h"

@class HomeBottomMenuPanel;

@protocol HomeBottomMenuPanelDelegate <HomeCommonViewDelegate>

@optional
- (void)homeBottomMenuPanel:(HomeBottomMenuPanel *)bottomMenuPanel
             didClickMenu:(HomeMenuView *)menu
                 menuType:(HomeMenuType)type;
@end

#define BOTTOM_ANIMATION_INTERVAL 1.0

@interface HomeBottomMenuPanel : HomeCommonView<HomeCommonViewProtocol, HomeMenuViewDelegate>
{
    
}

- (void)updateMenu:(HomeMenuType)type badge:(NSInteger)badge;
- (HomeMenuView *)getMenuViewWithType:(HomeMenuType)type;
- (void)hideAnimated:(BOOL)animated;
- (void)showAnimated:(BOOL)animated;
@end
