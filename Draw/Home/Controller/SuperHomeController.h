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

@interface SuperHomeController : PPViewController<HomeCommonViewDelegate, UserServiceDelegate>
{
    
}

@property(nonatomic, retain)HomeHeaderPanel *homeHeaderPanel;
@property(nonatomic, retain)HomeMainMenuPanel *homeMainMenuPanel;
@property(nonatomic, retain)HomeBottomMenuPanel *homeBottomMenuPanel;
@property(nonatomic, retain)UIView *adView;

- (void)updateAllBadge;
- (BOOL)isRegistered;
- (void)toRegister;

- (void)handleJoinGameResponse;
- (void)handleConnectedResponse;
- (void)handleDisconnectWithError:(NSError*)error;
- (float)getMainMenuOriginY;
- (float)getBottomMenuOriginY;

- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel
   didClickAvatarButton:(UIButton *)button;


@end
