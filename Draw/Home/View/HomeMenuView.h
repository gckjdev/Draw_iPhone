//
//  HomeMenuView.h
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import "HomeCommonView.h"

@class HomeMenuView;

typedef enum{
    HomeMenuTypeEnd = -1,
    
    //draw main menu
    HomeMenuTypeDrawDraw = 1000,
    HomeMenuTypeDrawGuess,
    HomeMenuTypeDrawGame,
    HomeMenuTypeDrawTimeline,
    HomeMenuTypeDrawRank,
    HomeMenuTypeDrawContest,
    HomeMenuTypeDrawBBS,
    HomeMenuTypeDrawShop,
    HomeMenuTypeDrawFreeCoins,
    HomeMenuTypeDrawPlayWithFriend,
    HomeMenuTypeDrawApps,
    
    //draw bottom menu
    HomeMenuTypeDrawHome = 1500,
    HomeMenuTypeDrawOpus,
    HomeMenuTypeDrawMessage,
    HomeMenuTypeDrawFriend,
    HomeMenuTypeDrawMore,
    HomeMenuTypeDrawMe,
    HomeMenuTypeDrawSetting,
    
    
    // ZJH main menu
    HomeMenuTypeZJHHelp = 2000,
    HomeMenuTypeZJHStart,
//    HomeMenuTypeZJHBBS,
    HomeMenuTypeZJHRichSite,
    HomeMenuTypeZJHNormalSite,
    HomeMenuTypeZJHVSSite,
    HomeMenuTypeZJHCharge,
    HomeMenuTypeZJHShop,
    HomeMenuTypeZJHFreeCoins,

    // ZJH bottom menu
    HomeMenuTypeZJHMore,

    
    // Dice main menu
    HomeMenuTypeDiceStart = 3000,
    HomeMenuTypeDiceHappyRoom,
    HomeMenuTypeDiceHighRoom,
    HomeMenuTypeDiceSuperHighRoom,
    HomeMenuTypeDiceHelp,
    HomeMenuTypeDiceShop,
    HomeMenuTypeDiceFreeCoins,
    
    // Dice bottom menu
    HomeMenuTypeDiceMore,
    
    //Learn Draw Bottom Menu
    HomeMenuTypeLearnDrawDraw,
    HomeMenuTypeLearnDrawDraft,
    HomeMenuTypeLearnDrawShop,
    HomeMenuTypeLearnDrawMore,
    
}HomeMenuType;

@protocol HomeMenuViewDelegate <HomeCommonViewDelegate>

@optional
- (void)didClickMenu:(HomeMenuView *)menu type:(HomeMenuType)type;

@end


@interface HomeMenuView : HomeCommonView
@property (retain, nonatomic) IBOutlet UIButton *badge;
@property (retain, nonatomic) IBOutlet UIButton *button;
@property (assign, nonatomic) HomeMenuType type;
@property (retain, nonatomic) IBOutlet UILabel *title;

- (IBAction)clickButton:(id)sender;

- (void)updateIcon:(UIImage *)icon
             title:(NSString *)title
              type:(HomeMenuType)type;

- (void)updateBadge:(NSInteger)count;

+ (HomeMenuView *)menuViewWithType:(HomeMenuType)type
                             badge:(NSInteger)badge
                          delegate:(id<HomeCommonViewDelegate>)delegate;
+ (NSString *)titleForType:(HomeMenuType)type;

@end



int *getDrawMainMenuTypeList();
int *getZJHMainMenuTypeList();
int *getDiceMainMenuTypeList();

int *getZJHBottomMenuTypeList();
int *getDrawBottomMenuTypeList();
int *getDiceBottomMenuTypeList();
int *getLearnDrawBottomMenuTypeList();


int *getBottomMenuTypeList();
int *getMainMenuTypeList();


BOOL isMainMenuButton(HomeMenuType type);

