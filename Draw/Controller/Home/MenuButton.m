//
//  MenuButton.m
//  Draw
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MenuButton.h"
#import "ShareImageManager.h"

@implementation MenuButton
@synthesize badge = _badge;
@synthesize button = _button;
@synthesize title = _title;
@synthesize type = _type;
@synthesize delegate = _delegate;

+ (MenuButton *)menuButtonWithImage:(UIImage *)image 
                              title:(NSString *)title
                              badge:(NSInteger)badge
{

    static NSString *identifier = @"MenuButton";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    MenuButton *menuButton = [topLevelObjects objectAtIndex:0];
    [menuButton updateImage:image tilte:title badge:badge];
    
    return  menuButton;

}
- (void)updateImage:(UIImage *)image 
              tilte:(NSString *)title 
              badge:(NSInteger)badge
{
    [_button setImage:image forState:UIControlStateNormal];
    [_title setText:title];
    [self setBadgeNumber:badge];
}


+ (NSString *)titleForMenuButtonType:(MenuButtonType)type
{
    
    switch (type) {
        case MenuButtonTypeOnlinePlay:
            return NSLS(@"kStart");
        case MenuButtonTypeOfflineDraw:
            return NSLS(@"kDrawOnly");
        case MenuButtonTypeOfflineGuess:
            return NSLS(@"kGuessOnly");
        case MenuButtonTypeFriendPlay:
            return NSLS(@"kPlayWithFriend");
        case MenuButtonTypeTimeline:
            return NSLS(@"kFeed");
        case MenuButtonTypeShop:
            return NSLS(@"kShop");            
        default:
            return nil;
    }
    
}

+ (UIImage *)imageForMenuButtonType:(MenuButtonType)type
{
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    switch (type) {
        case MenuButtonTypeOnlinePlay:
            return [imageManager onlinePlayImage];
        case MenuButtonTypeOfflineDraw:
            return [imageManager offlineDrawImage];
        case MenuButtonTypeOfflineGuess:
            return [imageManager offlineGuessImage];
        case MenuButtonTypeFriendPlay:
            return [imageManager friendPlayImage];
        case MenuButtonTypeTimeline:
            return [imageManager timelineImage];
        case MenuButtonTypeShop:
            return [imageManager shopImage];
        default:
            return nil;
    }

}

- (void)handleClick:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickMenuButton:)]) {
        [self.delegate didClickMenuButton:self];
    }
}

+ (MenuButton *)menuButtonWithType:(MenuButtonType)type
{
    UIImage *image = [MenuButton imageForMenuButtonType:type];
    NSString *title = [MenuButton titleForMenuButtonType:type];
    MenuButton *menu = [MenuButton menuButtonWithImage:image 
                                                 title:title 
                                                 badge:0];
    [menu setType:type];
    menu.button.tag = type;
    [menu.button addTarget:menu action:@selector(handleClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return menu;
}

- (void)setBadgeNumber:(NSInteger)badge
{
    if (badge <= 0) {
        _badge.hidden = YES;
    }else{
        _badge.hidden = NO;
        NSString *badgeString = (badge > 99) ? @"N" : 
        [NSString stringWithFormat:@"%d", badge];
        [_badge setTitle:badgeString forState:UIControlStateNormal];
    }
}

- (void)dealloc {
    PPRelease(_badge);
    PPRelease(_button);
    PPRelease(_title);
    [super dealloc];
}
@end




#pragma mark - Get the Menu list for the game type
int *drawMainMenuTypeList()
{
    static int list[] = {    
        MenuButtonTypeOnlinePlay,   
        MenuButtonTypeOfflineDraw,   
        MenuButtonTypeOfflineGuess,   
        MenuButtonTypeFriendPlay,   
        MenuButtonTypeTimeline,   
        MenuButtonTypeShop,    

        //must add the end mark.
        MenuButtonTypeEnd
    };
    return list;
    
}

int *diceMainMenuTypeList()
{
    static int list[] = {    
        MenuButtonTypeStart,   
        MenuButtonTypeRoom,   
        MenuButtonTypeHelp,   
        MenuButtonTypeShop,   
        //must add the end mark.
        MenuButtonTypeEnd
    };
    return list;
}

int *drawBottomMenuTypeList()
{
    static int list[] = {    
        MenuButtonTypeSettings,   
        MenuButtonTypeOpus,   
        MenuButtonTypeFriend,   
        MenuButtonTypeChat,   
        MenuButtonTypeFeedback,   
        
        //must add the end mark.
        MenuButtonTypeEnd
    };
    return list;    
}

int *diceBottomMenuTypeList()
{
    
    static int list[] = {    
        MenuButtonTypeSettings,   
        MenuButtonTypeFriend,   
        MenuButtonTypeChat,   
        MenuButtonTypeFeedback,   
        
        //must add the end mark.
        MenuButtonTypeEnd
    };
    return list;
}

int *getMainMenuTypeListByGameAppType(GameAppType type)
{
    if (type == GameAppTypeDraw) {
        return drawMainMenuTypeList();
    }
    return diceMainMenuTypeList();
}
int *getBottomMenuTypeListByGameAppType(GameAppType type)
{
    if (type == GameAppTypeDraw) {
        return drawBottomMenuTypeList();
    }
    return diceBottomMenuTypeList();
}

