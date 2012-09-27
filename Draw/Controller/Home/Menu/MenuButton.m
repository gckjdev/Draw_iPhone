//
//  MenuButton.m
//  Draw
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MenuButton.h"
#import "ShareImageManager.h"
#import "MobClick.h"

@implementation MenuButton
@synthesize badge = _badge;
@synthesize button = _button;
@synthesize title = _title;
@synthesize type = _type;
@synthesize delegate = _delegate;
@synthesize gameAppType = _gameAppType;

- (void)updateImage:(UIImage *)image 
              tilte:(NSString *)title 
              badge:(NSInteger)badge
{
    [_button setImage:image forState:UIControlStateNormal];
    [self.title setText:title];
    [self setBadgeNumber:badge];
}



+ (MenuButton *)menuButtonWithImage:(UIImage *)image 
                              title:(NSString *)title
                              badge:(NSInteger)badge 
                        gameAppType:(GameAppType)type

{
    NSString *identifier = (type == GameAppTypeDraw) ?  @"DiceMenu" : @"MenuButton";
//    static NSString *identifier = @"MenuButton";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    MenuButton *menuButton = [topLevelObjects objectAtIndex:0];
    [menuButton updateImage:image tilte:title badge:badge];
    
    return  menuButton;

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
        case MenuButtonTypeTop:
            return NSLS(@"kTop");
        case MenuButtonTypeContest:
            return NSLS(@"kContest"); 
            
        case MenuButtonTypeDiceStart:
            return NSLS(@"kDiceMenuStart"); 
        case MenuButtonTypeDiceHelp:
            return NSLS(@"kDiceMenuHelp"); 
            
        case MenuButtonTypeDiceHappyRoom:
            return NSLS(@"kDiceMenuHappyRoom"); 
        case MenuButtonTypeDiceHighRoom:
            return NSLS(@"kDiceMenuHighRoom"); 
        case MenuButtonTypeDiceSuperHighRoom:
            return NSLS(@"kDiceMenuSuperHighRoom"); 
            
//        case MenuButtonTypeDiceRoom:
//            return NSLS(@"kDiceMenuRoom"); 
        case MenuButtonTypeDiceShop:
            return NSLS(@"kDiceMenuShop"); 
        default:
            return nil;
    }
    
}

+ (UIImage *)imageForMenuButtonType:(MenuButtonType)type 
                        gameAppType:(GameAppType)gameAppType
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
        case MenuButtonTypeTop:
            return [imageManager topImage];
        case MenuButtonTypeContest:
            return [imageManager contestImage];

            //dice
        case MenuButtonTypeDiceStart:
            return [imageManager diceStartMenuImage];
        case MenuButtonTypeDiceShop:
            return [imageManager diceShopImage];
        case MenuButtonTypeDiceHelp:
            return [imageManager diceHelpMenuImage];
        case MenuButtonTypeDiceHappyRoom:
            return [imageManager normalRoomMenuImage];
        case MenuButtonTypeDiceHighRoom:
            return [imageManager highRoomMenuImage];
        case MenuButtonTypeDiceSuperHighRoom:
            return [imageManager superHighRoomMenuImage];
        default:
            return nil;
    }

}

- (void)handleClick:(UIButton *)button
{
    [MobClick event:@"CLICK_MENU_BUTTON" 
              label:[MenuButton titleForMenuButtonType:self.type] 
                acc:1];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickMenuButton:)]) {
        [self.delegate didClickMenuButton:self];
    }
}

+ (MenuButton *)menuButtonWithType:(MenuButtonType)type 
                       gameAppType:(GameAppType)gameAppType

{
    UIImage *image = [MenuButton imageForMenuButtonType:type gameAppType:gameAppType];
    NSString *title = [MenuButton titleForMenuButtonType:type];
    MenuButton *menu = [MenuButton menuButtonWithImage:image 
                                                 title:title 
                                                 badge:0 
                                           gameAppType:gameAppType];
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
 
        MenuButtonTypeOfflineDraw,   
        MenuButtonTypeOfflineGuess,   
        MenuButtonTypeTimeline,   
        MenuButtonTypeTop,
        
        MenuButtonTypeOnlinePlay,  
        MenuButtonTypeFriendPlay,   
        MenuButtonTypeContest,
        MenuButtonTypeShop,    
        //must add the end mark.
        MenuButtonTypeEnd
    };
    return list;
    
}

int *diceMainMenuTypeList()
{
    static int list[] = {    
        MenuButtonTypeDiceStart,  
        
        MenuButtonTypeDiceHappyRoom,
        MenuButtonTypeDiceHighRoom,
        MenuButtonTypeDiceSuperHighRoom,
        MenuButtonTypeDiceHelp,   
        MenuButtonTypeDiceShop,   
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



