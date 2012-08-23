//
//  MenuButton.h
//  Draw
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    
    //for main menu
    MenuButtonTypeOnlinePlay = 100,   
    MenuButtonTypeOfflineDraw,   
    MenuButtonTypeOfflineGuess,   
    MenuButtonTypeFriendPlay,   
    MenuButtonTypeTimeline,   
    MenuButtonTypeShop,   
    MenuButtonTypeEnd,
    
    
    //for bottom menu
    
    MenuButtonTypeSettings = 200,   
    MenuButtonTypeOpus,   
    MenuButtonTypeFriend,   
    MenuButtonTypeChat,   
    MenuButtonTypeFeedback,   

    BottomMenuTypeEnd,

    //unuse
    MenuButtonTypeCheckIn
    
    
}MenuButtonType;

#define MenuButtonTypeBase MenuButtonTypeOnlinePlay
#define BottomMenuTypeBase MenuButtonTypeSettings

#define MENU_BUTTON_WIDTH ([DeviceDetection isIPAD] ? 169 : 71)
#define MENU_BUTTON_HEIGHT ([DeviceDetection isIPAD] ? 191 : 87)

@class MenuButton;
//@class BottomMenu;

@protocol MenuButtonDelegate <NSObject>

@optional
- (void)didClickMenuButton:(MenuButton *)menuButton;
//- (void)didClickBottomMenu:(MenuButton *)menuButton;

@end

@interface MenuButton : UIView
{
    
}
@property (retain, nonatomic) IBOutlet UIButton *badge;
@property (retain, nonatomic) IBOutlet UIButton *button;
@property (retain, nonatomic) IBOutlet UILabel *title;
@property (assign, nonatomic) MenuButtonType type;
@property (assign, nonatomic) id<MenuButtonDelegate> delegate;

+ (MenuButton *)menuButtonWithImage:(UIImage *)image 
                              title:(NSString *)title
                              badge:(NSInteger)badge;

- (void)updateImage:(UIImage *)image 
              tilte:(NSString *)title 
              badge:(NSInteger)badge;

+ (MenuButton *)menuButtonWithType:(MenuButtonType)type;
- (void)setBadgeNumber:(NSInteger)badge;



@end
