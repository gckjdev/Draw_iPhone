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
    HomeMenuTypeDrawMainBegin = 1000,
    HomeMenuTypeDrawDraw = 1000,
    HomeMenuTypeDrawGuess,
    HomeMenuTypeDrawGame,
    HomeMenuTypeDrawTimeline,
    HomeMenuTypeDrawRank,
    HomeMenuTypeDrawContest,
    HomeMenuTypeDrawBBS,
    HomeMenuTypeDrawShop,
    HomeMenuTypeDrawFreeCoins,
    HomeMenuTypeDrawApps,
    
    //draw bottom menu
    HomeMenuTypeDrawBottomBegin = 1500,
    HomeMenuTypeDrawHome = 1500,
    HomeMenuTypeDrawOpus,
    HomeMenuTypeDrawMessage,
    HomeMenuTypeDrawFriend,
    HomeMenuTypeDrawMore,
    HomeMenuTypeDrawMe,
    HomeMenuTypeDrawSetting,
    
    //ZJH main menu start at 2000
    HomeMenuTypeZJHMainBegin = 2000,
    HomeMenuTypeZJHHelp = 2000,
    HomeMenuTypeZJHStart,
//    HomeMenuTypeZJHBBS,
    HomeMenuTypeZJHRichSite,
    HomeMenuTypeZJHNormalSite,
    HomeMenuTypeZJHVSSite,
    
    //ZJH bottom menu start at 2500
    HomeMenuTypeZJHBottomBegin = 2500,
//    HomeMenuTypeZJHHome = 2500,
//    HomeMenuTypeZJHMessage,
//    HomeMenuTypeZJHFriend,
//    HomeMenuTypeZJHMore,
//    HomeMenuTypeZJHMe,
//    HomeMenuTypeZJHSetting,
    
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
int *getDrawBottomMenuTypeList();
int *getZJHMainMenuTypeList();
int *getZJHBottomMenuTypeList();
