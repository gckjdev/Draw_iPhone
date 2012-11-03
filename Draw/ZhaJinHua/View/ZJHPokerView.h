//
//  ZJHPokerView.h
//  Draw
//
//  Created by 王 小涛 on 12-10-26.
//
//

#import <UIKit/UIKit.h>
#import "PokerView.h"
#import "ZJHUserPlayInfo.h"

#define SMALL_POKER_VIEW_WIDTH 27
#define SMALL_POKER_VIEW_HEIGHT 36
#define SMALL_POKER_GAP (- SMALL_POKER_VIEW_WIDTH * 0.8)

#define BIG_POKER_VIEW_WIDTH 35
#define BIG_POKER_VIEW_HEIGHT 47
#define BIG_POKER_GAP (BIG_POKER_VIEW_WIDTH * 0.2)

typedef enum {
    ZJHPokerSectorTypeNone = 0,
    ZJHPokerSectorTypeRight = 1,
    ZJHPokerSectorTypeLeft = 2,
    ZJHPokerSectorTypeCenter = 3
} ZJHPokerSectorType;

@interface ZJHPokerView : UIView

@property (retain, nonatomic) PokerView *pokerView1;
@property (retain, nonatomic) PokerView *pokerView2;
@property (retain, nonatomic) PokerView *pokerView3;

- (void)updateWithPokers:(NSArray *)pokers
                    size:(CGSize)size
                     gap:(CGFloat)gap
                delegate:(id<PokerViewProtocol>)delegate;

- (void)clear;

// 别人看牌时，调用这个接口，把牌摊成扇形
- (void)makeSectorShape:(ZJHPokerSectorType)sectorType animation:(BOOL)animation;

// 自己看牌时，调用这个接口，把自己三张牌都翻过来。
- (void)faceUpCards:(BOOL)animation;

// 别人亮牌时，调用这个接口，把自己那张亮的牌翻过来。
- (void)faceUpCard:(int)cardId animation:(BOOL)animation;

// 别人或自己弃牌，调用这个接口，表示弃牌
- (void)foldCards:(BOOL)animation;

// 别人或自己比牌，调用这个接口，表示比牌结果
- (void)compare:(BOOL)animation
            win:(BOOL)win;

@end
