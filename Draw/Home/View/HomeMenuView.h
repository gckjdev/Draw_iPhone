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
    //draw main menu
    HomeMenuTypeDrawMainBegin = 1000,
    HomeMenuTypeDrawDraw = 1000,
    HomeMenuTypeDrawGuess,
    HomeMenuTypeDrawGame,
    HomeMenuTypeDrawTimeline,
    HomeMenuTypeDrawRank,
    HomeMenuTypeDrawContest,
    HomeMenuTypeDrawBBS,

    //draw bottom menu
    HomeMenuTypeDrawBottomBegin = 1500,
    HomeMenuTypeDrawHome = 1500,
    HomeMenuTypeDrawOpus,
    HomeMenuTypeDrawMessage,
    HomeMenuTypeDrawSetting,
    
    //ZJH main menu start at 2000
    HomeMenuTypeZJHMainBegin = 2000,
    
    //ZJH bottom menu start at 2500
    HomeMenuTypeZJHBottomBegin = 2500,
    
}HomeMenuType;

@protocol HomeMenuViewDelegate <HomeCommonViewDelegate>

@optional
- (void)didClickMenu:(HomeMenuView *)menu tag:(NSInteger)tag;

@end


@interface HomeMenuView : HomeCommonView
@property (retain, nonatomic) IBOutlet UIButton *badge;

@property (retain, nonatomic) IBOutlet UIButton *button;
- (IBAction)clickButton:(id)sender;

- (void)updateIcon:(UIImage *)icon
             title:(NSString *)title
              type:(HomeMenuType)type;

- (void)updateBadge:(NSInteger)count;

+ (HomeMenuView *)menuViewWithType:(HomeMenuType)type
                             badge:(NSInteger)badge
                          delegate:(id<HomeCommonViewDelegate>)delegate;
@end
