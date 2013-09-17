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
@class AvatarView;

@protocol HomeMainMenuPanelDelegate <HomeCommonViewDelegate>

@optional
- (void)homeMainMenuPanel:(HomeMainMenuPanel *)mainMenuPanel
             didClickMenu:(HomeMenuView *)menu
                 menuType:(HomeMenuType)type;

- (void)homeMainMenuPanel:(HomeMainMenuPanel *)mainMenuPanel
       didClickAvatarView:(AvatarView *)avatarView;

@end


@interface HomeMainMenuPanel : HomeCommonView<HomeCommonViewProtocol, UIScrollViewDelegate, HomeMenuViewDelegate>
{
    
}
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIButton *previous;
@property (retain, nonatomic) IBOutlet UIButton *next;
@property (assign, nonatomic) NSInteger pageCount;

- (IBAction)clickPageButton:(id)sender;
- (void)animatePageButtons;
- (void)updatePageButton;
- (void)hidePageButtons;

- (void)updateMenu:(HomeMenuType)type badge:(NSInteger)badge;


- (HomeMenuView *)getMenuViewWithType:(HomeMenuType)type;
@end
