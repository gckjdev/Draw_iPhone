//
//  SuperHomeController.h
//  Draw
//
//  Created by qqn_pipi on 12-10-6.
//
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"
#import "HomeHeaderPanel.h"
#import "HomeMainMenuPanel.h"
#import "HomeBottomMenuPanel.h"
#import "UserService.h"
#import "StatisticManager.h"

#define UPDATE_HOME_BG_NOTIFICATION_KEY @"UPDATE_HOME_BG"


@interface SuperHomeController : PPViewController<HomeCommonViewDelegate, UserServiceDelegate>
{
    
}

@property(nonatomic, retain)HomeHeaderPanel *homeHeaderPanel;
@property(nonatomic, retain)HomeMainMenuPanel *homeMainMenuPanel;
@property(nonatomic, retain)HomeBottomMenuPanel *homeBottomMenuPanel;
@property(nonatomic, retain)UIView *adView;

- (void)updateAllBadge;
- (BOOL)isRegistered;
- (BOOL)toRegister;

- (void)handleJoinGameResponse;
- (void)handleConnectedResponse;
- (void)handleDisconnectWithError:(NSError*)error;
- (float)getMainMenuOriginY;
- (float)getBottomMenuOriginY;

//- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel
//   didClickAvatarButton:(UIButton *)button;

- (void)homeMainMenuPanel:(HomeMainMenuPanel *)mainMenuPanel
       didClickAvatarView:(AvatarView *)avatarView;

- (void)enterFriend;
+ (NSDictionary*)defaultMenuTitleDictionary;
+ (NSDictionary*)defaultMenuImageDictionary;


// the follow is to be implemented by sub class

+ (int*)getMainMenuList;
- (BOOL)handleClickMenu:(HomeMainMenuPanel *)mainMenuPanel
                   menu:(HomeMenuView *)menu
               menuType:(HomeMenuType)type;

+ (int *)getBottomMenuList;
- (BOOL)handleClickBottomMenu:(HomeBottomMenuPanel *)bottomMenuPanel
                         menu:(HomeMenuView *)menu
                     menuType:(HomeMenuType)type;

- (NSArray*)noCheckedMenuTypes;
+ (NSDictionary*)menuTitleDictionary;
+ (NSDictionary*)menuImageDictionary;


@end
