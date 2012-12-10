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
    HomeMenuTypeDrawDraw = 100,
    HomeMenuTypeDrawGuess,
    HomeMenuTypeDrawGame,
    HomeMenuTypeDrawTimeline,
    HomeMenuTypeDrawRank,
    HomeMenuTypeDrawContest,
    HomeMenuTypeDrawBBS,

    //draw bottom menu
    HomeMenuTypeDrawHome,
    HomeMenuTypeDrawOpus,
    HomeMenuTypeDrawMessage,
    HomeMenuTypeDrawSetting,
    
    //ZJH main menu
    
    //ZJH bottom menu
}HomeMenuType;

@protocol HomeMenuViewDelegate <HomeCommonViewDelegate>

@optional
- (void)didClickMenu:(HomeMenuView *)menu tag:(NSInteger)tag;

@end


@interface HomeMenuView : HomeCommonView

@property (retain, nonatomic) IBOutlet UIButton *button;
- (IBAction)clickButton:(id)sender;

- (void)updateIcon:(UIImage *)icon
             title:(NSString *)title
               tag:(NSInteger)tag;

@end
