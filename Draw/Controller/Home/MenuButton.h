//
//  MenuButton.h
//  Draw
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    MenuButtonTypeOnlinePlay = 100,   
    MenuButtonTypeOfflineDraw,   
    MenuButtonTypeOfflineGuess,   
    MenuButtonTypeFriendPlay,   
    MenuButtonTypeTimeline,   
    MenuButtonTypeShop   
}MenuButtonType;

@interface MenuButton : UIView
{
    
}
@property (retain, nonatomic) IBOutlet UIButton *badge;
@property (retain, nonatomic) IBOutlet UIButton *button;
@property (retain, nonatomic) IBOutlet UILabel *title;
@property (assign, nonatomic) MenuButtonType type;

+ (MenuButton *)menuButtonWithImage:(UIImage *)image 
                              title:(NSString *)title
                              badge:(NSInteger)badge;

- (void)updateImage:(UIImage *)image 
              tilte:(NSString *)title 
              badge:(NSInteger)badge;

+ (MenuButton *)menuButtonWithType:(MenuButtonType)type;
- (void)setBadgeNumber:(NSInteger)badge;

@end
